import 'dart:io';

import 'dart:math';

class FileUtils {
  static String getFileExtension(File file){
    List fileNameSplit = file.path.split(".");
    String extension = fileNameSplit.last;
    return extension;
  }

  static String getFileSize(File file){
    return (file.lengthSync() / (1024 * 1024)).toStringAsFixed(1);
  }

  static String formatBytes(bytes, decimals) {
    if (bytes == 0) return "0.0 KB";
    var k = 1024,
        dm = decimals <= 0 ? 0 : decimals,
        sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
        i = (log(bytes) / log(k)).floor();
    return (((bytes / pow(k, i)).toStringAsFixed(dm)) + ' ' + sizes[i]);
  }
}