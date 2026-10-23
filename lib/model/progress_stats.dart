class ProgressStats {
  final int reviewedToday;
  final int newCount;
  final int learningCount;
  final int masteredCount;

  const ProgressStats({
    required this.reviewedToday,
    required this.newCount,
    required this.learningCount,
    required this.masteredCount,
  });

  static const int masteredThreshold = 21;
}
