class TextPLNAnalyzer {
  static final List<String> negativeKeywords = [
    "triste",
    "cansado",
    "agotado",
    "solo",
    "inútil",
    "mal",
    "vacío",
    "no puedo",
    "sin ganas",
  ];

  static final List<String> repetitionIndicators = [
    "siempre",
    "nunca",
    "todo el tiempo",
  ];

  static Map<String, dynamic> analyze(String text) {
    final lowerText = text.toLowerCase();

    int negativeHits = negativeKeywords
        .where((word) => lowerText.contains(word))
        .length;

    int repetitionHits = repetitionIndicators
        .where((word) => lowerText.contains(word))
        .length;

    return {
      "lenguaje_negativo": _negativityLevel(negativeHits),
      "repeticiones": repetitionHits > 0,
    };
  }

  static String _negativityLevel(int hits) {
    if (hits == 0) return "bajo";
    if (hits <= 2) return "moderado";
    return "alto";
  }
}
