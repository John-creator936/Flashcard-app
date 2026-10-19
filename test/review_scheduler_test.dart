import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/review_scheduler.dart';

/// « Maintenant » fixe pour tous les tests : 19 octobre 2026, 15 h.
final now = DateTime(2026, 10, 19, 15);

/// Crée une carte, révisée ou non.
Flashcard card(String term, {DateTime? lastReviewed, double interval = 0}) =>
    Flashcard(
      term: term,
      definition: '-',
      createdTime: DateTime(2026, 10, 1),
      lastReviewedTime: lastReviewed,
      intervalDays: interval,
    );

void main() {
  group('isNew / isDue', () {
    test('Une carte nouvelle est nouvelle, mais jamais « due »', () {
      final c = card('nouvelle');
      expect(ReviewScheduler.isNew(c), isTrue);
      expect(ReviewScheduler.isDue(c, now), isFalse);
    });

    test('Révisée hier à 20 h, intervalle 1 → due aujourd\'hui à 15 h', () {
      final c = card(
        'hier',
        lastReviewed: DateTime(2026, 10, 18, 20),
        interval: 1,
      );
      expect(ReviewScheduler.isDue(c, now), isTrue);
    });

    test('Révisée aujourd\'hui, intervalle 1 → pas due', () {
      final c = card(
        'aujourdhui',
        lastReviewed: DateTime(2026, 10, 19, 9),
        interval: 1,
      );
      expect(ReviewScheduler.isDue(c, now), isFalse);
    });

    test('Intervalle non entier (9,487) : due seulement après 10 jours', () {
      final apres9 = card(
        '9j',
        lastReviewed: DateTime(2026, 10, 10),
        interval: 9.487,
      );
      final apres10 = card(
        '10j',
        lastReviewed: DateTime(2026, 10, 9),
        interval: 9.487,
      );
      expect(ReviewScheduler.isDue(apres9, now), isFalse);
      expect(ReviewScheduler.isDue(apres10, now), isTrue);
    });
  });

  group('cardsToReview', () {
    // Retard 3 : révisée il y a 3 jours, intervalle 1.
    final tresEnRetard = card(
      'A',
      lastReviewed: DateTime(2026, 10, 16),
      interval: 1,
    );
    // Retard 1,5 : révisée il y a 9 jours, intervalle 6.
    final unPeuEnRetard = card(
      'B',
      lastReviewed: DateTime(2026, 10, 10),
      interval: 6,
    );
    // Nouvelle carte.
    final nouvelle = card('C');
    // Pas encore due : révisée il y a 2 jours, intervalle 6.
    final pasDue = card('D', lastReviewed: DateTime(2026, 10, 17), interval: 6);

    final cartes = [nouvelle, pasDue, unPeuEnRetard, tresEnRetard];

    List<String> terms(List<Flashcard> cards) =>
        cards.map((c) => c.term).toList();

    test(
      'Ordre : dues par retard décroissant, puis nouvelles ; pas les non dues',
      () {
        final result = ReviewScheduler.cardsToReview(cartes, now, 30);
        expect(terms(result), ['A', 'B', 'C']);
      },
    );

    test('La limite coupe la liste (les nouvelles en premier)', () {
      final result = ReviewScheduler.cardsToReview(cartes, now, 2);
      expect(terms(result), ['A', 'B']);
    });

    test('Limite à 0 → aucune carte', () {
      final result = ReviewScheduler.cardsToReview(cartes, now, 0);
      expect(result, isEmpty);
    });
  });
}
