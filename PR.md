# Suggested title

`[cfe] Inline list literal spreads in non-const list and set literals`

## Description

This changes CFE collection lowering so a type-compatible list literal used as
a spread in a non-const list or set literal is lowered directly into the
destination collection.

For an initial spread, the list literal's expressions are used to initialize
the destination. For later or conditional spreads, each expression is lowered
as an individual add. This avoids constructing an intermediate list and then
iterating it through `addAll`. A null-aware list-literal spread uses the same
path because the literal itself cannot be null.

When the destination is a set, all expressions are first evaluated into
temporaries before any elements are added. This preserves the source ordering:
user-defined `hashCode` and `==` calls cannot be interleaved with evaluation of
later list-literal expressions.

The existing checked-iteration path remains in place when the inferred element
type is not compatible with the destination type. Set-literal spreads,
map-literal spreads, and set spreads into lists are intentionally unchanged.

This addresses the list-literal portion of #62226 and overlaps the older
request in #37483.

## Tests

The new CFE testcase covers initial, conditional, and null-aware list-literal
spreads into lists, list-literal spreads into sets, and the retained fallback
paths. Existing CFE expectations were updated for the new lowering.

A dart2js codegen regression test compiles list and set cases and checks that
their generated methods do not contain `addAll`.

A language-level regression test verifies the evaluation ordering for initial
and conditional list-literal spreads into sets. It has been compiled and run as
VM AOT, dart2js (`-O1` and `-O4`), and dart2wasm output.

## Questions and follow-ups for team discussion

### Set-literal and map-literal spreads

These remain out of scope for this patch. Constructing the inner set or map can
perform duplicate elimination and invoke user-defined `hashCode`/`==` before
the outer collection is updated. Flattening those literals may therefore be
observable. Extending #62226 to those cases needs agreement on the permitted
semantics or a lowering that preserves them.

### Large literal spreads

Inlining removes an allocation and iteration but also emits one operation per
element, which can increase Kernel and generated-code size for large literals.
This patch has no size threshold. Focused measurements show the crossover is
backend-dependent: at 64 elements the direct form was larger in AOT Kernel,
dart2wasm, and dart2js `-O1`, while remaining smaller in dart2js `-O4`. A
threshold, if needed, therefore needs broader measurements and agreement about
whether the decision belongs in CFE or in each backend.

### Collection spread representation

This recognizes the existing Kernel encoding in CFE lowering. A dedicated
Kernel representation for collection spreads could make later optimization
decisions available to each backend, but that is a substantially broader
design change and is not attempted here.

---

- [ ] I've reviewed the contributor guide and applied the relevant portions to
      this PR.
