import 'package:global_configuration/global_configuration.dart';

class Configuration {
  static Future<Map<String, dynamic>> get() async =>
      (await GlobalConfiguration().loadFromAsset("api")).appConfig;
}
