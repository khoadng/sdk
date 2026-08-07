// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Regression test for https://github.com/dart-lang/sdk/issues/62226.

bool spreadEvaluationComplete = false;

class Key {
  final int id;

  Key(this.id);

  @override
  int get hashCode {
    if (id != 0 && !spreadEvaluationComplete) {
      throw StateError('Key $id was added before the spread was evaluated');
    }
    return 0;
  }

  @override
  bool operator ==(Object other) {
    if (id != 0 && !spreadEvaluationComplete) {
      throw StateError('Key $id was compared before the spread was evaluated');
    }
    return other is Key && id == other.id;
  }
}

Key evaluate(int id, {bool last = false}) {
  if (last) spreadEvaluationComplete = true;
  return Key(id);
}

void testInitialSpread() {
  spreadEvaluationComplete = false;
  <Key>{
    ...<Key>[evaluate(1), evaluate(2, last: true)],
    Key(3),
  };
}

void testConditionalSpread() {
  spreadEvaluationComplete = false;
  <Key>{
    Key(0),
    if (true) ...<Key>[evaluate(1), evaluate(2, last: true)],
  };
}

void main() {
  testInitialSpread();
  testConditionalSpread();
}
