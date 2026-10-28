---
name: code-audit
description: Audit the current code for bugs, security issues, performance problems, and code smells, in the backend and in the frontend. Run the real linters and static analyzers of each language in the repo (ESLint, tsc, SpotBugs, PMD, Checkstyle, Ruff, Bandit, Semgrep, gitleaks, npm audit, cargo clippy, golangci-lint, shellcheck, and others), add a manual review pass, rank every finding P0 to P3 (domain model errors first, then application errors), check the architecture with ArchUnit, and write a Markdown report with one table each for backend, security, frontend, performance, and architecture. Use this whenever the user runs /code-audit, or asks to audit, health-check, lint, scan, or "find what is wrong with" a codebase, wants a list of bugs, vulnerabilities, technical debt, or code smells ranked by priority, or wants a quality or security report before a release, a handover, an interview, or a code review — even if they do not name a linter or the word "audit".
argument-hint: "[target-dir] [report-path]"
---

# Code audit

Find bugs, security issues, performance problems, and code smells in
the backend and in the frontend of a codebase. Rank them by priority.
Write one Markdown report that a developer can work through from the
top.

Linters give you breadth and evidence. Your own reading gives you the
issues that linters cannot see: a broken business rule, a missing
authorization check, a race condition. The report needs both.

## Arguments

- `target-dir` — the directory to audit. Default: the current working
  directory (the repo root when you are in a git repo).
- `report-path` — where to write the report. Default:
  `<target-dir>/code-audit-report.md`.

## Ground rules

These rules exist because an audit must not change the thing it measures.

- **Do not change project files.** Do not edit `pom.xml`,
  `package.json`, lock files, or lint configs to make a tool run. Call
  Maven plugins by their full coordinates. Put temporary linter configs
  and raw output in a scratch directory (the session scratchpad, or
  `mktemp -d`). The only file you write in the project is the report.
- **Do not install tools globally.** Use run-once launchers: `npx --yes`,
  `uvx`, `mvn <groupId>:<artifactId>:<version>:<goal>`, or `docker run`.
- **Use stable releases.** Pin an exact stable version of each tool. Do
  not use a beta, an RC, or a nightly build. A project pin
  (`.nvmrc`, `.tool-versions`, `engines`) wins over your choice.
- **Prefer the project config.** When the repo has an `.eslintrc*`,
  `eslint.config.*`, `ruff.toml`, `checkstyle.xml`, and so on, use it.
  Use the fallback config in `references/linters.md` only when the repo
  has none, and say so in the report.
- **A failed tool is a finding about the audit, not a reason to stop.**
  When a tool does not run (no network, build fails, missing JDK), log
  the command and the error in the report "Tool coverage" table, and
  continue with the other tools.
- **Ignore generated and vendored code**: `node_modules`, `dist`,
  `build`, `target`, `.venv`, `vendor`, generated sources, minified files.

## Workflow

Track these steps in your todo list.

### 1. Detect the stack

```bash
python3 ~/.claude/skills/code-audit/scripts/detect_stack.py <target-dir>
```

The script prints JSON: the languages, the build files, the existing
lint configs, and which tools are on the PATH. Read it before you choose
tools. Also read the README and any `docs/` file, because they tell you
what the code is supposed to do. A bug is often a gap between the docs
and the code.

### 2. Run the linters

Read `references/linters.md`. It lists, for each language, the commands
to run, the flags for machine-readable output, and the fallback configs.
Run at least these categories for each language that is present:

| Category | Why |
|---|---|
| Compiler or type checker | Real errors that block a build |
| Bug-pattern analyzer | Null dereference, resource leaks, wrong equality |
| Style and smell linter | Complexity, dead code, duplication |
| Security scanner (SAST) | Injection, unsafe deserialization, weak crypto |
| Dependency audit (SCA) | Known CVEs in third-party packages |
| Secret scanner | Keys and passwords in the code or in git history |
| Performance check | Bundle size, costly patterns, N+1 queries |
| Architecture check | Layer rules, dependency direction, package cycles (ArchUnit for JVM code) |

Run these categories for the frontend too. When the repo has a
`frontend/`, `web/`, `client/`, `ui/`, or any other folder with a
`package.json`, run the TypeScript / JavaScript tools in that folder. A
frontend with no tool run is a gap: list it in "Tool coverage".

Run independent tools in parallel. Save each raw output to the scratch
directory. Give each tool a timeout (5 minutes for a build-based tool).
When a JVM tool needs compiled classes, run `mvn -q -DskipTests compile`
or `gradle classes` first.

### 3. Review the code yourself

Review the layers in this order. The domain model is the most important
part of the code, so review it first and review it most carefully.

1. **Domain model** — entities, value objects, domain services, and
   business rules (pricing, totals, discounts, state transitions).
2. **Application** — services and use cases, controllers or handlers,
   data access, configuration, error handling, and the wiring between
   them.
3. **Frontend** — every UI package in the repo (React, Vue, Angular,
   Svelte, plain JS, templates). Scan it always, also when the backend
   is the main part of the repo.

Look for what a linter cannot find:

- **Domain model errors**: wrong arithmetic or rounding, money as a
  float, off-by-one, wrong date or range boundary, a broken invariant,
  wrong equality, a value object that is mutable, a business rule that
  differs from the docs, the tickets, or the tests.
- **Application errors**: an unhandled null or empty case, swallowed
  exceptions, wrong HTTP status codes, missing input validation that
  lets bad data reach the model, a transaction boundary in the wrong
  place, wrong mapping between DTOs and the model, config that differs
  between environments.
