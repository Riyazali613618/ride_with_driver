import 'dart:io';

final RegExp visibleTextPattern = RegExp(
  r'''(?<!\/\/.*)(?<!print\()(?:Text\(|hintText:|title:|labelText:|message:|content:)\s*['"]([^'"]{2,})['"]''',
  multiLine: true,
);

void main() async {
  final directory = Directory('lib/');
  final fileList = await directory
      .list(recursive: true)
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  final Map<String, Set<String>> fileTextMap = {};

  for (var file in fileList) {
    final content = await File(file.path).readAsString();

    final matches = visibleTextPattern.allMatches(content);
    final Set<String> strings = {};

    for (final match in matches) {
      final extracted = match.group(1);
      if (extracted != null &&
          !extracted.trim().startsWith('debug') &&
          !extracted.trim().startsWith('//')) {
        strings.add(extracted.trim());
      }
    }

    if (strings.isNotEmpty) {
      fileTextMap[file.path] = strings;
    }
  }

  final output = StringBuffer();

  for (final entry in fileTextMap.entries) {
    output.writeln('// File: ${entry.key}');
    output.writeln('{');
    for (final str in entry.value) {
      output.writeln('  "$str": "",');
    }
    output.writeln('}\n');
  }

  final outFile = File('tool/localization_strings_output.txt');
  await outFile.writeAsString(output.toString());

  print('✅ Extraction complete. Check: tool/localization_strings_output.txt');
}
