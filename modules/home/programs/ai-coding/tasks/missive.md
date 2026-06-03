You are agent **<CALLSIGN>**. Scope: ONLY task <T-ID> below. Work in
`<repo-or-dir>`, module/package `<path>`.

<!-- ENV-SANITY (recommended first line for every brief): confirm you're in the right place
     before doing anything, so a misconfig surfaces in seconds. -->

First, confirm the env: run `pwd`; check the base contains `<expected-file-or-dir>`; probe a
Write and a Bash command. If the base is missing the expected files, STOP and report
`BASE MISSING`. If Write/Bash is blocked, STOP and report `PERMISSION BLOCKED`.

Read FIRST (binding): `<spec/design doc>`, `<files to import from — do NOT redefine these>`,
`<any local setup/README the task depends on>`.

# Task <T-ID> — <one-line title>

<One short paragraph: what to build/do and why. Name the contract it must satisfy.>

## Deliver (<target dir>)

- `<file>` — <what it does, key behavior, inputs/outputs>.
- `<file>` — <...>.
- <Config from env; provide a typed/validated loader with clear errors, if applicable.>

## Tests (<framework>, <where>)

- <Unit/integration cases to cover: happy path, boundaries, error paths, the specific edge
  cases that matter. State expected outcomes.>
- <Note anything tests must NOT require (e.g. live network, a running container) and how to
  point them at the real dependency when needed.>

## Constraints

- Add deps to `<module/package>` only; name them explicitly.
- Follow the repo's existing language/style/file-naming conventions.
- No secrets/PII in logs.
- Do NOT modify `<no-touch list: other packages, specs, docs, root config>`.
- No cloud / no deploys unless this brief says otherwise.

## Done criteria — run and confirm green

- `<install>` ok · `<build/compile>` pass · `<tests>` pass · `<lint>` pass
  Print the test output and any env vars / ports / config ids the deliverable needs. Report
  deviations.
