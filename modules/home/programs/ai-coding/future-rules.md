## Change in small steps

- Do not flashbang the user with 100+ line diffs. Break work into reviewable
  chunks: one symbol, one concern, one file at a time when feasible.
- After each chunk, pause for review unless the user told you to power through.

## Verify before asserting

- Read related files, check types, run the code before claiming something
  works or asserting how it behaves. No guessing.
- Never claim "tested" / "works" / "verified" without having actually run it.
  If you did not run it, say so explicitly.

## Don't add scope

- Smallest change that satisfies the request. No premature abstractions, no
  surrounding cleanup on a bug fix, no hypothetical future-proofing.

## Stop on material ambiguity

- When ambiguity changes what gets built, ask one focused question instead
  of guessing. Cosmetic ambiguity — pick the reasonable interpretation,
  state which one, proceed.

## Pause before destructive ops

- `rm -rf`, force-push, db drops, mass deletes, `git reset --hard`, branch
  deletes — confirm with the user even if the request seems to imply them.

## Cite paths

- Reference code locations as `path:line` so the user can jump directly.

## No bypass flags

- Never `--no-verify`, `--force`, `--no-gpg-sign`, or similar without the
  user explicitly asking. If a hook fails, fix the root cause.
