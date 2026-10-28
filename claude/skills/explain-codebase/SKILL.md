---
name: explain-codebase
description: Scan a directory and all its subdirectories, then write three files that explain the code — architecture.mmd (a Mermaid diagram of how the components interact), ARCHITECTURE.md (structure, layers, flows, data, interfaces, risks) and BUSINESS_LOGIC.md (the domain rules in plain language, with worked examples and the places where the code disagrees with the docs). When the code uses DDD or has a real domain model, it also writes domain-model.mmd, a Mermaid class diagram of the aggregates, entities, value objects, services, repositories and events. Use this whenever the user asks to explain, document, map, onboard onto, reverse-engineer, or "understand how this code works", wants an architecture diagram or a Mermaid diagram of a project, wants a write-up of the business rules of an app, wants the DDD or domain model of a project drawn, or is preparing for a technical interview, code review, handover, or audit of an unfamiliar repository — even if they do not say "skill" or name the files.
argument-hint: "[target-dir] [output-dir]"
---

# Explain a codebase

Produce three files, plus a fourth when the code has a domain model, that
let a newcomer understand a project without reading its source first:

| File | Audience | Answers |
|---|---|---|
| `architecture.mmd` | Everyone | What are the parts, and who calls whom? |
| `ARCHITECTURE.md` | Developers | How is it built, how does a request travel, where are the structural risks? |
| `BUSINESS_LOGIC.md` | Product, new devs, reviewers | What rules does the software enforce, with real numbers, and where does the code break them? |
| `domain-model.mmd` *(only when there is a domain model)* | Developers, architects | What are the aggregates, entities, and value objects, and how do they relate? |

## Arguments

`$ARGUMENTS` holds up to two paths:

1. **Target directory** to scan. Default: the current working directory.
2. **Output directory**. Default: `<target>/docs/`.

If the output directory already holds files with these names, read them
first. Then update them instead of blindly replacing them, and tell the user
what changed. Do not commit anything unless the user asks.

## Workflow

### 1. Take inventory (about 1 minute)

Run the bundled script. It respects `.gitignore` and skips vendored and
build folders:

```bash
python3 -I <skill-dir>/scripts/inventory.py <target-dir>
```

It prints languages, line counts, top-level folders, manifests, docs,
likely entry points, tests, and a **size class** that decides step 2.

### 2. Read the code

Read in this order, because each step frames the next:

1. **Docs and tickets** (README, ADRs, ticket files). They state the
   intended behaviour. You will later compare the code against them.
2. **Manifests and config** (`package.json`, `pom.xml`, `pyproject.toml`,
   `application.properties`, docker files, proxy config). They give the
   stack, versions, ports, databases, and how the parts connect.
3. **Entry points**, then follow the calls inwards: controllers/routes →
   services/use cases → domain → persistence.
4. **Seed data and fixtures.** They show realistic inputs.
5. **Tests.** They show what the authors believe the behaviour is, and the
   gaps show what nobody checked.

How much to read depends on the size class:

- **SMALL**: read every source file yourself. The full picture is cheap
  and makes the business-logic file far more accurate.
- **MEDIUM**: read everything in steps 1–4 fully. Skim the rest with
  `grep` for the names you already found.
- **LARGE**: read docs, manifests, and top-level entry points yourself.
  Then give each top-level module to an `Explore` agent. Ask it for that
  module's responsibilities, public interface, outgoing calls, data
  stores, and business rules with `file:line`. Keep only the conclusions.
  Read the core domain module yourself anyway — the business logic file
  depends on precise detail that summaries lose.

While reading, also decide whether the code has a **domain model**. Look
for any of these signals:

- DDD vocabulary in package, folder, or class names: `domain`, `model`,
  `aggregate`, `entity`, `valueobject`, `vo`, `event`, `boundedcontext`,
  `Repository` interfaces, `DomainService`, `Specification`, `Policy`.
- Value objects: small immutable types that validate themselves (records,
  frozen dataclasses, `Money`, `Email`, `Sku`) instead of raw primitives.
- Entities with identity and behaviour, ORM entities, or schema classes
  that carry business rules.
- Domain events, factories, or a clear aggregate boundary (one root that
  owns child objects and enforces their invariants).

Two or more signals, or one strong signal such as explicit aggregates or a
`domain` package, mean you write `domain-model.mmd`. A plain CRUD app whose
"models" are only DTOs or table mappings gets no domain diagram. Say in
one line of `ARCHITECTURE.md` that there is no domain model, and why.

While reading, keep notes on four lists. They feed the outputs directly:
components and their edges, flows, business rules (with `file:line`), and
**discrepancies** — places where code, docs, tests, names, and the
frontend disagree with each other.

### 3. Check the numbers you will publish

The business-logic file includes worked examples. Readers trust them, so
compute them; do not do them in your head. Reproduce the exact arithmetic
of the code. If the code uses `double`, floats, or a specific rounding mode,
replicate that. For example, run a one-line `python3 -c` with the same
float math, or run the project's own test runner on a scratch test. Small
precision and rounding differences are often the most valuable finding in
the whole report.

Also evaluate date-bound data (promotions, licences, feature flags) against
today's date, and check boundary conditions (`<` vs `<=`, `isAfter` vs
inclusive) against what the docs say.

### 4. Write the output files

Write the three standard files, and `domain-model.mmd` when step 2 found a
domain model. Read `references/templates.md` and follow its structure for
each file. It
also has a Mermaid syntax checklist. Mermaid breaks silently on unquoted
parentheses and reserved words, so go through the checklist before you
finish.

Guidelines that make the difference between a useful report and a
generic one:

- **Use the project's own names** for modules, classes, endpoints, and
  domain terms. Keep the original language of domain terms (for example
  Spanish product names) and translate them in the glossary.
- **Cite `file:line`** for every rule and every discrepancy, so the reader
  can verify the claim in one click.
- **Separate what the code does from what it should do.** Describe actual
  behaviour in the main sections. Collect the gaps in the "disagrees"
  and "risks" tables, ordered by business impact.
- **Embed the diagrams** in the Markdown files too (```mermaid blocks), so
  they render on GitHub and in IDE previews. `architecture.mmd` goes in
  `ARCHITECTURE.md`. `domain-model.mmd` goes in the "Domain model" section
  of `BUSINESS_LOGIC.md`. Keep each `.mmd` file identical to its embedded
  copy.
- **Draw the domain model the code actually has**, not an ideal DDD
  model. If an "entity" is anemic, if a value object is mutable, or if the
  domain imports the ORM or framework, show that in the diagram and list it
  in the risks table. Those gaps tell the reader more than the stereotypes
  do.
- **Write the prose in the language the user wrote their request in**,
  unless they ask otherwise. Follow any writing-style rules the user
  already has in place.

### 5. Validate

1. If `mmdc` (mermaid-cli) is on the PATH, render each diagram to a
   scratch SVG. Fix any error. If it is not installed, check the
   checklist by eye instead. Do not install packages just for this.
2. Re-read every worked example and check that the totals add up.
3. Check that every `file:line` you cite exists.

### 6. Report back

Tell the user, briefly:

1. The paths of the output files, and whether you wrote a domain model
   diagram (and why or why not).
2. A short plain-language summary of what the application does and its
   main business rules (5–8 lines).
3. The top 3–5 discrepancies or risks, each with its location.
4. Anything you could not determine from the code, as open questions.

Keep the full detail in the files. The chat message is the index, not the
report.
