import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/sm2.dart';

/// Crée une nouvelle carte, jamais révisée.
Flashcard newCard() => Flashcard(
  term: 'der Hund',
  definition: 'le chien',
  createdTime: DateTime.now(),
);

void main() {
  group('SM-2 en mode écrit (poids 1)', () {
    test('Trois réussites : 1, 6 puis 15 jours', () {
      var card = newCard();

      card = SM2.review(card, isSuccess: true, weight: 1);
      expect(card.intervalDays, 1);

      card = SM2.review(card, isSuccess: true, weight: 1);
      expect(card.intervalDays, 6);

      card = SM2.review(card, isSuccess: true, weight: 1);
      expect(card.intervalDays, closeTo(15, 0.001));
      expect(card.easeFactor, closeTo(2.5, 0.001)); // q = 4 : facteur inchangé
    });

    test('Un échec : facteur −0,32, points à 0, intervalle 1 jour', () {
      var card = newCard();
      for (var i = 0; i < 3; i++) {
        card = SM2.review(card, isSuccess: true, weight: 1);
      }

      card = SM2.review(card, isSuccess: false, weight: 1);
      expect(card.easeFactor, closeTo(2.18, 0.001));
      expect(card.points, 0);
      expect(card.intervalDays, 1);
      expect(card.lastReviewedTime, isNotNull);
    });

    test('Le facteur ne descend jamais sous 1,3', () {
      var card = newCard();
      for (var i = 0; i < 6; i++) {
        card = SM2.review(card, isSuccess: false, weight: 1);
      }
      expect(card.easeFactor, closeTo(1.3, 0.001));
    });
  });

  group('Poids en QCM / flashcard (poids 0,5)', () {
    test('Deux réussites en QCM = une réussite en écrit', () {
      var card = newCard();

      card = SM2.review(card, isSuccess: true, weight: 0.5);
      card = SM2.review(card, isSuccess: true, weight: 0.5);
      expect(card.points, 1);
      expect(card.intervalDays, 1);
    });

    test('Six réussites en QCM = trois réussites en écrit (15 jours)', () {
      var card = newCard();
      final expectedIntervals = [1.0, 1.0, 6.0, 6.0, 9.487, 15.0];

      for (final expected in expectedIntervals) {
        card = SM2.review(card, isSuccess: true, weight: 0.5);
        expect(card.intervalDays, closeTo(expected, 0.001));
      }
    });
  });
}
