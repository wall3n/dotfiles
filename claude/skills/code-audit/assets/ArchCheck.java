// Standalone ArchUnit check for the code-audit skill.
// Runs with the Java source launcher, so the project needs no test or pom change:
//   java -cp "<archunit jars>:<target/classes>" ArchCheck.java <classes-dir> <base-package> [layers]
// layers: optional "domain=pkg1,pkg2;application=...;infrastructure=...;web=...;persistence=..."
// with sub-package names under <base-package>. Without it, the layers are detected by name.
// Output: one block per rule, "PASS <id>" or "FAIL <id> (<n>)" followed by the violations.
// Exit code: 0 when all rules pass, 1 when one or more rules fail, 2 on a usage error.

import com.tngtech.archunit.base.DescribedPredicate;
import com.tngtech.archunit.core.domain.JavaClass;
import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ClassFileImporter;
import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.lang.ArchRule;
import com.tngtech.archunit.lang.EvaluationResult;
import com.tngtech.archunit.library.GeneralCodingRules;

import java.nio.file.Path;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.stream.Collectors;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;
import static com.tngtech.archunit.library.dependencies.SlicesRuleDefinition.slices;

public class ArchCheck {

    private static final Map<String, List<String>> DEFAULT_NAMES = new LinkedHashMap<>();

    static {
        DEFAULT_NAMES.put("domain", List.of("domain", "model", "core"));
        DEFAULT_NAMES.put("application", List.of("application", "usecase", "usecases", "service", "services"));
        DEFAULT_NAMES.put("infrastructure", List.of("infrastructure", "adapter", "adapters", "infra"));
        DEFAULT_NAMES.put("web", List.of("rest", "web", "controller", "controllers", "api"));
        DEFAULT_NAMES.put("persistence", List.of("persistence", "repository", "repositories", "jpa", "db"));
    }

