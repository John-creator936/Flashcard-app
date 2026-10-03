import 'package:flashcard_app/database/card_repository.dart';
import 'package:flashcard_app/database/deck_repository.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/page/create_deck_page.dart';
import 'package:flashcard_app/page/flashcard_study_page.dart';
import 'package:flutter/material.dart';

class DeckDetailPage extends StatefulWidget {
  final Deck deck;
  const DeckDetailPage({super.key, required this.deck});

  @override
  State<DeckDetailPage> createState() => _DeckDetailPageState();
}

class _DeckDetailPageState extends State<DeckDetailPage> {
  late Deck currentDeck;
  List<Flashcard> cards = [];

  @override
  void initState() {
    super.initState();
    currentDeck = widget.deck;
    _loadCards();
  }

  Future<void> _loadCards() async {
    final loadedCards = await CardRepository().readCardsByDeck(widget.deck.id!);
    setState(() {
      cards = loadedCards;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentDeck.name),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateDeckPage(existingDeck: widget.deck),
                ),
              );
              _loadCards();
              Deck newDeck = await DeckRepository().readDeck(currentDeck.id!);
              setState(() {
                currentDeck = newDeck;
              });
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(cards[index].term),
            subtitle: Text(cards[index].definition),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardStudyPage(flashcards: cards),
            ),
          );
        },
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
