import 'dart:convert';
import '../modelos/AuthenticadorModel.dart';
import 'httpService.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final HttpService _httpService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(); // Instancia de almacenamiento seguro

  ApiService(String baseUrl) : _httpService = HttpService(baseUrl);

  Future<ResponseModel> generateCode(AuthenticadorModel request) async {
    final response = await _httpService.post(
      '/api/Autenticador/generate-code',
      headers: {'Content-Type': 'application/json'},
      body: request.toJson(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ResponseModel.fromJson(data);
    } else {
      throw Exception('Failed to generate code: ${response.statusCode}');
    }
  }

  Future<List<AccountCode>> getAccountsAndGenerateCodes(int codusr) async {
    final response = await _httpService.get(
      '/api/Autenticador/obtenerDatos/$codusr',
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> accounts = jsonDecode(response.body);

      List<AccountCode> codes = [];
      for (var account in accounts) {
        final accountModel = AuthenticadorModel(
          account: account['cat_cuenta'],
          secretKey: account['cat_clave'],
        );

        final codeResponse = await generateCode(accountModel);
        codes.add(AccountCode(
          catCodigo: account['cat_codigo'],
          account: account['cat_cuenta'],
          code: codeResponse.code,
        ));
      }

      return codes;
    } else {
      throw Exception('Failed to fetch accounts: ${response.statusCode}');
    }
  }

  Future<bool> getUser(String usuario, String clave) async {
    final response = await _httpService.get(
      '/api/Autenticador/obtenerUsuario/$usuario/$clave',
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final usrCodigo = data[0]['usr_codigo'];

        // Guardar el código del usuario de forma segura
        await _secureStorage.write(key: 'usr_codigo', value: usrCodigo.toString());

        return true;
      }
    } else if (response.statusCode == 404) {
      throw Exception('Usuario o contraseña incorrectos');
    }

    throw Exception('Error al verificar el usuario');
  }

  Future<void> insertNuevoTotp(int codUsuario, AuthenticadorModel model) async {
    final response = await _httpService.post(
      '/api/Autenticador/insertarNuevoTotp/$codUsuario',
      headers: {'Content-Type': 'application/json'},
      body: model.toJson(),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 400) {
      throw Exception('Error en la solicitud: ${response.body}');
    } else {
      throw Exception('Error al insertar TOTP: ${response.statusCode}');
    }
  }

  /// Nuevo metodo para eliminar TOTP
  Future<bool> deleteTotp(int codCat) async {
    final response = await _httpService.delete(
      '/api/Autenticador/eliminarTotp/$codCat',
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true; // Eliminación exitosa
    } else if (response.statusCode == 404) {
      return false; // Registro no encontrado
    } else {
      throw Exception('Error al eliminar TOTP: ${response.statusCode}');
    }
  }

  // 🔹 **Metodo Nuevo: Obtener código de usuario almacenado de forma segura**
  Future<int?> ObtenerCodUsuarioSeguro() async {
    String? usrCodigoStr = await _secureStorage.read(key: 'usr_codigo');

    if (usrCodigoStr == null) return null;

    return int.tryParse(usrCodigoStr);
  }

  // 🔹 **Metodo Nuevo: Cerrar sesión y borrar los datos seguros**
  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }


}

class AccountCode {
  final int catCodigo;
  final String account;
  final String code;

  AccountCode({required this.catCodigo, required this.account, required this.code});
}
