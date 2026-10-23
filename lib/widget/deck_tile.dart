import 'package:flashcard_app/database/deck_repository.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/model/text_utils.dart';
import 'package:flashcard_app/page/deck_detail_page.dart';
import 'package:flutter/material.dart';

/// Carte d'un deck dans « Mes unités » : nom, type, nombre de cartes,
/// et une poubelle pour le supprimer.
class DeckTile extends StatelessWidget {
  final Deck deck;

  /// Appelé après une suppression ou un retour du deck, pour recharger l'accueil.
  final VoidCallback onDeckChanged;
  final int cardCount;
  const DeckTile({
    super.key,
    required this.deck,
    required this.onDeckChanged,
    required this.cardCount,
  });

  /// Demande confirmation avant de supprimer le deck.
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Effacer l'unité ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Non"),
          ),
          TextButton(
            onPressed: () async {
              await DeckRepository().delete(deck.id!);
              if (context.mounted) {
                Navigator.pop(context);
                onDeckChanged();
              }
            },
            child: const Text("Oui"),
          ),
        ],
      ),
    );
  }

  /// Type du deck, avec ses langues pour le vocabulaire (« de → fr »).
  String get _subtitle {
    if (deck.deckType == 'translation') {
      if (deck.termLanguage == null && deck.definitionLanguage == null) {
        return 'Vocabulaire';
      }
      return 'Vocabulaire · ${deck.termLanguage ?? '?'} → ${deck.definitionLanguage ?? '?'}';
    }
    if (deck.deckType == 'definition') {
      return 'Définitions';
    }
    return 'Réponses courtes';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeckDetailPage(deck: deck),
              ),
            );
            onDeckChanged();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        deck.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _confirmDelete(context),
                      icon: Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                Text(
                  _subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Spacer(),
                Text(cardCountLabel(cardCount)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
