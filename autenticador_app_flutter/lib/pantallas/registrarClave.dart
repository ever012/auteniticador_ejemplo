import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../servicios/api_service.dart';
import '../utilidades/config.dart';
import 'inicio.dart';
import 'login.dart'; // Importar la pantalla de Login
import '../modelos/AuthenticadorModel.dart';

class RegistrarClave extends StatefulWidget {
  const RegistrarClave({super.key});

  @override
  State<RegistrarClave> createState() => _RegistrarClaveState();
}

class _RegistrarClaveState extends State<RegistrarClave> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();
  final ApiService _apiService = ApiService(AppConfig.baseUrl_azure);

  @override
  void initState() {
    super.initState();
    _checkAuthentication(); // Verificar si el usuario está autenticado
  }

  // Método para verificar si el usuario ha iniciado sesión
  Future<void> _checkAuthentication() async {
    final int? usrCodigo = await _apiService.ObtenerCodUsuarioSeguro(); // Obtener código de usuario de manera segura


    if (usrCodigo == null) {
      // Si no está autenticado, redirigir al login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _insertNewTotp() async {
    try {
      final int? usrCodigo = await _apiService.ObtenerCodUsuarioSeguro(); // Obtener código de usuario de manera segura


      if (usrCodigo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No está autenticado')),
        );
        return;
      }

      final account = _accountController.text.trim();
      final secretKey = _secretKeyController.text.trim();

      if (account.isEmpty || secretKey.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, complete todos los campos')),
        );
        return;
      }

      final model = AuthenticadorModel(
        account: account,
        secretKey: secretKey,
      );

      await _apiService.insertNuevoTotp(usrCodigo, model);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TOTP registrado correctamente')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Inicio()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Clave'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _accountController,
              decoration: const InputDecoration(labelText: 'Account'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _secretKeyController,
              decoration: const InputDecoration(labelText: 'Secret Key'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _insertNewTotp,
              child: const Text('Generate Code'),
            ),
          ],
        ),
      ),
    );
  }
}
