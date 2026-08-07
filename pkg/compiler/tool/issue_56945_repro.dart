// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 3) {
    stderr.writeln(
      'usage: issue_56945_repro.dart '
      '<array-stores|late-fields|plain-fields> <size> <output>',
    );
    exitCode = 64;
    return;
  }

  final mode = arguments[0];
  final size = int.parse(arguments[1]);
  final output = File(arguments[2]).openWrite();

  switch (mode) {
    case 'array-stores':
      output.writeln("@pragma('dart2js:noInline')");
      output.writeln('void workload(dynamic values) {');
      for (var index = 0; index < size; index++) {
        output.writeln('  values[$index] = $index;');
      }
      output.writeln('}');
      output.writeln();
      output.writeln('void main() {');
      output.writeln('  workload(List<int>.filled($size, 0));');
      output.writeln('}');

    case 'late-fields':
    case 'plain-fields':
      final isLate = mode == 'late-fields';
      output.writeln('class Box {');
      for (var index = 0; index < size; index++) {
        output.writeln(
          isLate ? '  late int field$index;' : '  int field$index = 0;',
        );
      }
      output.writeln('}');
      output.writeln();
      output.writeln("@pragma('dart2js:noInline')");
      output.writeln('Box createBox(bool initialize) {');
      output.writeln('  final box = Box();');
      output.writeln('  if (initialize) {');
      for (var index = 0; index < size; index++) {
        output.writeln('    box.field$index = $index;');
      }
      output.writeln('  }');
      output.writeln('  return box;');
      output.writeln('}');
      output.writeln();
      output.writeln('int sink = 0;');
      output.writeln();
      output.writeln("@pragma('dart2js:noInline')");
      output.writeln('void consume(int value) {');
      output.writeln('  sink ^= value;');
      output.writeln('}');
      output.writeln();
      output.writeln("@pragma('dart2js:noInline')");
      output.writeln('void workload(Box box) {');
      for (var index = 0; index < size; index++) {
        output.writeln('  consume(box.field$index);');
      }
      output.writeln('}');
      output.writeln();
      output.writeln('void main() {');
      output.writeln(
        '  workload(createBox(DateTime.now().millisecondsSinceEpoch.isEven));',
      );
      output.writeln('}');

    default:
      stderr.writeln('unknown mode: $mode');
      exitCode = 64;
  }

  await output.close();
}
