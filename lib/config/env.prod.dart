import 'env.dart';

class ProdEnv implements Env {
  @override
  String get apiUrl => 'http://localhost:5000'; // Update later

  @override
  bool get enableLogging => false;
}