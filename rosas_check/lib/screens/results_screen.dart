import 'dart:io';
import 'package:flutter/material.dart';
import '../models/diagnosis_result.dart';
import 'detail_screen.dart';

class ResultsScreen extends StatelessWidget {
  final AnalysisSession sesion;

  const ResultsScreen({super.key, required this.sesion});

  Color _getColor(String prediccion) {
    final colors = {
      'Black Spot': const Color(0xFF1a1a2e),
      'Fresh Leaf': const Color(0xFF2d6a4f),
      'Insectos': const Color(0xFF774936),
      'Mildew': const Color(0xFF6c757d),
      'Mosaico': const Color(0xFFe9c46a),
      'Roya': const Color(0xFFe76f51),
      'Error': Colors.grey,
    };
    return colors[prediccion] ?? const Color(0xFF2d6a4f);
  }

  @override
  Widget build(BuildContext context) {
    final resumen = sesion.resumen;
    final total = sesion.resultados.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      appBar: AppBar(
        title: const Text('Resultados'),
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Cabecera resumen
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF1B4332),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$total imagen${total != 1 ? 'es' : ''} analizadas',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Chips de resumen
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: resumen.entries.map((e) {
                      final pct = (e.value / total * 100).round();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getColor(e.key).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${ImageResult.diseaseInfo[e.key]?.emoji ?? '🌿'} ${e.key}: ${e.value} ($pct%)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
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

          // Título lista
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Detalle por imagen',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332),
                ),
              ),
            ),
          ),

          // Lista de resultados
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final r = sesion.resultados[index];
                final info = ImageResult.diseaseInfo[r.prediccion];
                final color = _getColor(r.prediccion);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(resultado: r),
                      ),
                    ),
                    child: Container(
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
                      child: Row(
                        children: [
                          // Imagen
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(14),
                            ),
                            child: Image.file(
                              File(r.imagePath),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          // Info
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Imagen ${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        info?.emoji ?? '🌿',
                                        style:
                                            const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          info?.nombre ?? r.prediccion,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: color,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Mini barra de confianza
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: r.confianza / 100,
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    color),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${r.confianza.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.chevron_right,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: sesion.resultados.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}
