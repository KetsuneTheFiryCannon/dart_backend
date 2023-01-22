import 'dart:async';
import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_backend/utils/app_response.dart';
import 'package:dart_backend/utils/app_utils.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AppTokenController extends Controller {
  @override
  FutureOr<RequestOrResponse?> handle(Request request) {
    try {
      // Получаем токен из header запроса
      final header = request.raw.headers.value(HttpHeaders.authorizationHeader);
      final token = const AuthorizationBearerParser().parse(header);

      // Получаем jwt-claim для проверки токена
      final jwtClaim = verifyJwtHS256Signature(token ?? '', AppUtils.secretKey);
      jwtClaim.validate();
      return request;
    } on JwtException catch (e) {
      return AppResponse.serverError(e.message);
    }
  }
}
