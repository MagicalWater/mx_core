import 'dart:io';

import 'package:meta/meta.dart';
import 'package:mx_core/http/http_content.dart';
import 'package:mx_core/http/http_util.dart';
import 'package:path_provider/path_provider.dart';

/// 文件操作
class FileUtil {

  FileUtil._();

  /// 取得外部儲存資料夾路徑
  static Future<File> get exStorageDirectory async {
    var dir = (await getExternalStorageDirectory()).path;
    return File(dir);
  }

  static Future<File> get cacheDirectory async {
    var dir = (await getTemporaryDirectory()).path;
    return File(dir);
  }

  static Future<String> getAppDir() async {
    var dir = (await getApplicationDocumentsDirectory()).path;
    return dir;
  }

  static Future<File> _getFile(String name) async {
    var dir = (await getApplicationDocumentsDirectory()).path;
    return File("$dir/$name");
  }

  /// 寫入 文件/網路請求 文件到本地
  static Future<File> write({
    @required String name,
    @required String content,
  }) async {
    var file = await (await _getFile(name)).create(recursive: true);
    print("寫入檔案: ${file.path}");
    return await (file).writeAsString(content);
  }

  /// 刪除本地文件
  static Future<File> delete({
    @required String name,
  }) async {
    var file = await _getFile(name);
    var isFileExist = await file.exists();
    if (isFileExist) {
      print("刪除檔案: ${file.path}");
      await (file).delete(recursive: true);
    }
  }

  /// 檢查文件是否存在
  static Future<bool> exists({
    @required String name,
  }) async {
    var file = await _getFile(name);
    return await file.exists();
  }

  /// 取得文件
  static Future<String> readAsString({
    @required String name,
  }) async {
    var file = await _getFile(name);
    var isFileExist = await exists(name: name);
    if (isFileExist) {
      return file.readAsString();
    } else {
      return null;
    }
  }

  /// 從網路下載文件
  static Future<File> writeFromNetwork({
    @required String name,
    @required HttpContent httpContent,
  }) async {
    File file;
    if (httpContent.saveInPath == null) {
      file = await (await _getFile(name)).create(recursive: true);
      httpContent.saveInPath = file.path;
    } else {
      file = File(httpContent.saveInPath);
    }
    print("FileUtil - 準備連接取得資料 ${httpContent.url}");
    final _ = await HttpUtil()
        .connect(httpContent,
        onReceiveProgress: (count, total) {
//      print("下載進度: $count / $total");
        })
        .single;
    print("FileUtil - 下載完畢, 存入 $file");
    return file;
  }

  /// 取得緩存總大小
  /// file.length() 是 byte 值
  /// 轉為 mb 需要 size /(1024 * 1024)
  /// 這邊回傳 mb
  static Future<double> get cacheFileSize async {
    var tempDir = await getTemporaryDirectory();

    Iterable<Future<int>> fileLenList;
    try {
      fileLenList = (await tempDir.list(recursive: true).toList())
          .where((f) => f is File)
          .map((f) => (f as File).length());
    } catch (e) {
      // print("取得快取size出錯: $e");
      fileLenList = [Future.value(0)];
    }
    var size = (await Future.wait(fileLenList));
    int sizeReduce;
//    print("區間列表: ${size}");
    if (size.length > 1) {
      sizeReduce = size.reduce((v, v2) => v + v2);
    } else if (size.length == 1) {
      sizeReduce = size[0];
    } else {
      sizeReduce = 0;
    }
    return sizeReduce / (1024 * 1024);
  }

  /// 清理緩存
  static Future<double> clearCacheFile() async {
    var file = await cacheDirectory;
    try {
      await file.delete(recursive: true);
    } catch (e) {
      print("刪除快取失敗: $e");
    }
    return Future.value(0);
  }
}
