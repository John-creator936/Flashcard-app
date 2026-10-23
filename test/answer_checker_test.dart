import 'package:flashcard_app/model/answer_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isCorrect', () {
    test('réponse identique', () {
      expect(AnswerChecker.isCorrect('la machine', 'la machine'), isTrue);
    });
    test('apostrophe typographique acceptée', () {
      expect(AnswerChecker.isCorrect("l’usine", "l'usine"), isTrue);
    });
    test('espaces au début et à la fin ignorés', () {
      expect(AnswerChecker.isCorrect('  la machine ', 'la machine'), isTrue);
    });
    test('espaces multiples au milieu ignorés', () {
      expect(AnswerChecker.isCorrect('le  produit', 'le produit'), isTrue);
    });
    test('majuscule toujours importante', () {
      expect(AnswerChecker.isCorrect('haus', 'Haus'), isFalse);
    });
    test('mauvaise réponse', () {
      expect(AnswerChecker.isCorrect('la fabrique', "l'usine"), isFalse);
    });
    test('réponse vide', () {
      expect(AnswerChecker.isCorrect('', 'la machine'), isFalse);
    });
  });
}
