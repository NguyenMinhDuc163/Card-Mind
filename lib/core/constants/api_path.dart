import 'package:envied/envied.dart';

import 'environment_files.dart';

part 'api_path.g.dart';

@Envied(path: pathToEnv, requireEnvFile: true)
class ApiPath {
  /// Base URL
  @EnviedField(varName: 'BASE_URL', obfuscate: true)
  static String baseUrl = _ApiPath.baseUrl;
  @EnviedField(varName: 'REGISTER_ID', obfuscate: true)
  static String registerId = _ApiPath.registerId;

  static const String refreshToken = '/refresh-token';
  static const String chatBot = '/chat/public';
}

// TODO trong intercepter => ds api can truyen id
// TODO o trong path chi dinh san ky tu => nhan dien duoc de truyen them id
// TODO tim hieu app error state
