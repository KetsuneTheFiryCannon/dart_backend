import 'package:conduit/conduit.dart';
import 'package:dart_backend/model_response.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AppResponse extends Response {
  AppResponse.serverError(dynamic error, {String? message})
      : super.serverError(body: _getResponseModel(error, message));

  AppResponse.unauthorized({dynamic body, String? message})
      : super.unauthorized(body: ModelResponse(data: body, message: message));

  AppResponse.badRequest({dynamic body, String? message})
      : super.badRequest(body: ModelResponse(data: body, message: message));

  AppResponse.notFound({dynamic data, String? message})
      : super.notFound(body: ModelResponse(data: data, message: message));

  AppResponse.ok({dynamic body, String? message})
      : super.ok(ModelResponse(data: body, message: message));

  static ModelResponse _getResponseModel(error, String? message) {
    if (error is QueryException || error is JwtException) {
      return ModelResponse(
          error: error.toString(), message: message ?? error.message);
    }

    return ModelResponse(
        error: error.toString(), message: message ?? 'Unknown error');
  }
}
