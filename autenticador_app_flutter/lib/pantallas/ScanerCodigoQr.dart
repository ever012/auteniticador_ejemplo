import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanerCodigoQr extends StatefulWidget {
  const ScanerCodigoQr({Key? key}) : super(key: key);

  @override
  _ScanerCodigoQrState createState() => _ScanerCodigoQrState();
}

class _ScanerCodigoQrState extends State<ScanerCodigoQr> {
  final MobileScannerController _controller = MobileScannerController(
    torchEnabled: false, // Linterna desactivada por defecto
    formats: [BarcodeFormat.qrCode], // Detecta solo códigos QR
  );
  bool _isScanning = true; // Bandera para evitar múltiples lecturas

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcodeDetection(BarcodeCapture barcodeCapture) async {
    if (!_isScanning) return; // Si ya se está procesando un QR, no hacer nada
    setState(() {
      _isScanning = false; // Bloquear detección adicional
    });

    try {
      final Barcode? barcode = barcodeCapture.barcodes.first;
      if (barcode != null && barcode.rawValue != null) {
        debugPrint('Código QR detectado: ${barcode.rawValue}');
        // Detenemos la cámara antes de navegar
        await _controller.stop();
        Navigator.pop(context, barcode.rawValue); // Devuelve el valor escaneado
      } else {
        setState(() {
          _isScanning = true; // Reactivar detección en caso de error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se detectó ningún código QR válido')),
        );
      }
    } catch (e) {
      setState(() {
        _isScanning = true; // Reactivar detección en caso de error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al procesar el código QR')),
      );
      debugPrint('Error al procesar el código QR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              _controller.toggleTorch(); // Alterna la linterna
            },
          ),
        ],
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: _handleBarcodeDetection,

      ),
    );
  }
}
