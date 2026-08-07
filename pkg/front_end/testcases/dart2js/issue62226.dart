// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

List<num> listLiteralSpread(bool include) => <num>[
  0,
  if (include) ...<int>[1, 2],
  3,
];

List<num> initialListLiteralSpread() => <num>[
  ...<int>[1, 2],
  3,
];

List<num> nullAwareListLiteralSpread() => <num>[
  0,
  // ignore: invalid_null_aware_operator
  ...?<int>[1, 2],
  3,
];

int value(int value) => value;

Set<num> listLiteralSpreadIntoSet(bool include) => <num>{
  0,
  if (include) ...<int>[value(1), value(2)],
  3,
};

Set<num> initialListLiteralSpreadIntoSet() => <num>{
  ...<int>[value(1), value(2)],
  3,
};

// A set literal spread must retain the inner set's equality behavior.
Set<num> setLiteralSpreadRetained(bool include) => <num>{
  0,
  if (include) ...<int>{1, 2},
  3,
};

Set<num> initialSetLiteralSpreadRetained() => <num>{
  ...<int>{1, 2},
  3,
};

// A map literal spread must retain the inner map's equality behavior.
Map<num, Object> mapLiteralSpreadRetained(bool include) => <num, Object>{
  0: 'zero',
  if (include) ...<int, String>{1: 'one', 2: 'two'},
  3: 'three',
};

Map<num, Object> initialMapLiteralSpreadRetained() => <num, Object>{
  ...<int, String>{1: 'one', 2: 'two'},
  3: 'three',
};

// A set spread into a list must retain the set's duplicate elimination.
List<int> setIntoList() => <int>[
  ...<int>{1, 2},
];

// A dynamically typed literal must retain the checked iteration path.
List<int> checkedListLiteralSpread() => <int>[
  ...<dynamic>[1, 2],
];

void main() {}
