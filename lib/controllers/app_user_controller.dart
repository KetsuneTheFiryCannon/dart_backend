import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_backend/model/user.dart';
import 'package:dart_backend/utils/app_response.dart';
import 'package:dart_backend/utils/app_utils.dart';

class AppUserController extends ResourceController {
  AppUserController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> getProfile(
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(id);
      user!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);
      return AppResponse.ok(
          message: 'Успешное получения профиля', body: user.backing.contents);
    } catch (e) {
      return AppResponse.serverError(e,
          message: 'Ошибка получения профиля пользователя');
    }
  }

  @Operation.post()
  Future<Response> updateProfile(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() User user) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      var found = await managedContext.fetchObjectWithID<User>(id);

      // Запрос для обновления данных пользователя
      final qUpdateUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.userName = user.userName ?? found!.userName
        ..values.email = user.email ?? found!.email;
      await qUpdateUser.updateOne();

      // Получаем обновленного пользователя
      found = await managedContext.fetchObjectWithID<User>(id);
      found!.removePropertiesFromBackingMap(['accessToken', 'refreshToken']);

      return AppResponse.ok(
          body: found.backing.contents, message: 'Успешное обновление профиля');
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка обновления данных');
    }
  }
}
