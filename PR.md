# Suggested title

`[dart2wasm] Handle required parameters in shared selectors`

## Description

Fixes #60583.

When a selector combines a required parameter with optional implementations
that have different defaults, its merged parameter information uses the
default-value sentinel. Parameter setup previously attempted to replace that
sentinel for every implementation, including the required implementation. The
required parameter has no default value, so compilation failed with a null
check error while generating its entry code.

Only replace the sentinel for optional parameters. Required implementations
continue to use supplied arguments, while dynamic invocations that omit the
required argument follow the existing `NoSuchMethodError` path.

## Tests

Add dart2wasm regression tests for named and positional parameters. Each has
one required implementation and two optional implementations with different
defaults, and covers an explicit required argument, omitted optional arguments,
and omission of the required argument. The async implementations also exercise
the state-machine codegen path from the reported failure.

The regression tests pass in the dart2wasm Chrome test configuration when
compiled from source. The related regressions for #62273 and #63904 also
continue to pass.

---

- [ ] I've reviewed the contributor guide and applied the relevant portions to
      this PR.
