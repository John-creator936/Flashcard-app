class StudyOptions {
  final bool reversed;
  final bool shuffled;

  const StudyOptions({this.reversed = false, this.shuffled = false});

  StudyOptions copy({bool? reversed, bool? shuffled}) => StudyOptions(
    reversed: reversed ?? this.reversed,
    shuffled: shuffled ?? this.shuffled,
  );
}
