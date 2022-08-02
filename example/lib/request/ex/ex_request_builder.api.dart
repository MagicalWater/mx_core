// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// ApiGenerator
// **************************************************************************

part of 'ex_request_builder.dart';

abstract class ExRequestApi extends RequestBuilderBase
    implements ExRequestInterface {
  @override
  HttpContent exApi(String titlePath, String? aId, String bToken, String cBody,
      MultipartFile dBodyFile,
      {required String check,
      required String? opId,
      String? opToken,
      String? opBody,
      MultipartFile? opBodyFile,
      required List<String> opId2}) {
    final content = generator.generate('ex/$titlePath$check',
        method: HttpMethod.post,
        port: 8881,
        contentType: ContentType.parse("application/x-www-form-urlencoded"));
    content.bodyType = HttpBodyType.formUrlencoded;
    const _temp3 = "titleBodyValue";
    content.addBody(
      key: "titleBodyKey",
      value: _temp3,
    );
    content.addBody(
      key: "body",
      value: cBody,
    );
    content.addBody(
      key: "bodyF",
      value: dBodyFile,
    );
    if (opBody != null) {
      content.addBody(
        key: "bodyOp",
        value: opBody,
      );
    }
    if (opBodyFile != null) {
      content.addBody(
        key: "bodyFOp",
        value: opBodyFile,
      );
    }
    const _temp2 = "titleHValue";
    content.addHeader("titleHKey", value: _temp2);
    content.addHeader("toke¥n", value: bToken);
    if (opToken != null) {
      content.addHeader("tokenOp", value: opToken);
    }
    const _temp1 = "titleQPValue";
    content.addQueryParam("titleQPKey", value: _temp1);
    if (aId != null) {
      content.addQueryParam("id", value: aId);
    }
    if (opId != null) {
      content.addQueryParam("opId", value: opId);
    }
    content.addQueryParam("opId2", value: opId2);

    return content;
  }
}
