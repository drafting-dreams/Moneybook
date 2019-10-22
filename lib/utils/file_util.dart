import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum PathType { doc, temp, external }

class FileUtil {
  Future<String> get appPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
  Future<String> get tempPath async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }
  Future<String> get externalPath async {
    final dir = await getExternalStorageDirectory();
    return dir.path;
  }

  // This will automatically create the file recursively, if not exists.
  Future<File> localFile(PathType type, String fileName) async {
    String path;
    switch(type) {
      case PathType.doc:
        path = await appPath;
        break;
      case PathType.temp:
        path = await tempPath;
        break;
      case PathType.external:
        path = await externalPath;
    }
    final file = await File('$path/$fileName').create(recursive: true);
    return file;
  }

  Future<File> writeTo(PathType type, String fileName, String contents) async {
    final file = await localFile(type, fileName);

    // Write the file.
    return file.writeAsString(contents);
  }

  Future<String> readFrom(PathType type, String fileName) async {
    try {
      final file = await localFile(type, fileName);
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      throw e;
    }
  }
}