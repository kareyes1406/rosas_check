# 🌹 Rosas Check

App Flutter para detectar enfermedades en rosas usando IA.

## Enfermedades detectadas
- 🖤 Black Spot (Mancha Negra)
- 🌿 Fresh Leaf (Hoja Sana)
- 🐛 Insectos
- 🤍 Mildew (Mildiu Polvoroso)
- 🟡 Mosaico (Virus del Mosaico)
- 🟠 Roya

## Funcionalidades
- Analizar múltiples imágenes a la vez (galería o cámara)
- Ver porcentaje de probabilidad por enfermedad en cada imagen
- Historial de análisis anteriores
- Información de tratamiento por enfermedad

## Estructura
```
lib/
  main.dart
  models/
    diagnosis_result.dart
  services/
    api_service.dart
    history_service.dart
  screens/
    home_screen.dart
    analysis_screen.dart
    results_screen.dart
    detail_screen.dart
    history_screen.dart
```

## API
La app se conecta a HuggingFace Space:
`https://kareyes-rose-disease-detector1.hf.space`

## Build APK
GitHub Actions genera el APK automáticamente en cada push a `main`.
Se descarga desde la pestaña **Actions** → último workflow → **Artifacts**.
