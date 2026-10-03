import 'package:flashcard_app/database/deck_repository.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/page/deck_detail_page.dart';
import 'package:flutter/material.dart';

class DeckTile extends StatelessWidget {
  final Deck deck;
  final VoidCallback onDeckChanged;
  const DeckTile({super.key, required this.deck, required this.onDeckChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
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
      },
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeckDetailPage(deck: deck)),
        );
        onDeckChanged();
      },
      child: Container(
        width: 300,
        height: 190,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Text(deck.name),
      ),
    );
  }
}
