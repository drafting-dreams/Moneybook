import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtil {
  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }
  Future<File> localFile(String fileName) async {
    final path = await localPath;
    return File('$path/$fileName');
  }

  Future<File> writeTo(String fileName, String contents) async {
    final file = await localFile(fileName);

    // Write the file.
    return file.writeAsString(contents);
  }

  Future<String> readFrom(String fileName) async {
    try {
      final file = await localFile(fileName);
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      throw e;
    }
  }
}