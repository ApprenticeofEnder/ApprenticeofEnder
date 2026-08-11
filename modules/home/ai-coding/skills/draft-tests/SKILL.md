---
name: draft-tests
description: Write tests using 3 independent sub-agents. Use after every non-trivial function is written, as part of the test-writing pass.
---

# When to use

Apply this methodology to every non-trivial function AFTER the code is written, as part of the test-writing pass. These include:

- Public API functions
- Methods with documented contracts
- Functions with multiple branches or error paths
- Functions that handle untrusted input (I/O, wire format, external API calls, etc.)

## Exceptions

Trivial accessors, constructors with no branching, and functions
that delegate entirely to a tested sub-function do not need this
treatment.

# Usage

Each significant function or method should be analyzed by 3 independent subagents when generating tests. These agents are as follows:

| Subagent                 | Provides                                               | Used As Input For                     |
| ------------------------ | ------------------------------------------------------ | ------------------------------------- |
| @property-extraction     | A specification-coverage lens (what should hold)       | [Property testing](#property-testing) |
| @control-flow-extraction | An implementation-coverage lens (what paths exist)     | [Path testing](#path-testing)         |
| @adjacent-analysis       | An integration lens (how callers and callees interact) | [Contract testing](#contract-testing) |

For each agent, provide it with a `<file>:<line-range>` referencing a function -- **NOT the entire function or its name**. Use absolute paths to reference the file. Use the subagent's output to write tests accordingly.

# Writing tests

## Property testing

@property-extraction fuels property tests. Creating the tests depends on the tech stack used:

- Python: [hypothesis](https://hypothesis.readthedocs.io/en/latest/)
- Rust: [proptest](https://raw.githubusercontent.com/proptest-rs/proptest/refs/heads/main/proptest/README.md)
- JS/TS: [fast-check](https://fast-check.dev/docs/introduction/)

<!-- TODO: Add other property testing frameworks as necessary -->

## Path testing

@control-flow-extraction fuels named tests for each specific path -- especially error paths that property testing may not hit efficiently.

## Contract testing

@adjacent-analysis fuels contract tests that exercise the call chain with values that stress each interface. An example in Rust:

```rust
#[test]
fn zero_payload_len_rejected() {
    let data = [0, 0, 0, 0];
    let err = decode_message(&data).unwrap_err();
    assert!(matches!(err, ProtocolError::BufferTooShort { .. }));
}
```

# Test Coverage

**Target**: 90%

All code merged to main must maintain >=90% line and branch coverage, as measured according to its tech stack:

- Python: `coverage.py`
- Rust: `cargo-llvm-cov`
- JS/TS: `vitest`, `v8` by default, `istanbul` for Firefox, Bun, etc.

<!-- TODO: Make this section cross platform -->

Exceptions are noted with `// #[cfg(not(tarpaulin))]` or gated behind
feature flags and documented in the PR. Every exception requires a
justification in the review.

Control-flow-heavy code (wire parsers, protocol handlers, module
dispatch) must be measured separately with fuzz targets
(`cargo-fuzz`). Fuzz targets live in each crate's `fuzz/`
directory and are run for a minimum of 60 CPU-seconds per CI run.

# Rules of Engagement

- **DO NOT** inline the function code in prompts to subagents. `<file>:<line-range>` only.
- **DO** use absolute file paths in function references. `/home/ender/Projects/myproject/src/target.rs` is always more acceptable and correct than `src/target.rs`.
