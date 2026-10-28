# Linter commands by language

Contents: conventions · all languages (secrets, SAST, dependencies) ·
Java / Kotlin (with ArchUnit) · TypeScript / JavaScript (frontend, bundle size) ·
performance patterns · Python · Go · Rust · Shell and
Docker · other languages · parsing the output

## Conventions

- `$S` is the scratch directory for this audit. Create it with
  `S=$(mktemp -d)` when the session has no scratchpad.
- `$C` is the tool cache: `C=~/.cache/code-audit`. Downloaded linters and
  fallback toolchains live here, outside the project, and are reused
  between audits.
- `$SKILL` is `~/.claude/skills/code-audit`.
- Exit codes: most linters exit non-zero when they find something. That
  is a result, not a failure. Treat the run as failed only when the
  output file is missing or empty, or the log shows a crash.
- The versions below are stable releases that ran on this machine. When
  you pick a newer version, pick a stable one, never a beta or RC.

## All languages

Run these on every audit.

### Secrets — gitleaks

```bash
gitleaks git --no-banner --redact -f json -r $S/gitleaks-git.json <target>   # history
gitleaks dir --no-banner --redact -f json -r $S/gitleaks-dir.json <target>   # working tree, includes untracked files
```

No gitleaks on the PATH: `docker run --rm -v <target>:/repo:ro -v $S:/out zricethezav/gitleaks:v8.21.2 dir /repo --redact -f json -r /out/gitleaks-dir.json`,
or skip it and grep for `password|secret|api[_-]?key|token|BEGIN .*PRIVATE KEY`
in config files. `--redact` keeps the secret value out of the report —
never paste a real secret into the report.

### SAST — Semgrep

```bash
uvx --python 3.13 --with 'setuptools<81' --from semgrep==1.99.0 \
  semgrep scan --config p/default --metrics=off --json -o $S/semgrep.json \
  --exclude node_modules --exclude target --exclude dist --exclude build <target>
```

`setuptools<81` is necessary because this Semgrep version imports
`pkg_resources`. `p/default` downloads the rules from the Semgrep
registry. With no network, skip Semgrep and say so in "Tool coverage".

### Dependencies — osv-scanner

One tool for every lock file (Maven, npm, pip, Go, Cargo, Gem, Composer).

```bash
[ -x $C/bin/osv-scanner ] || GOBIN=$C/bin go install github.com/google/osv-scanner/cmd/osv-scanner@v1.9.2
$C/bin/osv-scanner --format json --output $S/osv.json -r <target>
```

No Go: `docker run --rm -v <target>:/src ghcr.io/google/osv-scanner:v1.9.2 --format json -r /src`.
For each vulnerable package, give the installed version, the fixed
version, and the worst severity. A transitive dependency of a framework
(for example Tomcat inside Spring Boot) is usually fixed by a bump of
the framework, so say that in the fix.

## Java / Kotlin (Maven or Gradle)

Compile first. The bytecode tools need `target/classes`.

```bash
mvn -B -q -DskipTests compile > $S/compile.log 2>&1      # or: gradle classes -q
```

A compile error is a P0 finding. Report it and still run the source
tools (PMD, Checkstyle, Semgrep).

### SpotBugs + FindSecBugs (bugs and security, on bytecode)

```bash
mvn -B -q dependency:get -Dartifact=com.h3xstream.findsecbugs:findsecbugs-plugin:1.13.0
FSB=~/.m2/repository/com/h3xstream/findsecbugs/findsecbugs-plugin/1.13.0/findsecbugs-plugin-1.13.0.jar
mvn -B com.github.spotbugs:spotbugs-maven-plugin:4.8.6.6:spotbugs \
  -Dspotbugs.effort=Max -Dspotbugs.threshold=Low -Dspotbugs.xmlOutput=true \
  -Dspotbugs.pluginList=$FSB > $S/spotbugs.log 2>&1
```

Output: `target/spotbugsXml.xml` (one long line — parse it, do not
grep it). Check that `<Plugin id="com.h3xstream.findsecbugs">` is in the
file, which proves FindSecBugs loaded. In multi-module builds, run from
the root and collect the file from each module.

Noise: `EI_EXPOSE_REP`/`EI_EXPOSE_REP2` on JPA entities and DTOs, and
`SPRING_ENDPOINT` (it only lists endpoints). Use `SPRING_ENDPOINT` as an
inventory of the attack surface for the manual review, not as findings.

### PMD (bugs, smells, complexity, on source)

The Maven PMD plugin cannot take a ruleset on the command line without
a `pom.xml` change, so use the PMD CLI:

```bash
[ -d $C/pmd-bin-7.7.0 ] || (cd $C && curl -fsSL -o pmd.zip \
  https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.7.0/pmd-dist-7.7.0-bin.zip \
  && unzip -q pmd.zip && rm pmd.zip)
$C/pmd-bin-7.7.0/bin/pmd check --no-progress --no-cache -d src/main/java \
  -R <project ruleset, or $SKILL/assets/pmd-ruleset.xml> \
  -f json -r $S/pmd.json --aux-classpath target/classes
```

