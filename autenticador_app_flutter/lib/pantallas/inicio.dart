import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../modelos/AuthenticadorModel.dart';
import '../servicios/api_service.dart';
import '../pantallas/registrarClave.dart';
import '../utilidades/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ScanerCodigoQr.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService(AppConfig.baseUrl_azure);
  List<AccountCode> _accountCodes = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Inicializar la animación de la barra de progreso
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );

    _animationController.addListener(() {
      int segundosRestantes = (30 * (1 - _animationController.value)).toInt();
      debugPrint("Avance: $segundosRestantes segundos restantes");
    });

    _animationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await _fetchCodes();
        _animationController.reset();
        _animationController.forward();
      }
    });

    _animationController.forward();
    _fetchCodes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  Future<void> _fetchCodes() async {
    try {
      final int? usrCodigo = await _apiService.ObtenerCodUsuarioSeguro(); // Obtener código de usuario de manera segura


      if (usrCodigo == null) {
        throw Exception('Usuario no autenticado');
      }

      final codes = await _apiService.getAccountsAndGenerateCodes(usrCodigo);
      setState(() {
        _accountCodes = codes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('Escanear código QR'),
            onTap: () {
              Navigator.pop(context);
              _scanQrCode();
            },
          ),
          ListTile(
            leading: const Icon(Icons.keyboard),
            title: const Text('Ingresar clave manualmente'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const RegistrarClave()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Se copió el código al portapapeles')),
    );
  }

  Future<void> _deleteCode(int index) async {
    final catCodigo = _accountCodes[index].catCodigo;

    try {
      final success = await _apiService.deleteTotp(catCodigo);
      if (success) {
        setState(() {
          _accountCodes.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código eliminado correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: No se encontró el registro con ID $catCodigo')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el código: $e  codigoENVIADO:$catCodigo')),
      );
    }
  }

  Future<void> _scanQrCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanerCodigoQr()),
    );

    if (result != null) {
      try {
        final uri = Uri.parse(result);
        if (uri.scheme == 'otpauth' && uri.host == 'totp') {
          final account = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
          final secretKey = uri.queryParameters['secret'] ?? '';

          if (account.isNotEmpty && secretKey.isNotEmpty) {
            final usrCodigo = await _apiService.ObtenerCodUsuarioSeguro(); // Obtener código de usuario de manera segura


            if (usrCodigo != null) {
              final model = AuthenticadorModel(account: account, secretKey: secretKey);
              await _apiService.insertNuevoTotp(usrCodigo, model);
              _fetchCodes();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Clave registrada para $account')),
              );
            } else {
              throw Exception('Usuario no autenticado');
            }
          } else {
            throw Exception('QR inválido');
          }
        } else {
          throw Exception('Formato de QR no soportado');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar el QR: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autenticador'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCodes,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: _accountCodes.length,
            itemBuilder: (context, index) {
              final accountCode = _accountCodes[index];
              return Dismissible(
                key: Key(accountCode.account),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                onDismissed: (direction) {
                  _deleteCode(index);
                },
                child: GestureDetector(
                  onLongPress: () => _copyToClipboard(accountCode.code),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {},
                      highlightColor: Colors.blue.withOpacity(0.2),
                      splashColor: Colors.blue.withOpacity(0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: 1 - _animationController.value,
                                color: Colors.blue,
                                backgroundColor: Colors.grey[300],
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  accountCode.account,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  accountCode.code.split('').join(' '),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
