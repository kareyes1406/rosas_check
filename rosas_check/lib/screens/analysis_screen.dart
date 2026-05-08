import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../models/diagnosis_result.dart';
import 'results_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final List<File> _selectedImages = [];
  bool _isAnalyzing = false;
  int _progress = 0;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isEmpty) return;
    setState(() {
      _selectedImages.addAll(images.map((x) => File(x.path)));
    });
  }

  Future<void> _pickFromCamera() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (image == null) return;
    setState(() {
      _selectedImages.add(File(image.path));
    });
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _analyze() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _progress = 0;
    });

    try {
      final resultados = await ApiService.analizarMultiples(
        _selectedImages,
        onProgress: (completadas, total) {
          setState(() => _progress = completadas);
        },
      );

      final sesion = AnalysisSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fecha: DateTime.now(),
        resultados: resultados,
        totalImagenes: _selectedImages.length,
      );

      await HistoryService.guardarSesion(sesion);

      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _selectedImages.clear();
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(sesion: sesion),
        ),
      );
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFF1B4332),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Rosas Check',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                  ),
                ),
                child: const Center(
                  child: Text('🌹', style: TextStyle(fontSize: 50)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botones de selección
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.photo_library,
                          label: 'Galería',
                          subtitle: 'Múltiples fotos',
                          onTap: _isAnalyzing ? null : _pickFromGallery,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.camera_alt,
                          label: 'Cámara',
                          subtitle: 'Tomar foto',
                          onTap: _isAnalyzing ? null : _pickFromCamera,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Contador de imágenes
                  if (_selectedImages.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedImages.length} imagen${_selectedImages.length != 1 ? 'es' : ''} seleccionada${_selectedImages.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF1B4332),
                          ),
                        ),
                        TextButton(
                          onPressed: _isAnalyzing
                              ? null
                              : () => setState(() => _selectedImages.clear()),
                          child: const Text(
                            'Limpiar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Grid de imágenes seleccionadas
                  if (_selectedImages.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _selectedImages[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (!_isAnalyzing)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                  if (_selectedImages.isEmpty)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF52B788).withOpacity(0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🌸', style: TextStyle(fontSize: 48)),
                            SizedBox(height: 12),
                            Text(
                              'Selecciona fotos de tus rosas',
                              style: TextStyle(
                                color: Color(0xFF52B788),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Puedes seleccionar múltiples imágenes',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Barra de progreso durante análisis
                  if (_isAnalyzing) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Analizando $_progress de ${_selectedImages.length} imágenes...',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B4332),
                            ),
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: _selectedImages.isEmpty
                                ? 0
                                : _progress / _selectedImages.length,
                            backgroundColor: const Color(0xFFD8F3DC),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF2D6A4F)),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Botón analizar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_selectedImages.isEmpty || _isAnalyzing)
                          ? null
                          : _analyze,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D6A4F),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: _isAnalyzing
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Analizando...',
                                    style: TextStyle(fontSize: 16)),
                              ],
                            )
                          : Text(
                              _selectedImages.isEmpty
                                  ? 'Selecciona imágenes primero'
                                  : 'Analizar ${_selectedImages.length} imagen${_selectedImages.length != 1 ? 'es' : ''}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D6A4F).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2D6A4F), size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
                fontSize: 15,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
