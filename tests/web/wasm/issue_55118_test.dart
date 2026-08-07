// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:expect/expect.dart';

// Regression test for https://github.com/dart-lang/sdk/issues/55118.
class BadFuture implements Future<String> {
  @override
  Future<R> then<R>(FutureOr<R> Function(String) onValue, {Function? onError}) {
    return Future<R>.value((onValue as FutureOr<R> Function(dynamic))(42));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> awaitFuture(Future<String> future) async {
  await future;
}

Future<void> awaitFutureOr(FutureOr<String> future) async {
  await future;
}

Future<void> expectTypeError(Future<void> future) async {
  try {
    await future;
    Expect.fail('Expected TypeError');
  } on TypeError {
    // Expected.
  }
}

Future<void> main() async {
  await expectTypeError(awaitFuture(BadFuture()));
  await expectTypeError(awaitFutureOr(BadFuture()));
}
