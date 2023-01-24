import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_backend/model/note.dart';
import 'package:dart_backend/model/user.dart';
import 'package:dart_backend/response.dart';
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

  @Operation.get()
  Future<Response> getAllUserNotes(
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qGetNotes = Query<Note>(managedContext)
        ..where((x) => x.author!.id).equalTo(id);
      final List<Note> notes = await qGetNotes.fetch();
      if (notes.isEmpty) {
        return Response.notFound(
            body: ModelResponse(data: [], message: 'Не найдено заметок'));
      }
      return AppResponse.ok(body: notes);
    } on QueryException catch (e) {
      return AppResponse.serverError(e, message: e.message);
    }
  }

  @Operation.get('id')
  Future<Response> getNoteById(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path('id') int id) async {
    try {
      final authorId = AppUtils.getIdFromHeader(header);
      final qGetNote = Query<Note>(managedContext)
        ..where((x) => x.author!.id).equalTo(authorId)
        ..where((x) => x.id).equalTo(id);

      final note = await qGetNote.fetchOne();
      if (note == null) {
        return Response.notFound(
            body: ModelResponse(message: 'Не найдено заметок'));
      }

      return AppResponse.ok(body: note);
    } on QueryException catch (e) {
      return AppResponse.serverError(e, message: e.message);
    }
  }
}
