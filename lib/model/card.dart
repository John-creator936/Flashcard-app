/// Nom de la table des cartes.
final String tableCards = 'cards';

/// Noms des colonnes de la table `cards`.
class CardFields {
  static final List<String> values = [
    id,
    term,
    definition,
    time,
    easeFactor,
    points,
    intervalDays,
    lastReviewedTime,
  ];

  static final String id = '_id';
  static final String term = 'term';
  static final String definition = 'definition';
  static final String time = 'time';
  static final String easeFactor = 'easeFactor';
  static final String points = 'points';
  static final String intervalDays = 'intervalDays';
  static final String lastReviewedTime = 'lastReviewedTime';
}

/// Une carte : un terme, sa définition et son progrès SM-2.
///
/// Le nom évite le conflit avec le widget `Card` de Material.
class Flashcard {
  final int? id;
  final String term;
  final String definition;
  final DateTime createdTime;

  /// Facteur de facilité SM-2 : plus il est grand, plus l'intervalle grandit vite.
  final double easeFactor;

  /// Points gagnés depuis le dernier échec, selon le poids de chaque mode.
  final double points;

  /// Nombre de jours avant la prochaine révision.
  final double intervalDays;

  /// Date de la dernière révision, ou `null` si la carte est nouvelle.
  final DateTime? lastReviewedTime;

  const Flashcard({
    this.id,
    required this.term,
    required this.definition,
    required this.createdTime,
    this.easeFactor = 2.5,
    this.points = 0,
    this.intervalDays = 0,
    this.lastReviewedTime,
  });

  /// Copie la carte en remplaçant seulement les champs donnés.
  Flashcard copy({
    int? id,
    String? term,
    String? definition,
    DateTime? createdTime,
    double? easeFactor,
    double? points,
    double? intervalDays,
    DateTime? lastReviewedTime,
  }) => Flashcard(
    id: id ?? this.id,
    term: term ?? this.term,
    definition: definition ?? this.definition,
    createdTime: createdTime ?? this.createdTime,
    easeFactor: easeFactor ?? this.easeFactor,
    points: points ?? this.points,
    intervalDays: intervalDays ?? this.intervalDays,
    lastReviewedTime: lastReviewedTime ?? this.lastReviewedTime,
  );

  /// Crée une carte à partir d'une ligne de la base.
  static Flashcard fromJson(Map<String, Object?> json) => Flashcard(
    id: json[CardFields.id] as int?,
    term: json[CardFields.term] as String,
    definition: json[CardFields.definition] as String,
    createdTime: DateTime.parse(json[CardFields.time] as String),
    easeFactor: (json[CardFields.easeFactor] as num).toDouble(),
    points: (json[CardFields.points] as num).toDouble(),
    intervalDays: (json[CardFields.intervalDays] as num).toDouble(),
    lastReviewedTime: (json[CardFields.lastReviewedTime] == null)
        ? null
        : DateTime.parse(json[CardFields.lastReviewedTime] as String),
  );

  /// Convertit la carte en ligne pour la base.
  Map<String, Object?> toJson() => {
    CardFields.id: id,
    CardFields.term: term,
    CardFields.definition: definition,
    CardFields.time: createdTime.toIso8601String(),
    CardFields.easeFactor: easeFactor,
    CardFields.points: points,
    CardFields.intervalDays: intervalDays,
    CardFields.lastReviewedTime: lastReviewedTime?.toIso8601String(),
  };
}
