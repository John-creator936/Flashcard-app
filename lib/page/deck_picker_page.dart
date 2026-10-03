import 'package:flashcard_app/database/deck_repository.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flutter/material.dart';

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
    setState(() {
      allDecks = decks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
