import 'dart:io';

import 'model/author.dart';
import 'model/post.dart';
import 'model/user.dart';

import 'package:conduit/conduit.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  @override
  Future prepare(){
    final persistenStore = _initDatabase();

    managedContext = ManagedContext(
      ManagedDataModel.fromCurrentMirrorSystem(), persistenStore);
      return super.prepare();
  }

  @override
  Controller get entryPoint => Router();

  PersistentStore _initDatabase() {
    final username = Platform.environment['DB_USERNAME'] ?? 'postgres';
    final password = Platform.environment['DB_PASSWORD'] ?? '2358';
    final host = Platform.environment['DB_HOST'] ?? '127.0.0.1';
    final port = int.parse(Platform.environment['DB_PORT'] ?? '5432');
    final databaseName = Platform.environment['DB_NAME'] ?? 'flutter-project';
    return PostgreSQLPersistentStore(username, password, host, port, databaseName);
  }
}