import 'dart:io';
import 'package:conduit/conduit.dart';
import 'model/author.dart';
import 'model/post.dart';
import 'model/user.dart';

class AppService extends ApplicationChannel {
late final ManagedContext managedContext;
  
  @override
  Future prepare() {
    final persistentStore = _initDatabase();
    managedContext = ManagedContext(
      ManagedDataModel.fromCurrentMirrorSystem(), 
      persistentStore);
      return super.prepare();
  }

  @override
  Controller get entryPoint => Router();
  
  PersistentStore _initDatabase() {
    final username = Platform.environment['DB_USERNAME'] ?? 'postgres';
    final password = Platform.environment['DB_PASSWORD'] ?? '123'; 
    final host = Platform.environment['DB_HOST'] ?? '127.0.0.1'; 
    final port = int.parse(Platform.environment['DB_PORT'] ?? '5432'); 
    final databaseName = Platform.environment['DB_NAME'] ?? 'dart_backend'; 

    return PostgreSQLPersistentStore(username, password, host, port, databaseName);
  }
}