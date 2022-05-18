import 'dart:io' show ContentType;

import 'package:mx_core/mx_core.dart';

part 'ex_request_builder.api.dart';

@Api()
abstract class ExRequestInterface {
  @Post(
    'ex/{titlePath}',
    headers: {
      'titleHKey': 'titleHValue',
    },
    queryParams: {
      'titleQPKey': 'titleQPValue',
    },
    body: {
      'titleBodyKey': 'titleBodyValue',
    },
    bodyType: HttpBodyType.formUrlencoded,
    contentType: HttpContentType.formUrlencoded,
    // host: 'titleHost',
    // scheme: 'titleHttps',
    port: 8881,
  )
  HttpContent exApi(
    @Path('titlePath') String titlePath,
    @Param('id') String aId,
    @Header('toke¥n') String bToken,
    @Body('body') String cBody,
    // @Body() String rawBody,
    @Body('bodyF') MultipartFile dBodyFile, {
    @Param('opId') required String? opId,
    @Header('tokenOp') String? opToken,
    @Body('bodyOp') String? opBody,
    @Body('bodyFOp') MultipartFile? opBodyFile,
    // @Body() String? optRawBody,
  });
}

class ExRequestBuilder extends ExRequestApi {
  @override
  String host() => 'www.google.com';

  @override
  String scheme() => 'https';
}
