import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'source_generator/annotation.dart';

class HttpContentMixin {
  final Map<String, dynamic> _queryParams = {};
  Map<String, dynamic> headers = {};

  Map<String, dynamic> get queryParams => _queryParams;

  /// 鍵值對應的 body
  Map<String, dynamic> _keyValueBody = {};

  /// rawData的 body
  String _rawBody = '';

  ContentType? _contentType;

  int? port;

  /// body 的類型, 預設 [HttpBodyType.formUrlencoded]
  HttpBodyType bodyType = HttpBodyType.formUrlencoded;

  /// contentType, null時根據 body 帶入對應contentType
  ContentType? get contentType {
    if (_contentType != null) {
      return _contentType;
    } else if (_rawBody.isNotEmpty || _keyValueBody.isNotEmpty) {
      return _convertBodyType();
    }
    return null;
  }

  /// 取得最終帶入的 body
  dynamic get bodyData {
    switch (bodyType) {
      case HttpBodyType.formData:
      case HttpBodyType.formUrlencoded:
        // 當 _keyValueBody 沒值, 而 _rawBody 有值時
        // 嘗試解析 _rawBody 為 json 並轉為鍵值對應
        if (_keyValueBody.isEmpty && _rawBody.isNotEmpty) {
          print("body 的類型為 $bodyType, 但鍵值對應參數為空, 嘗試從 rawBody 轉換");
          try {
            return json.decode(_rawBody);
          } on FormatException catch (_) {
            print("轉換失敗, 將回傳空 body");
          }
        }
        return _keyValueBody;
      case HttpBodyType.raw:
        // 當 _rawBody 無值, 且 _keyValueBody 有值
        // 將 _keyValueBody 轉換為 _rawBody
        // 轉換過程將會移除 MultipartFile
        if (_rawBody.isEmpty && _keyValueBody.isNotEmpty) {
          print("body 的類型為 $bodyType, 但 rawBody 參數為空, 嘗試從 鍵值對應 轉換");

          // 先移除第二層是 FileInfo 的參數
          _keyValueBody = _keyValueBody.map((k, v) {
            if (v is List) {
              v.removeWhere((e) => e is MultipartFile);
            }
            return MapEntry(k, v);
          });

          // 接著移除第一層為空, 或為 FileInfo 的參數
          _keyValueBody.removeWhere((k, v) {
            if (v is List && v.isEmpty) {
              return true;
            } else if (v is MultipartFile) {
              return true;
            }
            return false;
          });
          try {
            return json.encode(_keyValueBody);
          } on JsonUnsupportedObjectError catch (_) {
            print("轉換失敗, 將回傳空 body");
          }
        }
        return _rawBody;
    }
  }

  /// 將 bodyType 轉換為 contentType
  ContentType? _convertBodyType() {
    switch (bodyType) {
      case HttpBodyType.formData:
        return null;
      case HttpBodyType.formUrlencoded:
        return ContentType.parse(HttpContentType.formUrlencoded.value);
      case HttpBodyType.raw:
        return ContentType.parse(HttpContentType.json.value);
    }
  }

  /// 直接設定param, 會替代掉原有的
  void setQueryParams(Map<String, dynamic> iterable) {
    _queryParams.clear();
    iterable.forEach((k, v) => addQueryParam(k, value: v));
  }

  void addQueryParams(Map<String, dynamic> iterable) {
    iterable.forEach((key, value) {
      addQueryParam(key, value: value);
    });
  }

  void setContentType(ContentType? type) {
    _contentType = type;
  }

  /// 直接設定 body, 將會清空當前的 body
  /// 重新設置新值
  /// [raw] - 純字串內容
  /// [keyValue] - 鍵值對應內容, 若需要帶入檔案則value帶入[MultipartFile]
  void setBody({Map<String, dynamic>? keyValue, String? raw}) {
    _keyValueBody.clear();
    _rawBody = '';
    if (keyValue != null) {
      keyValue.forEach((k, v) {
        addBody(key: k, value: v);
      });
    } else if (raw != null) {
      _rawBody = raw;
    }
  }

  @protected
  Map<String, dynamic> getKeyValueBody() {
    return _keyValueBody;
  }

  @protected
  String getRawBody() {
    return _rawBody;
  }

  /// 加入鍵值body, 若是需要設定rawBody, 則改用[setBody]方法
  /// [key] - 鍵值key
  /// [value] - 對應內容, 若為檔案則帶入[MultipartFile]
  void addBody({
    required String key,
    required dynamic value,
  }) {
    // 添加鍵值對應
    _addPair(key, value: value, target: _keyValueBody);
  }

  /// 純粹的 key value pair
  /// [iterable] - 鍵值對應內容, 若需要帶入檔案則value帶入[MultipartFile]
  void addBodys(Map<String, dynamic> iterable) {
    iterable.forEach((k, v) {
      addBody(key: k, value: v);
    });
  }

  /// 添加複數個抬頭
  void addHeaders(Map<String, dynamic> iterable) {
    iterable.forEach((key, value) {
      addHeader(key, value: value);
    });
  }

  /// 添加參數
  /// 若是添加陣列到字串的參數, 則原先的字串會變為陣列並且加入新陣列
  /// 若是添加字串到陣列的參數, 則原因的陣列會添加一個新元素
  void addQueryParam(String key, {required dynamic value}) {
    _addPair(key, value: value, target: _queryParams);
  }

  /// 添加抬頭
  /// 若是添加陣列到字串的參數, 則原先的字串會變為陣列並且加入新陣列
  /// 若是添加字串到陣列的參數, 則原因的陣列會添加一個新元素
  void addHeader(String key, {required dynamic value}) {
    _addPair(key, value: value, target: headers);
  }

  void clear() {
    headers.clear();
    _queryParams.clear();
    _keyValueBody.clear();
    _rawBody = '';
    port = null;
    bodyType = HttpBodyType.formUrlencoded;
    _contentType = null;
  }

  void _addPair(
    String key, {
    required dynamic value,
    required Map<String, dynamic> target,
  }) {
    if (target.containsKey(key)) {
      var oriValue = target[key];
      if (value is List<String>) {
        if (oriValue is String) {
          //原先元素是個字串, 更改為陣列並添加
          target[key] = [oriValue] + value;
        } else if (oriValue is List<String>) {
          //原先元素是個陣列, 直接添加
          target[key] = oriValue + value;
        }
      } else if (value is String) {
        if (oriValue is String) {
          //原先元素是個字串, 直接修改參數
          target[key] = value;
        } else if (oriValue is List<String>) {
          //原先元素是個陣列, 直接添加
          oriValue.add(value);
          target[key] = oriValue;
        }
      }
    } else {
      target[key] = value;
    }
  }

  void parseQuery(Map<String, String> query) {
    const regex = "[\\w]+(?=\\[[0-x9]+\\])";
    RegExp regExp = RegExp(regex);
    query.forEach((key, value) {
      String realKey = key;
      if (regExp.hasMatch(key)) {
        //代表是個陣列
        realKey = regExp.firstMatch(key)!.group(0)!;
        addQueryParam(realKey, value: [value]);
      } else {
        //代表並非陣列
        addQueryParam(realKey, value: value);
      }
    });
  }
}
