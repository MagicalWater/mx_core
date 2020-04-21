import 'package:mx_core/mx_core.dart';

import 'ex_request_builder.api.dart';

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
      'titleBodyFile':
          FileInfo(filename: 'titleFilename', filepath: 'titleFilepath')
    },
    bodyType: HttpBodyType.formUrlencoded,
    contentType: HttpContentType.formUrlencoded,
    host: 'titleHost',
    scheme: 'titleHttps',
    port: 8881,
  )
  HttpContent exApi(
    @Path('titlePath') String titlePath,
    @Param('id') String aId,
    @Header('toke¥n') String bToken,
    @Body('body') String cBody,
    @Body() String rawBody,
    @Body('bodyF') FileInfo dBodyFile, {
    @Param('opId') String opId,
    @Header('tokenOp') String opToken,
    @Body('bodyOp') String opBody,
    @Body('bodyFOp') FileInfo opBodyFile,
    @Body() String optRawBody,
  });
}

class ExRequestBuilder extends ExRequestApi {

  @override
  String host(String client) {
    return super.host(client);
  }

  @override
  String scheme(String client) {
    return super.scheme(client);
  }

  @override
  Map<String, String> queryParams(Map<String, String> client) {
    return super.queryParams(client);
  }

  @override
  Map<String, String> headers(Map<String, String> client) {
    return super.headers(client);
  }

  @override
  dynamic body(client) {
    return super.body(client);
  }

  @override
  HttpBodyType bodyType(HttpBodyType client) {
    return super.bodyType(client);
  }

  @override
  HttpContentType contentType(HttpContentType client) {
    return super.contentType(client);
  }
}