Exit code 4 means "violations found". Kotlin: PMD does not cover it —
use detekt (`gradle detekt` when the project has it).

### CPD (duplication)

```bash
$C/pmd-bin-7.7.0/bin/pmd cpd --minimum-tokens 100 -d src/main/java --language java -f xml > $S/cpd.xml
```

### ArchUnit (architecture rules, on bytecode)

When the project already has ArchUnit tests, run them first:
`mvn -B test -Dtest='*Arch*' -Dsurefire.failIfNoSpecifiedTests=false`.
Then always run the skill checker. It runs with the Java source
launcher, so the project needs no new test and no `pom.xml` change.

```bash
mvn -B -q dependency:get -Dartifact=com.tngtech.archunit:archunit:1.4.1
mvn -B -q dependency:get -Dartifact=org.slf4j:slf4j-api:2.0.17
M=$HOME/.m2/repository
AU="$M/com/tngtech/archunit/archunit/1.4.1/archunit-1.4.1.jar:$M/org/slf4j/slf4j-api/2.0.17/slf4j-api-2.0.17.jar"
java -cp "${AU}:target/classes" $SKILL/assets/ArchCheck.java \
  target/classes <base.package> [layers] > $S/archunit.txt 2>/dev/null
```

Write `${AU}` with braces. In zsh, `$AU:t` is a path modifier and
breaks the class path. `<base.package>` is the package of the
`@SpringBootApplication` class (or the root package of the module).

Without `[layers]`, the checker detects the layers by package name
(`domain`, `model`, `application`, `usecase`, `infrastructure`,
`adapter`, `rest`, `web`, `persistence`, `repository`). When the docs
describe other names, give the layers yourself, as sub-packages of the
base package:

```
"domain=core.model;application=core.service;web=adapter.in.web;persistence=adapter.out.db"
```

Read the `LAYERS` line first. A layer that is wrong or missing makes
the rules wrong. The output has one `PASS <rule>` or `FAIL <rule> (<n>)`
line for each rule, then the violations. Exit code 1 means "violations
found".

| Rule | Checks |
|---|---|
| `ARCH-domain-independent` | The domain does not use the application, web, or persistence layers |
| `ARCH-domain-framework-free` | The domain does not use Spring, JPA, Hibernate, Jackson, or the Servlet API |
| `ARCH-application-no-adapters` | Use cases do not use adapter classes. They use ports |
| `ARCH-application-no-web` | Use cases do not use Spring Web or the Servlet API |
| `ARCH-web-no-repository` | Controllers do not call repositories directly |
| `ARCH-web-no-entity` | Controllers do not take or return JPA entities |
| `ARCH-no-package-cycles` | No cycles between the top-level packages |
| `ARCH-no-field-injection`, `ARCH-no-standard-streams`, `ARCH-no-generic-exceptions`, `ARCH-no-java-util-logging` | ArchUnit `GeneralCodingRules` |

Compare the result with the architecture in the docs. When the docs
already list a break, the finding is still valid. Say in the finding
that the break is known and documented. When the code follows an
architecture that is different from the one in the docs, report this
as one finding of its own.

### Checkstyle (style and smells)

```bash
mvn -B org.apache.maven.plugins:maven-checkstyle-plugin:3.6.0:check \
  -Dcheckstyle.config.location=<project config, or google_checks.xml> \
  -Dcheckstyle.failOnViolation=false -Dcheckstyle.violationSeverity=error \
  -Dcheckstyle.consoleOutput=false > $S/checkstyle.log 2>&1
```

Output: `target/checkstyle-result.xml`. With `google_checks.xml` most
hits are indentation and Javadoc. Group them into one P3 row each. Look
in the remaining hits for real smells: `MethodLength`,
`ParameterNumber`, `CyclomaticComplexity`, `EmptyCatchBlock`.

Gradle: run the same tools through `gradle spotbugsMain pmdMain
checkstyleMain` only when the build already applies them. If not, use
the PMD CLI and Semgrep, and say that SpotBugs did not run.

## TypeScript / JavaScript

Run from the package directory (the one with `package.json`). Install
the project dependencies only when `node_modules` is missing and a lock
file exists: `npm ci --ignore-scripts` (or `pnpm i --frozen-lockfile
--ignore-scripts`). `--ignore-scripts` stops install hooks from running
untrusted code.

### Type check

```bash
npx --no-install tsc --noEmit -p . > $S/tsc.txt 2>&1
```

Each `error TS` line is a finding. A type error in shipped code is P1
or higher.

### ESLint

When the project has an ESLint config, run its own ESLint:
`npx --no-install eslint -f json -o $S/eslint.json .`

When it has none, use the pinned fallback toolchain (ESLint 9,
typescript-eslint, react-hooks, security):

