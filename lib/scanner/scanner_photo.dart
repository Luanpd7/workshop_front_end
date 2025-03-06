import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class NotaFiscalScanner extends StatefulWidget {
  @override
  _NotaFiscalScannerState createState() => _NotaFiscalScannerState();
}

class _NotaFiscalScannerState extends State<NotaFiscalScanner> {
  File? _image;
  String _textoExtraido = "Nenhum texto extraído ainda.";

  final ImagePicker _picker = ImagePicker();

  Future<void> _capturarImagem() async {
    // Solicitar permissão para a câmera
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
        _extrairTexto();
      }
    } else {
      print("Permissão negada.");
    }
  }

  Future<void> _extrairTexto() async {
    if (_image == null) return;

    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(_image!);

    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      _textoExtraido = recognizedText.text.isNotEmpty ? recognizedText.text : "Nenhum texto detectado.";
    });

    textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Digitalizar Nota Fiscal")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image != null ? Image.file(_image!) : Icon(Icons.camera_alt, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _capturarImagem,
            icon: Icon(Icons.camera),
            label: Text("Tirar Foto"),
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Text(_textoExtraido, style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
