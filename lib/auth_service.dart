import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Importe a biblioteca

class AuthService {
  static const String _userIdKey = 'userId';
  static const String _tokenKey = 'authToken'; // Chave para o token de autenticação (pode ser diferente do seu)

  static const _secureStorage = FlutterSecureStorage();

  // Salva apenas o ID do usuário usando SharedPreferences (menos sensível)
  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  // Obtém apenas o ID do usuário usando SharedPreferences
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Salva o token de autenticação usando FlutterSecureStorage
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  // Obtém o token de autenticação usando FlutterSecureStorage
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  //  Verifica se o usuário está autenticado
  // A autenticação é baseada na existência de um token válido.
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    // Retorna true se o token não for nulo, false caso contrário.
    return token != null && token.isNotEmpty; // Adicionado .isNotEmpty para garantir que não é vazio
  }

  // Logout: remove o ID do SharedPreferences e o token do Secure Storage
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey); // Remove o User ID
    await _secureStorage.delete(key: _tokenKey); // Remove o Token
    // Adicione aqui qualquer outra lógica de limpeza ao deslogar
  }

  // clearUserData chama logout, o que agora limpa ID e Token.
  static Future<void> clearUserData() async {
    await logout();
  }

}