```bash
E=$C/eslint; mkdir -p $E
cp $SKILL/assets/eslint.config.mjs $E/ && cp $SKILL/assets/eslint-package.json $E/package.json
[ -d $E/node_modules ] || npm install --prefix $E --no-audit --no-fund --loglevel=error
cd <package dir> && $E/node_modules/.bin/eslint -c $E/eslint.config.mjs -f json -o $S/eslint.json src
```

Run it from the package dir: ESLint ignores files outside the current
directory ("File ignored because outside of base path"). Check that the
JSON lists the files you expect. An empty array means nothing was
linted, which is different from "no findings".

### Dependency audit

```bash
npm audit --json > $S/npm-audit.json      # or: pnpm audit --json / yarn npm audit --json
```

Mark dev-only packages (Vite, test tools) one level lower than runtime
packages, unless the hole is in the dev server and the docs tell people
to expose it.

### Frontend build and bundle size (performance)

Build into the scratch directory, so the project `dist/` does not change:

```bash
npx --no-install vite build --outDir $S/fe-dist --emptyOutDir > $S/fe-build.log 2>&1   # Vite
du -k $S/fe-dist/assets/*.js | sort -n | tail -5
```

For other bundlers, run the project build script and read the size
report it prints. A JavaScript chunk over 500 kB (before gzip) is a P2
performance finding. Look in the chunk for a library imported whole
(`lodash`, `moment`, an icon set) and name it in the fix.

## Performance patterns (all languages)

No single tool finds performance problems, so grep for the usual
patterns, then read each hit:

```bash
grep -rnE 'findAll\(|\.stream\(\).*\.filter|for .*repository\.|FetchType\.EAGER|Thread\.sleep' <backend src>
grep -rnE 'useEffect\(|onChange=.*fetch|JSON\.parse\(JSON\.stringify|\.map\(.*\.map\(' <frontend src>
```

With Spring Data JPA, set `spring.jpa.show-sql=true` only in a scratch
run, never in the project config, to count the queries for one request.

## Python

```bash
uvx ruff@0.8.4 check --output-format json -o $S/ruff.json --select E,F,B,S,SIM,C90,PL,UP,RUF <target>
uvx bandit@1.8.0 -r <target> -f json -o $S/bandit.json -x ./.venv,./tests
uvx pip-audit@2.7.3 -r requirements.txt -f json -o $S/pip-audit.json    # or plain pip-audit in an active venv
uvx mypy@1.13.0 --ignore-missing-imports <package> > $S/mypy.txt        # only when the code has type hints
```

When the project has a `[tool.ruff]` section, drop `--select` and use it.

## Go

```bash
go vet ./... > $S/govet.txt 2>&1
GOBIN=$C/bin go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.62.2
$C/bin/golangci-lint run --out-format json ./... > $S/golangci.json
GOBIN=$C/bin go install golang.org/x/vuln/cmd/govulncheck@v1.1.3
$C/bin/govulncheck -json ./... > $S/govulncheck.json
```

`govulncheck` reports only the CVEs whose code is reachable, so rank its
hits above the osv-scanner hits for the same package.

## Rust

```bash
cargo +stable clippy --all-targets --message-format=json -- -W clippy::pedantic > $S/clippy.json
cargo install --locked --root $C cargo-audit@0.21.0 && $C/bin/cargo-audit audit --json > $S/cargo-audit.json
```

`clippy::pedantic` is noisy. Rank its hits P3 unless they point at a bug.

## Shell and Docker

```bash
docker run --rm -v <target>:/mnt koalaman/shellcheck:v0.10.0 -f json $(cd <target> && git ls-files '*.sh') > $S/shellcheck.json
docker run --rm -i hadolint/hadolint:v2.12.0 hadolint -f json - < Dockerfile > $S/hadolint.json
```

## Other languages

| Language | Tools |
|---|---|
| Ruby | `rubocop --format json`, `brakeman -f json` (Rails) |
| PHP | `vendor/bin/phpstan analyse --error-format=json`, `composer audit --format=json` |
| C# | `dotnet build -warnaserror-` and read the analyzer warnings, `dotnet list package --vulnerable` |
| C / C++ | `cppcheck --enable=all --xml`, `clang-tidy` with `compile_commands.json` |
| Terraform | `uvx checkov@3.2.334 -d <dir> -o json` |

When no tool is available for a language, review it by hand and say so
in "Not covered".

## Parsing the output

Do not read a large raw output into the context. Summarize it with a
short script first, then open only the hits that matter:

```bash
python3 - "$S/pmd.json" <<'EOF'
import json, sys, collections
d = json.load(open(sys.argv[1]))
hits = [(v["rule"], f["filename"], v["beginline"]) for f in d["files"] for v in f["violations"]]
print(collections.Counter(r for r, _, _ in hits).most_common())
EOF
```

Then read the source at each `path:line` that could be P0 to P2, and
confirm it before it goes into the report. A linter hit you did not
look at is a Suspected finding at best.
