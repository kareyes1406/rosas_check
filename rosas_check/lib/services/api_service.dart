import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/diagnosis_result.dart';

class ApiService {
  static const String _baseUrl =
      'https://kareyes-rose-disease-detector1.hf.space';

  // Analiza UNA imagen y devuelve ImageResult
  static Future<ImageResult> analizarImagen(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/predecir'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Error del servidor: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded.containsKey('error')) {
      throw Exception('Error en predicción: ${decoded['error']}');
    }

    final porcentajes = Map<String, double>.from(
      (decoded['porcentajes'] as Map).map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      ),
    );

    return ImageResult(
      imagePath: imageFile.path,
      prediccion: decoded['prediccion'],
      confianza: (decoded['confianza'] as num).toDouble(),
      porcentajes: porcentajes,
    );
  }

  // Analiza MÚLTIPLES imágenes con progreso
  static Future<List<ImageResult>> analizarMultiples(
    List<File> imagenes, {
    void Function(int completadas, int total)? onProgress,
  }) async {
    final List<ImageResult> resultados = [];

    for (int i = 0; i < imagenes.length; i++) {
      try {
        final resultado = await analizarImagen(imagenes[i]);
        resultados.add(resultado);
      } catch (e) {
        // Si falla una imagen, agrega un resultado de error y continúa
        resultados.add(ImageResult(
          imagePath: imagenes[i].path,
          prediccion: 'Error',
          confianza: 0,
          porcentajes: {},
        ));
      }
      onProgress?.call(i + 1, imagenes.length);
    }

    return resultados;
  }

  // Verifica si la API está disponible
  static Future<bool> verificarConexion() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
