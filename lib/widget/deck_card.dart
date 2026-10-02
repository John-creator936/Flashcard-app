import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/page/deck_detail_page.dart';
import 'package:flutter/material.dart';

class DeckCard extends StatelessWidget {
  final Deck deck;
  const DeckCard({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onLongPress: () {
      //   AlertDialog(
      //     title: Text("Effacer l'unité ?"),
      //     actions: [
      //       TextButton(onPressed: onPressed, child: const Text("Oui")),
      //       TextButton(onPressed: onPressed, child: const Text("Non")),
      //     ],

      //   );
      // },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeckDetailPage(deck: deck)),
        );
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