- **Architecture**: read the architecture in the docs (layers,
  hexagonal ports and adapters, modules) and compare it with the
  ArchUnit result and with the code. Look for a domain that uses a
  framework, a use case that uses an adapter instead of a port, a
  controller that skips the application layer, an entity exposed in the
  API, and package cycles.
- **Frontend errors**: TypeScript types that do not match the API
  contract, money or totals calculated again in the UI, missing loading
  and error states, an unhandled rejected promise, stale state, wrong
  `useEffect` dependencies, a race between two requests, a form without
  validation, hard-coded API URLs, broken accessibility on a core flow.
- **Security**: missing input validation, missing authorization, data
  that a user controls in a query or a path or a shell command, CORS
  set to `*`, verbose errors that leak internals, secrets in config,
  debug endpoints or consoles (an H2 console, Actuator) open in prod.
  In the frontend, also look for `dangerouslySetInnerHTML`, `innerHTML`,
  `eval`, tokens in `localStorage`, secrets in `VITE_*` or
  `NEXT_PUBLIC_*` variables, and source maps shipped to production.
- **Concurrency and state**: shared mutable state, a non-atomic
  read-then-write, a cache without invalidation.
- **Performance**: N+1 queries, a query or a list without pagination
  or a limit, a missing index on a filtered column, blocking I/O on a
  request thread, work repeated in a loop that could run once, a large
  object built for each request, a missing cache on a hot read. In the
  frontend: needless re-renders, a missing memo on a costly calculation,
  a request for each keystroke without a debounce, a large bundle, a
  dependency imported whole when one function is used.
- **Code smells**: god classes, long methods, duplication, primitive
  obsession (money as `double`), magic numbers, dead code, tests that
  do not assert, missing tests for a core rule.

When you suspect a bug, prove it if this costs little: write a short test
or a one-off script in the scratch directory, run it, and quote the
result. A proved bug is worth more than a suspected one. Mark each
finding as **Confirmed** (you ran it or the tool proved it) or
**Suspected** (you read it but did not run it).

### 4. Merge, de-duplicate, and triage

- Merge the same issue reported by two tools into one finding. List
  both tools as the source.
- Drop false positives. When you drop a whole rule, say which rule and
  why in the "Noise and false positives" section, so a reader can
  trust the rest.
- Group many hits of one style rule (for example, 140 missing Javadoc
  comments) into one P3 finding with a count. Do not list each hit.
- Give each finding a priority with the rubric below.
- Put each finding in exactly one section, with this rule:
  1. A security issue goes to **Security**, also when it is in the
     frontend or in a dependency.
  2. A performance problem goes to **Performance**, backend or frontend.
  3. A break of a layer or dependency rule goes to **Architecture**.
     One ArchUnit rule that fails gives one finding, with the count of
     violations and the main locations.
  4. Any other finding in the frontend goes to **Frontend**.
  5. Any other finding goes to **Backend**.
- In the Backend table, put all domain model errors first, then all
  application errors, then backend smells. Sort by priority inside each
  group. A P2 model error comes before a P0 application error in the
  table. The "Fix first" list uses priority only, and when two findings
  have the same priority, the model error comes first.
- In the Frontend table, use the same order: errors in the client model
  (types, API contract, totals, data mapping) first, then UI and
  application errors, then smells.

### 5. Write the report

Use the template in `references/report-template.md`. The report has
five finding tables, in this order: Backend, Security, Frontend,
Performance, Architecture. Write it to the report path. Then give the user the path,
the count for each priority in each section, and the top three findings
in a few lines.

## Priority rubric

Rank by impact first, then by how likely the issue is to happen.

| Priority | Meaning | Examples |
|---|---|---|
| **P0 — Critical** | Fix now. Exploitable security issue, data loss or corruption, wrong money or totals in a common path, a build that does not compile. | SQL injection, hard-coded production secret, a dependency with a known RCE, wrong price for every cart |
| **P1 — High** | Fix before the next release. A real bug in a plausible path, a security weakness that needs one extra step, a crash on valid input. | Unhandled null on an optional field, missing auth on one endpoint, a dependency with a high CVE, rounding error on some inputs |
| **P2 — Medium** | Plan it. Bugs in rare edge cases, a smell that makes the next bug likely, missing tests for a core rule. | `double` for money, a 300-line method, a swallowed exception, permissive CORS in dev config |
| **P3 — Low** | Clean up when you touch the file. Style, naming, minor duplication, dead code, documentation gaps. | Unused imports, magic numbers, inconsistent naming |

Architecture findings: **P1** when the domain uses an outer layer or a
framework, or when packages have a cycle. **P2** when a use case uses an
adapter, a controller skips the application layer, or the API exposes
an entity. **P3** for the ArchUnit general coding rules.

Raise a priority by one level when the code sits on a hot path or
handles money, auth, or personal data. Lower it by one level when the
code is test-only, a prototype, or dead.

## Finding format

Give each finding a stable ID so the user can refer to it in a ticket:

| Prefix | Section | Use for |
|---|---|---|
| `MODEL-` | Backend | Domain model errors |
| `APP-` | Backend | Application errors |
| `SMELL-` | Backend | Backend code smells |
| `SEC-` | Security | Security issues, backend, frontend, or dependency |
| `FE-` | Frontend | Frontend errors and smells |
| `PERF-` | Performance | Performance problems, backend or frontend |
| `ARCH-` | Architecture | Breaks of the layer and dependency rules |

Each finding has: the priority, the section, the layer (Model,
Application, Frontend), the location as `path:line`, the source (tool and rule ID, or
"manual review"), the status (Confirmed or Suspected), what is wrong,
why it matters, and a concrete fix. Keep the code excerpt short — five
lines or fewer.
