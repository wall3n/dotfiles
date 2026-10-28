# Report template

Fill in every section. When a section has nothing in it, write "None
found" and keep the heading, so the reader knows you checked.

The report has five finding tables, in this order: Backend, Security,
Frontend, Performance, Architecture. Each finding is in exactly one table. The
"Finding details" section then gives the full text of each P0 to P2
finding, in the same order as the tables.

~~~markdown
# Code audit — <project name>

| | |
|---|---|
| Date | <YYYY-MM-DD> |
| Commit | `<git rev-parse --short HEAD>` (<branch>, <clean / N uncommitted files>) |
| Scope | <backend dir, languages>, <frontend dir, languages> |
| Auditor | Claude Code, `/code-audit` skill |

## Summary

| Priority | Backend (model) | Backend (app) | Security | Frontend | Performance | Architecture | Total |
|---|---|---|---|---|---|---|---|
| P0 Critical | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| P1 High | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| P2 Medium | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| P3 Low | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

Count backend smells in the "Backend (app)" column.

<Three to five sentences: the overall state of the code, the most
important risk, and what to fix first.>

### Fix first

Sorted by priority. With the same priority, a model error comes first.

1. **<ID>** — <one line>
2. **<ID>** — <one line>
3. **<ID>** — <one line>

## 1. Backend

Domain model errors first, then application errors, then smells. Sorted
by priority inside each group.

| ID | Priority | Layer | Title | Location | Status | Fix |
|---|---|---|---|---|---|---|
| MODEL-001 | P0 | Model | <short title> | `path/File.java:42` | Confirmed | <one line> |
| MODEL-002 | P2 | Model | ... | ... | ... | ... |
| APP-001 | P0 | Application | ... | ... | ... | ... |
| SMELL-001 | P3 | Application | ... | ... | ... | ... |

## 2. Security

Backend, frontend, configuration, secrets, and dependencies. Sorted by
priority.

| ID | Priority | Area | Title | Location | Status | Fix |
|---|---|---|---|---|---|---|
| SEC-001 | P0 | Backend | <short title> | `path/File.java:42` | Confirmed | <one line> |
| SEC-002 | P1 | Dependency | <package> <version>, <CVE> | `package-lock.json` | Confirmed | Upgrade to <version> |

## 3. Frontend

Client model errors first (types, API contract, totals, data mapping),
then UI and application errors, then smells.

| ID | Priority | Layer | Title | Location | Status | Fix |
|---|---|---|---|---|---|---|
| FE-001 | P1 | Client model | <short title> | `src/api.ts:12` | Confirmed | <one line> |

## 4. Performance

Backend and frontend. Sorted by priority.

| ID | Priority | Area | Title | Location | Status | Fix |
|---|---|---|---|---|---|---|
| PERF-001 | P2 | Backend | <short title> | `path/Repo.java:20` | Suspected | <one line> |

## 5. Architecture

Checked with ArchUnit (`ArchCheck.java`, plus the project ArchUnit tests
when they exist). Give the layers that the check used, and the rules
that passed, so the reader knows what was checked.

Layers used: `<LAYERS line from the ArchUnit output>`

| ID | Priority | Rule | Violations | Main locations | Documented | Fix |
|---|---|---|---|---|---|---|
| ARCH-001 | P1 | `ARCH-domain-framework-free` | 6 | `domain/PricingRule.java` (JPA) | Yes, ARCHITECTURE.md 3.1 | Move the JPA mapping to a persistence entity |

Rules that passed: <list>

## Finding details

One block for each P0, P1, and P2 finding, in the table order above.
P3 findings stay in the tables only.

#### MODEL-001 · <short title>

| | |
|---|---|
| Priority | P0 |
| Section | Backend / Security / Frontend / Performance / Architecture |
| Layer | Model / Application / Frontend |
| Location | `path/to/File.java:42` |
| Source | <tool> `<rule-id>` / manual review |
| Status | Confirmed / Suspected |

**What:** <the defect, in one or two sentences>

**Why it matters:** <the impact, with a concrete scenario: input → wrong
result>

**Fix:** <the concrete change>

```<lang>
<excerpt, five lines or fewer>
```

### Grouped style hits (P3)

Group repeated style hits into one row.

| ID | Section | Rule | Count | Example location | Fix |
|---|---|---|---|---|---|

## Tool coverage

| Area | Language | Tool | Version | Command | Result |
|---|---|---|---|---|---|
| Backend | Java | SpotBugs + FindSecBugs | 4.8.6.6 | `mvn ...` | 3 findings |
| Frontend | TypeScript | ESLint | 9.x | `npx ...` | Did not run: <error> |
| Backend | Java | ArchUnit (`ArchCheck.java`) | 1.4.1 | `java -cp ... ArchCheck.java ...` | 5 of 11 rules failed |
| Frontend | TypeScript | Vite build (bundle size) | 5.x | `npx vite build ...` | Largest chunk 180 kB |

Say which tools used the project config and which used the skill
fallback config.

## Noise and false positives

<The rules or hits you dropped, and why.>

## Not covered

<What this audit did not check: runtime behavior, infra, load tests, a
language with no available tool, and so on.>
~~~
