import 'package:flashcard_app/database/deck_repository.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flutter/material.dart';

/// Liste des decks où choisir celui dont on veut reprendre des cartes.
///
/// Renvoie le deck choisi, ou `null` si l'utilisateur revient en arrière.
class DeckPickerPage extends StatefulWidget {
  const DeckPickerPage({super.key});

  @override
  State<DeckPickerPage> createState() => _DeckPickerPageState();
}

class _DeckPickerPageState extends State<DeckPickerPage> {
  List<Deck> allDecks = [];

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    final decks = await DeckRepository().readAllDecks();
    if (!mounted) return;
    setState(() {
      allDecks = decks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choisir un deck")),
      body: ListView.builder(
        itemCount: allDecks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(allDecks[index].name),
            onTap: () {
              Navigator.pop(context, allDecks[index]);
            },
          );
        },
      ),
    );
  }
}
