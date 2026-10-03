import 'package:flashcard_app/database/card_repository.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flutter/material.dart';

class CardPickerPage extends StatefulWidget {
  final Deck deck;
  const CardPickerPage({super.key, required this.deck});

  @override
  State<CardPickerPage> createState() => _CardPickerPageState();
}

class _CardPickerPageState extends State<CardPickerPage> {
  Set<int> selectedCardIds = {};
  List<Flashcard> cards = [];

  @override
  void initState() {
    super.initState();
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
        title: Text("Sauvegardage des cartes"),
        actions: [
          IconButton(
            onPressed: () {
              List<Flashcard> selectedCards = cards
                  .where((card) => selectedCardIds.contains(card.id))
                  .toList();
              Navigator.pop(context, selectedCards);
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(cards[index].term),
            subtitle: Text(cards[index].definition),
            value: selectedCardIds.contains(cards[index].id),
            onChanged: (bool? checked) {
              if (checked == true) {
                setState(() {
                  selectedCardIds.add(cards[index].id!);
                });
              } else {
                setState(() {
                  selectedCardIds.remove(cards[index].id!);
                });
              }
            },
          );
        },
      ),
    );
  }
}
