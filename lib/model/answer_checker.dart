/// Compare la réponse tapée en mode écrit avec la réponse attendue.
class AnswerChecker {
  /// Rend deux textes comparables : apostrophe typographique ’ remplacée
  /// par ', espaces multiples réduits à un seul, et espaces au bord retirés.
  ///
  /// Le clavier de l'iPhone remplace automatiquement ' par ’ : sans cette
  /// étape, « l’usine » serait comptée fausse face à « l'usine ».
  static String normalize(String text) {
    String result = text.replaceAll("’", "'");
    result = result.replaceAll(RegExp(r'\s+'), " ");
    return result.trim();
  }

  /// Vrai si les deux réponses sont identiques une fois normalisées.
  /// La casse et les accents comptent toujours.
  static bool isCorrect(String given, String expected) {
    return normalize(given) == normalize(expected);
  }
}
