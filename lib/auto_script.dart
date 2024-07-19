import 'dart:io';
import 'package:tuple/tuple.dart';

void main() async {
  String filePath = 'lib/app/widgets.dart';
  String existingCode = await File(filePath).readAsString();

  String directoryPath = 'lib/widget_book';
  var result = collectFolderInfo(directoryPath);
  var code = generateCode(result, existingCode);
  // print(result);
  await File(filePath).writeAsString(code);  // Generate and write the new code to the file
  print('Code generation completed');
}

List<Tuple2<String, String>> collectFolderInfo(String directoryPath) {
  Directory directory = Directory(directoryPath);
  List<Tuple2<String, String>> folderInfo = [];

  if (!directory.existsSync()) {
    print("Directory does not exist");
    return folderInfo;
  }

  List<FileSystemEntity> entities = directory.listSync(recursive: true);
  Map<String, String> folderMap = {};

  // Check each folder for 'usage.dart' or '_/_.dart' with 'class NewView'
  for (var entity in entities) {
    if (entity is File) {
      String fileName = entity.path.split('/').last;
      String folderName = entity.parent.path.split('/').last;
      String relativePath = entity.path.replaceFirst('$directoryPath/', '');
      String topFolderName = relativePath.split('/').first;

      if (!topFolderName.startsWith('_new')) {
        if (fileName == 'usage.dart') {
          folderMap[topFolderName] = 'usage';
        } else if (fileName == '_.dart') {
          String content = entity.readAsStringSync();
          if (content.contains('class NewView') && folderMap[topFolderName] != 'usage') {
            folderMap[topFolderName] = 'newview';
          }
        }
      }
    }
  }

  folderMap.forEach((key, value) {
    folderInfo.add(Tuple2(key, value));
  });

  return folderInfo;
}

String generateCode(List<Tuple2<String, String>> folderInfo, String existingCode) {
  Set<String> imports = {};
  Set<String> newImports = {};
  List<String> existingWidgets = [];
  List<String> newWidgets = [];
  Set<String> processedFolders = {}; // To track folders that already have 'usage' or 'newview'

  // 기존 코드에서 import 구문과 widgets 리스트를 추출
  var importRegex = RegExp(r"import\s+'([^']+)' as (\w+);");
  var widgetRegex = RegExp(r"Tuple2\('([^']+)',\s+(\w+)\.(\w+)\(\)\)");

  var importMatches = importRegex.allMatches(existingCode);
  var widgetMatches = widgetRegex.allMatches(existingCode);

  for (var match in importMatches) {
    String importLine = match.group(0)!;
    String importPath = match.group(1)!;
    String asName = match.group(2)!;

    imports.add(importLine);

    if (importPath.endsWith('_/_.dart') || importPath.endsWith('usage.dart')) {
      String folderName = importPath.split('/')[2]; // Extract folder name from import path
      processedFolders.add(folderName);
    }
  }

  for (var match in widgetMatches) {
    existingWidgets.add(match.group(0)!);
  }

  // 새로운 폴더 정보를 처리하여 import 및 widget 항목 추가
  for (var info in folderInfo) {
    String folderName = info.item1;
    String type = info.item2;
    String asName = folderName.replaceAll('.', '_');
    String importLine = "";

    if (processedFolders.contains(folderName)) {
      // Skip if the folder is already processed
      continue;
    }

    if (type == 'usage') {
      importLine = "import '../../widget_book/$folderName/usage.dart' as $asName;";
      if (!imports.any((import) => import.contains("$folderName/usage.dart"))) {
        newImports.add(importLine);
        newWidgets.add("Tuple2('$folderName', $asName.Usage())");
        processedFolders.add(folderName); // Mark folder as processed
      }
    } else if (type == 'newview') {
      importLine = "import '../../widget_book/$folderName/_/_.dart' as $asName;";
      if (!imports.any((import) => import.contains("$folderName/_/_.dart"))) {
        newImports.add(importLine);
        newWidgets.add("Tuple2('$folderName', $asName.NewView())");
        processedFolders.add(folderName); // Mark folder as processed
      }
    }
  }

  String importsCode = (newImports.isNotEmpty ? newImports.join('\n') + '\n' : '') + imports.join('\n');
  String widgetsCode = newWidgets.join(',\n  ') + (newWidgets.isNotEmpty ? ',\n  ' : '') + existingWidgets.join(',\n  ');

  return '''
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

$importsCode

final List<Tuple2<String, Widget>> widgets = [
  $widgetsCode
];
''';
}
