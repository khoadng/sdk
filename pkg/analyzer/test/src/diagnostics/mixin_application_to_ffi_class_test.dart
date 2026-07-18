// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dart/resolution/context_collection_resolution.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MixinApplicationToFfiClassTest);
  });
}

@reflectiveTest
class MixinApplicationToFfiClassTest extends PubPackageResolutionTest {
  test_abiSpecificInteger() async {
    await resolveTestCodeWithDiagnostics(r'''
import 'dart:ffi';

base mixin M on AbiSpecificInteger {}

@AbiSpecificIntegerMapping({})
final class C extends AbiSpecificInteger with M {
//                                            ^
// [diag.mixinApplicationToFfiClass] The class 'C' can't mix in 'M' because subclasses of 'AbiSpecificInteger' must extend 'AbiSpecificInteger' directly.
  const C();
}
''');
  }

  test_opaque() async {
    await resolveTestCodeWithDiagnostics(r'''
import 'dart:ffi';

base mixin M on Opaque {}

final class C extends Opaque with M {}
//                                ^
// [diag.mixinApplicationToFfiClass] The class 'C' can't mix in 'M' because subclasses of 'Opaque' must extend 'Opaque' directly.
''');
  }

  test_struct() async {
    await resolveTestCodeWithDiagnostics(r'''
import 'dart:ffi';

base mixin HeaderFields on Struct {
  @Int32()
  external int fieldA;

  external Pointer<Void> fieldB;
}

final class ExampleStruct extends Struct with HeaderFields {
//                                            ^^^^^^^^^^^^
// [diag.mixinApplicationToFfiClass] The class 'ExampleStruct' can't mix in 'HeaderFields' because subclasses of 'Struct' must extend 'Struct' directly.
  @Uint32()
  external int fieldC;
}
''');
  }

  test_union() async {
    await resolveTestCodeWithDiagnostics(r'''
import 'dart:ffi';

base mixin M on Union {}

final class C extends Union with M {
//                               ^
// [diag.mixinApplicationToFfiClass] The class 'C' can't mix in 'M' because subclasses of 'Union' must extend 'Union' directly.
  external Pointer<Void> field;
}
''');
  }
}
