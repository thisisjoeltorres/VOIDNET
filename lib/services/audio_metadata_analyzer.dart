import 'dart:io';

class AudioMetadataAnalyzer {
  /// Simulación ligera de análisis de metadata
  /// (duración real puede venir del plugin que uses luego)
  static Map<String, dynamic> analyze({
    required File audioFile,
    required String transcription,
  }) {
    final wordCount = transcription.split(RegExp(r'\s+')).length;

    // ⚠️ Placeholder: duración estimada (en segundos)
    // Puedes reemplazarlo luego con un plugin real
    final estimatedDurationSec = wordCount / 2; // habla lenta promedio

    final wordsPerMinute = (wordCount / (estimatedDurationSec / 60)).round();

    return {
      "duracion_seg": estimatedDurationSec.round(),
      "palabras_totales": wordCount,
      "velocidad_habla": _speechSpeed(wordsPerMinute),
      "pausas_largas": transcription.contains("...") || transcription.contains("—"),
    };
  }

  static String _speechSpeed(int wpm) {
    if (wpm < 90) return "lenta";
    if (wpm < 130) return "normal";
    return "rapida";
  }
}
