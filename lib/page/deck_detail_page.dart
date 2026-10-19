import 'package:flashcard_app/database/card_repository.dart';
import 'package:flashcard_app/database/deck_repository.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/model/review_scheduler.dart';
import 'package:flashcard_app/page/create_deck_page.dart';
import 'package:flashcard_app/page/flashcard_study_page.dart';
import 'package:flashcard_app/page/multiple_choice_study_page.dart';
import 'package:flashcard_app/page/written_study_page.dart';
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
  static const _dailyLimit = 30;

  List<Flashcard> get reviewCards =>
      ReviewScheduler.cardsToReview(cards, DateTime.now(), _dailyLimit);

  @override
  void initState() {
    super.initState();
    currentDeck = widget.deck;
    _loadCards();
  }

  Future<void> _loadCards() async {
    final loadedCards = await CardRepository().readCardsByDeck(widget.deck.id!);
    if (!mounted) return;
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
              if (!mounted) return;
              setState(() {
                currentDeck = newDeck;
              });
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.repeat),
              title: (reviewCards.isNotEmpty)
                  ? Text("${reviewCards.length} cartes à réviser")
                  : Text("Rien à réviser aujourd'hui"),
              trailing: ElevatedButton(
                onPressed: (reviewCards.isNotEmpty)
                    ? () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text("Mode flashcard"),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FlashcardStudyPage(
                                              flashcards: reviewCards,
                                              deckId: currentDeck.id!,
                                              isReview: true,
                                            ),
                                      ),
                                    );
                                    _loadCards();
                                  },
                                ),
                                ListTile(
                                  title: Text("Mode écrit"),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WrittenStudyPage(
                                          flashcards: reviewCards,
                                          deckId: currentDeck.id!,
                                          isReview: true,
                                        ),
                                      ),
                                    );
                                    _loadCards();
                                  },
                                ),
                                ListTile(
                                  enabled: reviewCards.length > 1,
                                  title: Text("Mode QCM"),
                                  subtitle: reviewCards.length > 1
                                      ? null
                                      : Text("Il faut au moins 2 cartes"),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MultipleChoiceStudyPage(
                                              flashcards: reviewCards,
                                              deckId: currentDeck.id!,
                                              isReview: true,
                                            ),
                                      ),
                                    );
                                    _loadCards();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text("Réviser"),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cards[index].term),
                  subtitle: Text(cards[index].definition),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    enabled: cards.isNotEmpty,
                    title: Text("Mode flashcard"),
                    subtitle: cards.isNotEmpty
                        ? null
                        : Text("Ajoute au moins une carte"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlashcardStudyPage(
                            flashcards: cards,
                            deckId: currentDeck.id!,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    enabled: cards.isNotEmpty,
                    title: Text("Mode écrit"),
                    subtitle: cards.isNotEmpty
                        ? null
                        : Text("Ajoute au moins une carte"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WrittenStudyPage(
                            flashcards: cards,
                            deckId: currentDeck.id!,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    enabled: cards.length > 1,
                    title: Text("Mode QCM"),
                    subtitle: cards.length > 1
                        ? null
                        : Text("Il faut au moins 2 cartes"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultipleChoiceStudyPage(
                            flashcards: cards,
                            deckId: currentDeck.id!,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
