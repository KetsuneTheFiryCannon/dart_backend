import 'package:dart_backend/dart_backend.dart';
import 'dart:io';
import 'package:conduit/conduit.dart';

void main() async {
  //Указываем порт на котором у нас будет запущен сервис - в данном случае API
  final port = int.parse(Platform.environment['PORT'] ?? '5785');
  //Инициализация переменная и назначение порта на котором развернется сервис
  final service = Application<AppService>()
    ..options.port = port
    ..options.configurationFilePath = 'config.yaml';

  //Запуск сервиса и его логирования, а так же три изолятора
  await service.start(numberOfInstances: 3, consoleLogging: true);
}
