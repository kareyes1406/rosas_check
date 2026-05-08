import 'dart:io';
import 'package:flutter/material.dart';
import '../models/diagnosis_result.dart';

class DetailScreen extends StatelessWidget {
  final ImageResult resultado;

  const DetailScreen({super.key, required this.resultado});

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
    final info = ImageResult.diseaseInfo[resultado.prediccion];
    final color = _getColor(resultado.prediccion);

    // Ordenar porcentajes de mayor a menor
    final sortedPorcentajes = resultado.porcentajes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(resultado.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: color),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          color.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info?.emoji ?? '🌿',
                          style: const TextStyle(fontSize: 40),
                        ),
                        Text(
                          info?.nombre ?? resultado.prediccion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Confianza: ${resultado.confianza.toStringAsFixed(2)}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción
                  if (info != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Descripción',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1B4332),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            info.descripcion,
                            style: const TextStyle(
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Porcentajes por enfermedad
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Probabilidad por enfermedad',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1B4332),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...sortedPorcentajes.map((entry) {
                          final isWinner =
                              entry.key == resultado.prediccion;
                          final barColor = isWinner
                              ? _getColor(entry.key)
                              : Colors.grey.shade300;
                          final diseaseInfo =
                              ImageResult.diseaseInfo[entry.key];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          diseaseInfo?.emoji ?? '🌿',
                                          style:
                                              const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          diseaseInfo?.nombre ?? entry.key,
                                          style: TextStyle(
                                            fontWeight: isWinner
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isWinner
                                                ? _getColor(entry.key)
                                                : Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (isWinner) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _getColor(entry.key)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'GANADOR',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    _getColor(entry.key),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '${entry.value.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        fontWeight: isWinner
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isWinner
                                            ? _getColor(entry.key)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: entry.value / 100,
                                    backgroundColor: Colors.grey.shade100,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            barColor),
                                    minHeight: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tratamiento
                  if (info != null && resultado.prediccion != 'Error') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.healing, color: color, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Tratamiento recomendado',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1B4332),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...info.tratamiento.asMap().entries.map((e) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${e.key + 1}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        e.value,
                                        style: const TextStyle(
                                          height: 1.4,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
