import 'package:flashcard_app/database/deck_repository.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/page/deck_detail_page.dart';
import 'package:flutter/material.dart';

class DeckTile extends StatelessWidget {
  final Deck deck;
  final VoidCallback onDeckChanged;
  final int cardCount;
  const DeckTile({
    super.key,
    required this.deck,
    required this.onDeckChanged,
    required this.cardCount,
  });

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

  String get _subtitle {
    if (deck.deckType == 'translation') {
      return 'Vocabulaire · ${deck.termLanguage ?? '?'} → ${deck.definitionLanguage ?? '?'}';
    }
    if (deck.deckType == 'definition') {
      return 'Définitions';
    }
    return 'Réponses courtes';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeckDetailPage(deck: deck)),
        );
        onDeckChanged();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 300,
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
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
            Text("$cardCount ${(cardCount > 1) ? "cartes" : "carte"}"),
          ],
        ),
      ),
    );
  }
}
