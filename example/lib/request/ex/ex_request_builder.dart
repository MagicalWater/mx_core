import 'dart:io' show ContentType;

import 'package:mx_core/mx_core.dart';

part 'ex_request_builder.api.dart';

@Api()
abstract class ExRequestInterface {
  @Post(
    'ex/aa',
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
    @Path('titlePath') String titlePath, {
    @Param('opId') required String? opId,
    @Param('opId2') required List<String> opId2,
  });
}

class ExRequestBuilder extends ExRequestApi {
  @override
  String host() => 'www.google.com';

  @override
  String scheme() => 'https';
}
