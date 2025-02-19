import 'env.dart';

class AppConfig {
  static late Env _env;

  static void initialize(Env env) {
    _env = env;
  }

  static Env get env => _env;
}