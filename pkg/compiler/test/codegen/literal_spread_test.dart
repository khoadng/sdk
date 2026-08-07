// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:expect/async_helper.dart';
import 'package:expect/expect.dart';

import '../helpers/compiler_helper.dart';

const String source = r'''
@pragma('dart2js:noInline')
bool includeElements() => DateTime.now().millisecondsSinceEpoch.isEven;

@pragma('dart2js:noInline')
int value(int value) => value;

List<int> buildList() => <int>[
  value(1),
  if (includeElements()) ...<int>[value(2), value(3)],
  value(4),
];

Set<int> buildSet() => <int>{
  value(1),
  if (includeElements()) ...<int>[value(2), value(3)],
  value(4),
};
''';

void main() {
  asyncTest(() async {
    for (String entry in ['buildList', 'buildSet']) {
      await compile(
        source,
        entry: entry,
        disableTypeInference: false,
        check: (String generated) {
          Expect.isFalse(
            generated.contains('addAll'),
            'Literal spread in $entry allocated an intermediate collection:\n'
            '$generated',
          );
        },
      );
    }
  });
}
