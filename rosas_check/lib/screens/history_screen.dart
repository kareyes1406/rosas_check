import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diagnosis_result.dart';
import '../services/history_service.dart';
import 'results_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<AnalysisSession> _sesiones = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    final sesiones = await HistoryService.cargarHistorial();
    setState(() {
      _sesiones = sesiones;
      _loading = false;
    });
  }

  Future<void> _eliminar(String id) async {
    await HistoryService.eliminarSesion(id);
    _cargar();
  }

  Future<void> _limpiarTodo() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpiar historial'),
        content:
            const Text('¿Eliminar todo el historial de análisis?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await HistoryService.limpiarHistorial();
      _cargar();
    }
  }

  Color _getColor(String prediccion) {
    final colors = {
      'Black Spot': const Color(0xFF1a1a2e),
      'Fresh Leaf': const Color(0xFF2d6a4f),
      'Insectos': const Color(0xFF774936),
      'Mildew': const Color(0xFF6c757d),
      'Mosaico': const Color(0xFFe9a020),
      'Roya': const Color(0xFFe76f51),
    };
    return colors[prediccion] ?? const Color(0xFF2d6a4f);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      appBar: AppBar(
        title: const Text('Historial'),
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_sesiones.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _limpiarTodo,
              tooltip: 'Limpiar todo',
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2D6A4F)))
          : _sesiones.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🌱', style: TextStyle(fontSize: 60)),
                      SizedBox(height: 16),
                      Text(
                        'No hay análisis guardados',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2D6A4F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Analiza tus rosas para ver el historial',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  color: const Color(0xFF2D6A4F),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sesiones.length,
                    itemBuilder: (context, index) {
                      final sesion = _sesiones[index];
                      final resumen = sesion.resumen;
                      final principal = sesion.prediccionMasFrecuente;
                      final info = ImageResult.diseaseInfo[principal];

                      return Dismissible(
                        key: Key(sesion.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _eliminar(sesion.id),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ResultsScreen(sesion: sesion),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm')
                                          .format(sesion.fecha),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '${sesion.totalImagenes} imágenes',
                                      style: const TextStyle(
                                        color: Color(0xFF2D6A4F),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      info?.emoji ?? '🌿',
                                      style:
                                          const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Principal: ${info?.nombre ?? principal}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: _getColor(principal),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: resumen.entries.map((e) {
                                    final d = ImageResult.diseaseInfo[e.key];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getColor(e.key)
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${d?.emoji ?? ''} ${e.value}',
                                        style: TextStyle(
                                          color: _getColor(e.key),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
