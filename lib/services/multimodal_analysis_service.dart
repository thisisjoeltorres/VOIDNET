import 'dart:io';
import 'audio_metadata_analyzer.dart';
import 'text_nlp_analyzer.dart';

class MultimodalAnalysisService {
  /// Une texto + metadata del audio
  static Map<String, dynamic> analyzeAudioMessage({
    required File audioFile,
    required String transcription,
  }) {
    final audioMetadata = AudioMetadataAnalyzer.analyze(
      audioFile: audioFile,
      transcription: transcription,
    );

    final textAnalysis = TextPLNAnalyzer.analyze(transcription);

    return {
      "fuente": "audio_importado",
      "transcripcion": transcription,
      "audio_metadata": audioMetadata,
      "analisis_texto": textAnalysis,
    };
  }
}
