import 'package:mx_core/mx_core.dart';
import 'package:rxdart/rxdart.dart';

import '../request/ex/ex_request_builder.api.dart';
import '../request/ex/ex_request_client.dart';

class ExRequestService {
  ExRequestClientMixin exRequestClientMixin = ExRequestClient.getInstance();

  Observable<ServerResponse> exApi(String titlePath, String aId, String bToken,
      String cBody, String rawBody, FileInfo dBodyFile,
      {String opId,
      String opToken,
      String opBody,
      FileInfo opBodyFile,
      String optRawBody}) {
    return exRequestClientMixin
        .exApi(
          titlePath,
          aId,
          bToken,
          cBody,
          rawBody,
          dBodyFile,
          opId: opId,
          opToken: opToken,
          opBody: opBody,
          opBodyFile: opBodyFile,
          optRawBody: optRawBody,
        )
        .connect();
  }
}

