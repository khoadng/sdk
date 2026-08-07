# Suggested title

`[analyzer] Avoid duplicate fragments for duplicate part directives`

## Description

Fixes #63010.

A library containing multiple `part` directives that resolve to the same file
could produce multiple library fragments for that file. A later
`getUnitElement` request expected exactly one fragment for the requested URI
and failed with `Bad state: Too many elements` in
`LibraryContext.computeUnitElement`.

Keep every part directive in the element model so that `DUPLICATE_PART` can
still be reported, but create only one library fragment for each resolved part
file. Duplicate directives resolve to the source without introducing another
fragment.

## Tests

Add regression coverage for unit-element lookup with duplicate part
directives. Add element-model coverage showing that equivalent part URIs keep
both directives but produce one fragment, both while linking and after reading
the element model from bytes.

Existing duplicate-part diagnostic and cached-diagnostic tests continue to
pass.

---

- [ ] I've reviewed the contributor guide and applied the relevant portions to
      this PR.
