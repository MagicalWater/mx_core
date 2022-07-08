// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// ApiGenerator
// **************************************************************************

part of 'ex_request_builder.dart';

abstract class ExRequestApi extends RequestBuilderBase
    implements ExRequestInterface {
  @override
  HttpContent exApi(String titlePath,
      {required String? opId,
      required List<String> opId2,
      required List<AA> opId3,
      AA? opId4}) {
    final content = generator.generate('ex/aa',
        method: HttpMethod.post,
        port: 8881,
        contentType: ContentType.parse("application/x-www-form-urlencoded"));
    content.bodyType = HttpBodyType.formUrlencoded;
    const _temp3 = "titleBodyValue";
    content.addBody(
      key: "titleBodyKey",
      value: _temp3,
    );
    if (opId4 != null) {
      content.setBody(raw: opId4.toString());
    }
    const _temp2 = "titleHValue";
    content.addHeader("titleHKey", value: _temp2);

    const _temp1 = "titleQPValue";
    content.addQueryParam("titleQPKey", value: _temp1);
    if (opId != null) {
      content.addQueryParam("opId", value: opId);
    }
    content.addQueryParam("opId2", value: opId2);
    content.addQueryParam("opId3", value: opId3);

    return content;
  }
}
