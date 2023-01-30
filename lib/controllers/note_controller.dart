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
        ..values.number = note.number
        ..values.summ = note.summ
        ..values.category!.id = note.category!.id;
      final newNote = await qCreateNote.insert();
      newNote.removePropertyFromBackingMap('author');

      return AppResponse.ok(body: newNote, message: 'Заметка добавлена');
    } on QueryException catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка создания поста');
    }
  }

  @Operation.get()
  Future<Response> getAllUserNotes(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      {@Bind.query('s') String s = '',
      @Bind.query('pageLimit') int pageLimit = 0,
      @Bind.query('skipRows') int skipRows = 0}) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qGetNotes = Query<Note>(managedContext)
        ..fetchLimit = pageLimit
        ..offset = pageLimit * skipRows
        ..where((x) => x.author!.id).equalTo(id)
        ..where((x) => x.name).contains(s, caseSensitive: false)
        ..join(object: (x) => x.author)
        ..join(object: (x) => x.category);
      final List<Note> notes = await qGetNotes.fetch();
      if (notes.isEmpty) {
        return AppResponse.notFound(data: [], message: 'Не найдено заметок');
      }

      for (var note in notes) {
        note.removePropertyFromBackingMap('author');
      }

      return AppResponse.ok(
          body: notes, message: 'Записки авторизованного пользователя');
    } catch (e) {
      return AppResponse.serverError(e);
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
        ..where((x) => x.id).equalTo(id)
        ..join(object: (x) => x.category);

      final note = await qGetNote.fetchOne();
      if (note == null) {
        return AppResponse.notFound(message: 'Не найдено заметок');
      }
      note.removePropertyFromBackingMap('author');

      var response = AppResponse.ok(body: note, message: 'Найдена заметка');
      return response;
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.put('id')
  Future<Response> updateNote(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path('id') int id,
      @Bind.body() Note note) async {
    try {
      final authorId = AppUtils.getIdFromHeader(header);
      final author = await managedContext.fetchObjectWithID<User>(authorId);
      if (author == null) {
        throw AppResponse.unauthorized(message: 'Невалидный токен');
      }

      final qGetNote = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..join(object: (x) => x.author)
        ..join(object: (x) => x.category);
      var found = await qGetNote.fetchOne();
      if (found == null) {
        return AppResponse.notFound(message: 'Не найдено заметок');
      }

      final qUpdateNote = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.content = note.content
        ..values.name = note.name
        ..values.category!.id = note.category!.id
        ..values.editedDate = DateTime.now();
      found = await qUpdateNote.updateOne();

      return AppResponse.ok(body: found, message: 'Заметка успешно обновлена');
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.delete('id')
  Future<Response> deleteNote(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path('id') int id) async {
    try {
      final authorId = AppUtils.getIdFromHeader(header);
      final author = await managedContext.fetchObjectWithID<User>(authorId);
      if (author == null) {
        throw AppResponse.unauthorized(message: 'Невалидный токен');
      }

      final note = await managedContext.fetchObjectWithID<Note>(id);
      if (note == null) {
        return AppResponse.notFound(message: 'Не найдено записок');
      }

      if (note.author!.id != authorId) {
        final data = {'author': note.author!.id, 'user': authorId};
        return AppResponse.forbidden(
            data: data, message: 'Пользователь не является автором записки');
      }

      final qDeleteNote = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id);
      await qDeleteNote.delete();

      return AppResponse.ok(message: 'Записка была успешно удалена');
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка удаления заметки');
    }
  }
}
