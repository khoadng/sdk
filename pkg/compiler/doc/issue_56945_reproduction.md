# Issue 56945 reproduction notes

Issue: https://github.com/dart-lang/sdk/issues/56945

## Current status

The original array-store workload no longer produces large
`DominatedUses.of` queries. The receiver-not-null strengthening call site that
triggered those queries was removed by `0bb3adb704d` in April 2025.

The same repeated large-query behavior is still reachable through late-field
optimization. Reading N distinct late fields from one receiver produces about
2N large `DominatedUses` queries, each of which scans about N receiver uses.
The two groups of queries come from the two SSA optimization passes at `-O4`.

## Reproduction

Generate equivalent late-field and ordinary-field inputs:

```sh
dart pkg/compiler/tool/issue_56945_repro.dart \
  late-fields 1200 /tmp/issue_56945_late.dart
dart pkg/compiler/tool/issue_56945_repro.dart \
  plain-fields 1200 /tmp/issue_56945_plain.dart
```

Compile both inputs with dart2js at `-O4`. Run each case several times in a
fresh process and compare medians.

## Measurements

Uninstrumented wall-clock medians:

| Fields | Late fields | Plain fields |
| ---: | ---: | ---: |
| 200 | 1.36 s | 1.04 s |
| 400 | 1.56 s | 1.05 s |
| 800 | 2.21 s | 1.30 s |
| 1200 | 3.25 s | 1.49 s |

Temporary counters around `DominatedUses._compute` produced:

| Fields | Large queries | Source uses examined | `_compute` time |
| ---: | ---: | ---: | ---: |
| 100 | 200 | 28,348 | 11.6 ms |
| 200 | 400 | 88,948 | 31.3 ms |
| 400 | 800 | 330,148 | 78.6 ms |
| 800 | 1600 | 1,292,548 | 293.0 ms |
| 1200 | 2400 | 2,894,948 | 655.9 ms |

The examined-use count grows quadratically. The equivalent plain-field input
does not produce the large queries.

These measurements used SDK revision
`1bbaacba6a5afcfe03b81a6a2244272b7e09731c`, matching the available bootstrap
SDK. The `DominatedUses` implementation, its late-field call sites, and
`Setlet` are unchanged between that revision and `origin/main` at
`6d09d2c05dc54ca0ada663c01612cd009b8bfba4`.

## Design boundary

Reducing allocations or replacing the `seen` and `users` sets inside
`DominatedUses._compute` can reduce the cost of each query, but it does not
remove the quadratic behavior demonstrated here.

Removing that behavior requires the late-field optimizer to avoid rescanning
all uses of the same receiver for every distinct field. Any implementation must
continue to handle repeated inputs, instruction order within the dominator's
block, and partially dominated phi inputs.
