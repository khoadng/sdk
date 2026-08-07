// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:expect/expect.dart';

abstract class Callable {
  Future<int> call(int value);
}

class RequiredCall implements Callable {
  @override
  Future<int> call(int value) async => value;
}

class OptionalCallOne implements Callable {
  @override
  Future<int> call([int value = 1]) async => value;
}

class OptionalCallTwo implements Callable {
  @override
  Future<int> call([int value = 2]) async => value;
}

Callable select(int value) => switch (value) {
  0 => RequiredCall(),
  1 => OptionalCallOne(),
  _ => OptionalCallTwo(),
};

Future<void> main(List<String> arguments) async {
  final callable = select(arguments.length);
  Expect.equals(42, await callable(42));
  if (callable is RequiredCall) {
    Expect.throwsNoSuchMethodError(() => (callable as dynamic)());
  } else {
    final expected = callable is OptionalCallOne ? 1 : 2;
    Expect.equals(expected, await (callable as dynamic)());
  }
}
