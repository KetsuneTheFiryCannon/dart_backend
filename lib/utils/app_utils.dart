import 'dart:io';
import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class AppUtils {
  const AppUtils._();

  static String get secretKey => Platform.environment['SECRET_KEY'] ?? 'SECRET_KEY';

  static int getIdFromToken(String token) {
    final jwtClaim = verifyJwtHS256Signature(token, secretKey);
    return int.parse(jwtClaim['id'].toString());
  }

  static int getIdFromHeader(String header) {
    final token = const AuthorizationBearerParser().parse(header);
    final id = getIdFromToken(token ?? '');
    return id;
  }
}