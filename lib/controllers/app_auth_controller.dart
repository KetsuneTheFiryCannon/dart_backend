import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_backend/model/user.dart';
import 'package:dart_backend/response.dart';
import 'package:dart_backend/utils/app_utils.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AppAuthController extends ResourceController {
  AppAuthController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.password == null || user.userName == null) {
      return Response.badRequest(
          body: ModelResponse(
              message: 'Поля "userName" и "password" обязательны'));
    }

    try {
      final found = await _findUser(managedContext, user.userName);
      if (found == null) {
        throw QueryException.input('Пользователь не найден', []);
      }

      // Генерация хэша пароля для дальнейшей проверки
      final requestHashPassword =
          generatePasswordHash(user.password ?? '', found.salt ?? '');

      if (requestHashPassword == found.hashPassword) {
        // Обновление токена пароля
        _updateTokens(found.id ?? -1, managedContext);

        // Получаем данные пользователя
        final newUser = await managedContext.fetchObjectWithID<User>(found.id);
        return Response.ok(ModelResponse(
            data: newUser!.backing.contents, message: 'Успешная авторизация'));
      } else {
        throw QueryException.input('Неверный пароль', []);
      }
    } on QueryException catch (e) {
      return Response.serverError(body: ModelResponse(message: e.message));
    }
  }

  @Operation.post()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password == null || user.userName == null || user.email == null) {
      return Response.badRequest(
          body: ModelResponse(
              message: 'Поля "email", "userName" и "password" обязательны'));
    }

    // Генерация соли
    final salt = generateRandomSalt();
    // Генерация хэша пароля
    final hashPassword = generatePasswordHash(user.password!, salt);

    try {
      late final int id;

      // Создаем транзакцию
      await managedContext.transaction((transaction) async {
        final qCreateUser = Query<User>(transaction)
          ..values.userName = user.userName
          ..values.email = user.email
          ..values.salt = salt
          ..values.hashPassword = hashPassword;

        // Добавление пользователя в базу данных
        final created = await qCreateUser.insert();
        // Сохраняем id
        id = created.id!;
        // Обновление токены
        _updateTokens(id, transaction);
      });

      final userData = await managedContext.fetchObjectWithID<User>(id);
      return Response.ok(ModelResponse(
          data: userData!.backing.contents, message: 'Успешная регистрация'));
    } on QueryException catch (e) {
      return Response.serverError(body: ModelResponse(message: e.message));
    }
  }

  @Operation.post('refresh')
  Future<Response> refreshToken(@Bind.path('refresh') String refreshToken) async {
    try {
      // Получаем id пользователя из jwt-токена
      final id =  AppUtils.getIdFromToken(refreshToken);

      // Получаем данные пользователя по id
      final user = await managedContext.fetchObjectWithID<User>(id);

      if (user!.refreshToken !=refreshToken) {
        return Response.unauthorized(body: 'Токен невалидный');
      }

      _updateTokens(id, managedContext);
      return Response.ok(
        ModelResponse(data: user.backing.contents, message: 'Токен успешно обновлен')
      );
    } on QueryException catch (e) {
      return Response.serverError(body: ModelResponse(message: e.message));
    }
  }

  /// Поиск по имени пользователя в базе данных
  Future<User?> _findUser(ManagedContext context, String? userName) {
    final qFindUser = Query<User>(managedContext)
      ..where((x) => x.userName).equalTo(userName)
      ..returningProperties((x) => [x.id, x.salt, x.hashPassword]);

    return qFindUser.fetchOne();
  }

  void _updateTokens(int id, ManagedContext transaction) async {
    final Map<String, String> tokens = _getTokens(id);

    final qUpdateTokens = Query<User>(transaction)
      ..where((x) => x.id).equalTo(id)
      ..values.accessToken = tokens['access']
      ..values.refreshToken = tokens['refresh'];

    await qUpdateTokens.updateOne();
  }

  Map<String, String> _getTokens(int id) {
    final key = Platform.environment['SECRET_KEY'] ?? 'SECRET_KEY';
    final accessClaimSet =
        JwtClaim(maxAge: const Duration(hours: 1), otherClaims: {'id': id});
    final refreshClaimSet = JwtClaim(otherClaims: {'id': id});

    final tokens = <String, String>{
      'access': issueJwtHS256(accessClaimSet, key),
      'refresh': issueJwtHS256(refreshClaimSet, key),
    };
    return tokens;
  }
}
