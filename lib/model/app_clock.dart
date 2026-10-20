/// Date actuelle de l'appli, avec un décalage possible pour les tests.
class AppClock {
  /// Nombre de jours ajoutés à la date réelle. Doit rester à 0 en temps normal.
  static int offsetDays = 0;

  static DateTime now() => DateTime.now().add(Duration(days: offsetDays));
}
