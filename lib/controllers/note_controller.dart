import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_backend/model/note.dart';
import 'package:dart_backend/model/user.dart';
import 'package:dart_backend/utils/app_response.dart';
import 'package:dart_backend/utils/app_utils.dart';

class NoteController extends ResourceController {
  NoteController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.post()
  Future<Response> createNote(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() Note note) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final author = await managedContext.fetchObjectWithID<User>(id);

      if (author == null) {
        throw AppResponse.unauthorized(message: 'Невалидный токен');
      }

      final qCreateNote = Query<Note>(managedContext)
        ..values.author!.id = id
        ..values.content = note.content
        ..values.name = note.name
        ..values.category = note.category;
      await qCreateNote.insert();

      return AppResponse.ok(message: 'Заметка успешно добавлена');
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка создания поста');
    }
  }
}
