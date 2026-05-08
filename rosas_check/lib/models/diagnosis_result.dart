class DiseaseInfo {
  final String nombre;
  final String emoji;
  final String descripcion;
  final List<String> tratamiento;
  final String color;

  const DiseaseInfo({
    required this.nombre,
    required this.emoji,
    required this.descripcion,
    required this.tratamiento,
    required this.color,
  });
}

class ImageResult {
  final String imagePath;
  final String prediccion;
  final double confianza;
  final Map<String, double> porcentajes;

  const ImageResult({
    required this.imagePath,
    required this.prediccion,
    required this.confianza,
    required this.porcentajes,
  });

  static const Map<String, DiseaseInfo> diseaseInfo = {
    'Black Spot': DiseaseInfo(
      nombre: 'Mancha Negra',
      emoji: '🖤',
      descripcion:
          'Enfermedad fúngica causada por Diplocarpon rosae. Produce manchas negras en las hojas que amarillean y caen.',
      tratamiento: [
        'Retirar hojas infectadas inmediatamente',
        'Aplicar fungicida con cobre o azufre',
        'Mejorar la circulación de aire entre plantas',
        'Evitar mojar las hojas al regar',
        'Aplicar fungicida preventivo cada 7-10 días',
      ],
      color: '#1a1a2e',
    ),
    'Fresh Leaf': DiseaseInfo(
      nombre: 'Hoja Sana',
      emoji: '🌿',
      descripcion: 'La rosa está en excelente estado. Las hojas muestran un color verde vibrante sin signos de enfermedad.',
      tratamiento: [
        'Continuar con el riego regular',
        'Mantener fertilización mensual',
        'Revisar periódicamente para detección temprana',
        'Podar ramas secas cuando sea necesario',
      ],
      color: '#2d6a4f',
    ),
    'Insectos': DiseaseInfo(
      nombre: 'Plaga de Insectos',
      emoji: '🐛',
      descripcion: 'Se detecta presencia de insectos dañinos como áfidos, trips o ácaros que afectan el desarrollo de la planta.',
      tratamiento: [
        'Aplicar insecticida sistémico o de contacto',
        'Usar jabón potásico como alternativa orgánica',
        'Revisar el envés de las hojas regularmente',
        'Introducir depredadores naturales (mariquitas)',
        'Repetir tratamiento cada 5-7 días',
      ],
      color: '#774936',
    ),
    'Mildew': DiseaseInfo(
      nombre: 'Mildiu Polvoroso',
      emoji: '🤍',
      descripcion: 'Hongo Podosphaera pannosa que cubre hojas y tallos con polvo blanco. Se desarrolla con alta humedad y temperaturas cálidas.',
      tratamiento: [
        'Aplicar fungicida con bicarbonato de sodio',
        'Usar azufre micronizado en pulverización',
        'Podar y eliminar partes muy afectadas',
        'Reducir la humedad ambiental',
        'Aplicar tratamiento preventivo en temporada húmeda',
      ],
      color: '#6c757d',
    ),
    'Mosaico': DiseaseInfo(
      nombre: 'Virus del Mosaico',
      emoji: '🟡',
      descripcion: 'Enfermedad viral que produce patrones de mosaico amarillo-verde en las hojas, reduciendo el vigor de la planta.',
      tratamiento: [
        'No existe cura — retirar plantas muy afectadas',
        'Controlar insectos vectores (áfidos)',
        'Desinfectar herramientas de poda con alcohol',
        'No propagar esquejes de plantas infectadas',
        'Usar variedades resistentes en nuevas siembras',
      ],
      color: '#e9c46a',
    ),
    'Roya': DiseaseInfo(
      nombre: 'Roya',
      emoji: '🟠',
      descripcion: 'Hongo Phragmidium mucronatum que produce pústulas anaranjadas en el envés de las hojas, debilitando la planta.',
      tratamiento: [
        'Aplicar fungicida con triazoles o estrobilurinas',
        'Retirar y destruir hojas infectadas',
        'Evitar el riego por aspersión',
        'Mejorar la ventilación de las plantas',
        'Aplicar preventivamente al inicio de la temporada',
      ],
      color: '#e76f51',
    ),
  };
}

class AnalysisSession {
  final String id;
  final DateTime fecha;
  final List<ImageResult> resultados;
  final int totalImagenes;

  const AnalysisSession({
    required this.id,
    required this.fecha,
    required this.resultados,
    required this.totalImagenes,
  });

  Map<String, int> get resumen {
    final Map<String, int> counts = {};
    for (final r in resultados) {
      counts[r.prediccion] = (counts[r.prediccion] ?? 0) + 1;
    }
    return counts;
  }

  String get prediccionMasFrecuente {
    if (resultados.isEmpty) return '';
    final resumenMap = resumen;
    return resumenMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fecha': fecha.toIso8601String(),
        'totalImagenes': totalImagenes,
        'resultados': resultados
            .map((r) => {
                  'imagePath': r.imagePath,
                  'prediccion': r.prediccion,
                  'confianza': r.confianza,
                  'porcentajes': r.porcentajes,
                })
            .toList(),
      };

  factory AnalysisSession.fromJson(Map<String, dynamic> json) {
    return AnalysisSession(
      id: json['id'],
      fecha: DateTime.parse(json['fecha']),
      totalImagenes: json['totalImagenes'],
      resultados: (json['resultados'] as List)
          .map((r) => ImageResult(
                imagePath: r['imagePath'],
                prediccion: r['prediccion'],
                confianza: r['confianza'].toDouble(),
                porcentajes: Map<String, double>.from(
                  r['porcentajes'].map((k, v) => MapEntry(k, v.toDouble())),
                ),
              ))
          .toList(),
    );
  }
}
