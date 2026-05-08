import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diagnosis_result.dart';

class HistoryService {
  static const String _key = 'rosas_check_history';

  static Future<List<AnalysisSession>> cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((j) => AnalysisSession.fromJson(j))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> guardarSesion(AnalysisSession sesion) async {
    final prefs = await SharedPreferences.getInstance();
    final sesiones = await cargarHistorial();
    sesiones.insert(0, sesion);
    // Guardar máximo 50 sesiones
    final limitadas = sesiones.take(50).toList();
    await prefs.setString(
      _key,
      jsonEncode(limitadas.map((s) => s.toJson()).toList()),
    );
  }

  static Future<void> eliminarSesion(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final sesiones = await cargarHistorial();
    sesiones.removeWhere((s) => s.id == id);
    await prefs.setString(
      _key,
      jsonEncode(sesiones.map((s) => s.toJson()).toList()),
    );
  }

  static Future<void> limpiarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