    private static final String[] FRAMEWORKS = {
        "org.springframework..", "jakarta.persistence..", "javax.persistence..",
        "org.hibernate..", "com.fasterxml.jackson..", "jakarta.servlet..", "javax.servlet.."
    };

    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("usage: ArchCheck.java <classes-dir> <base-package> [layers]");
            System.exit(2);
        }
        String base = args[1];
        JavaClasses classes = new ClassFileImporter()
                .withImportOption(ImportOption.Predefined.DO_NOT_INCLUDE_TESTS)
                .importPath(Path.of(args[0]));
        if (classes.isEmpty()) {
            System.err.println("no classes found in " + args[0] + " - compile first");
            System.exit(2);
        }

        Map<String, String[]> layers = args.length > 2 ? parseLayers(base, args[2]) : detectLayers(base, classes);
        System.out.println("LAYERS " + layers.entrySet().stream()
                .map(e -> e.getKey() + "=" + String.join(",", e.getValue()))
                .collect(Collectors.joining("; ")));

        Map<String, ArchRule> rules = new LinkedHashMap<>();
        String[] domain = layers.get("domain");
        String[] application = layers.get("application");
        String[] infrastructure = layers.get("infrastructure");
        String[] web = layers.get("web");
        String[] persistence = layers.get("persistence");

        if (domain != null) {
            List<String> outer = new ArrayList<>();
            for (String layer : List.of("application", "infrastructure", "web", "persistence")) {
                if (layers.get(layer) != null) outer.addAll(List.of(layers.get(layer)));
            }
            if (!outer.isEmpty()) {
                rules.put("ARCH-domain-independent", noClasses().that().resideInAnyPackage(domain)
                        .should().dependOnClassesThat().resideInAnyPackage(outer.toArray(String[]::new))
                        .because("the domain depends on no other layer"));
            }
            rules.put("ARCH-domain-framework-free", noClasses().that().resideInAnyPackage(domain)
                    .should().dependOnClassesThat().resideInAnyPackage(FRAMEWORKS)
                    .because("the domain model must not depend on Spring, JPA, or Jackson"));
        }
        if (application != null) {
            List<String> adapters = new ArrayList<>();
            for (String layer : List.of("infrastructure", "web", "persistence")) {
                if (layers.get(layer) != null) adapters.addAll(List.of(layers.get(layer)));
            }
            if (!adapters.isEmpty()) {
                rules.put("ARCH-application-no-adapters", noClasses().that().resideInAnyPackage(application)
                        .should().dependOnClassesThat().resideInAnyPackage(adapters.toArray(String[]::new))
                        .because("use cases talk to adapters through ports, not directly"));
            }
            rules.put("ARCH-application-no-web", noClasses().that().resideInAnyPackage(application)
                    .should().dependOnClassesThat().resideInAnyPackage("org.springframework.web..", "jakarta.servlet..", "javax.servlet..")
                    .because("use cases do not know about HTTP"));
        }
        if (web != null) {
            rules.put("ARCH-web-no-repository", noClasses().that().resideInAnyPackage(web)
                    .should().dependOnClassesThat(isRepository(persistence))
                    .because("controllers go through the application layer, not straight to the database"));
            rules.put("ARCH-web-no-entity", noClasses().that().resideInAnyPackage(web)
                    .should().dependOnClassesThat().areAnnotatedWith("jakarta.persistence.Entity")
                    .orShould().dependOnClassesThat().areAnnotatedWith("javax.persistence.Entity")
                    .because("the REST layer exposes DTOs, not JPA entities"));
        }
        rules.put("ARCH-no-package-cycles", slices().matching(base + ".(*)..").should().beFreeOfCycles()
                .allowEmptyShould(true));
        rules.put("ARCH-no-field-injection", GeneralCodingRules.NO_CLASSES_SHOULD_USE_FIELD_INJECTION);
        rules.put("ARCH-no-standard-streams", GeneralCodingRules.NO_CLASSES_SHOULD_ACCESS_STANDARD_STREAMS);
        rules.put("ARCH-no-generic-exceptions", GeneralCodingRules.NO_CLASSES_SHOULD_THROW_GENERIC_EXCEPTIONS);
        rules.put("ARCH-no-java-util-logging", GeneralCodingRules.NO_CLASSES_SHOULD_USE_JAVA_UTIL_LOGGING);

        int failed = 0;
        for (Map.Entry<String, ArchRule> entry : rules.entrySet()) {
            EvaluationResult result = entry.getValue().allowEmptyShould(true).evaluate(classes);
            List<String> details = result.getFailureReport().getDetails();
            if (details.isEmpty()) {
                System.out.println("PASS " + entry.getKey());
            } else {
                failed++;
                System.out.println("FAIL " + entry.getKey() + " (" + details.size() + ")");
                System.out.println("  rule: " + entry.getValue().getDescription());
                details.forEach(d -> System.out.println("  - " + d));
            }
        }
        System.out.println("SUMMARY " + (rules.size() - failed) + " passed, " + failed + " failed");
        System.exit(failed == 0 ? 0 : 1);
    }

    private static DescribedPredicate<JavaClass> isRepository(String[] persistence) {
        return new DescribedPredicate<>("are repositories") {
            @Override
            public boolean test(JavaClass c) {
                boolean inPersistence = persistence != null && JavaClass.Predicates.resideInAnyPackage(persistence).test(c);
                return inPersistence
                        || c.isAnnotatedWith("org.springframework.stereotype.Repository")
                        || c.isAssignableTo("org.springframework.data.repository.Repository");
            }
        };
    }

    private static Map<String, String[]> parseLayers(String base, String spec) {
        Map<String, String[]> layers = new LinkedHashMap<>();
        for (String part : spec.split(";")) {
            String[] kv = part.split("=", 2);
            if (kv.length == 2 && !kv[1].isBlank()) {
                layers.put(kv[0].trim(), toPackages(base, List.of(kv[1].split(","))));
            }
        }
        return layers;
    }

    // A layer is a sub-package (at any depth under base) whose last segment matches a known name.
    private static Map<String, String[]> detectLayers(String base, JavaClasses classes) {
        Set<String> packages = new TreeSet<>();
        for (JavaClass c : classes) {
            String pkg = c.getPackageName();
            if (pkg.startsWith(base + ".")) {
                String[] segments = pkg.substring(base.length() + 1).split("\\.");
                StringBuilder path = new StringBuilder();
                for (String s : segments) {
                    path.append(path.length() == 0 ? "" : ".").append(s);
                    packages.add(path.toString());
                }
            }
        }
        Map<String, String[]> layers = new LinkedHashMap<>();
        for (Map.Entry<String, List<String>> entry : DEFAULT_NAMES.entrySet()) {
            List<String> found = packages.stream()
                    .filter(p -> entry.getValue().contains(p.substring(p.lastIndexOf('.') + 1)))
                    .toList();
            if (!found.isEmpty()) layers.put(entry.getKey(), toPackages(base, found));
        }
        return layers;
    }

    private static String[] toPackages(String base, List<String> subs) {
        return subs.stream().map(s -> base + "." + s.trim() + "..").toArray(String[]::new);
    }
}
