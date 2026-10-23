class AnswerChecker {
  static String normalize(String text) {
    String result = text.replaceAll("’", "'");
    result = result.replaceAll(RegExp(r'\s+'), " ");
    return result.trim();
  }

  static bool isCorrect(String given, String expected) {
    return normalize(given) == normalize(expected);
  }
}
