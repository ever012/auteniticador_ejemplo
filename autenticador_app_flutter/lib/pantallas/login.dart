import 'package:flutter/material.dart';
import 'inicio.dart'; // Redirige a esta pantalla después del login
import '../widgets/input_field.dart'; // Widget para los campos de entrada
import '../servicios/api_service.dart';
import '../utilidades/config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService(AppConfig.baseUrl_azure);

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;


    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un usuario y contraseña válidos')),
      );
      return;
    }

    try {
      final isValidUser = await _apiService.getUser(username, password);
      if (isValidUser) {
        // Redirigir a la pantalla Inicio
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Inicio()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.lightBlueAccent,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomRight,
              heightFactor: 0.5,
              widthFactor: 0.5,
              child: Material(
                borderRadius: const BorderRadius.all(Radius.circular(200.0)),
                color: const Color.fromRGBO(255, 255, 255, 0.4),
                child: SizedBox(
                  width: 400,
                  height: 400,
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Material(
                      elevation: 10.0,
                      borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "lib/imagenes/flutter-logo.png",
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                    // Campo de usuario
                    InputField(
                      const Icon(Icons.person, color: Colors.white),
                      "Username",
                      controller: _usernameController,
                    ),
                    // Campo de contraseña
                    InputField(
                      const Icon(Icons.lock, color: Colors.white),
                      "Password",
                      controller: _passwordController,
                    ),
                    // Botón de Login
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 20.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
