import 'package:flashcard_app/database/deck_repository.dart';
import 'package:flashcard_app/model/app_clock.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/model/deck_review_info.dart';
import 'package:flashcard_app/model/review_limit.dart';
import 'package:flashcard_app/page/create_deck_page.dart';
import 'package:flashcard_app/page/flashcard_study_page.dart';
import 'package:flashcard_app/page/multiple_choice_study_page.dart';
import 'package:flashcard_app/page/written_study_page.dart';
import 'package:flashcard_app/widget/review_mode_sheet.dart';
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
  int dailyLimit = ReviewLimit.defaultLimit;
  int remainingToday = 0;
  List<Flashcard> reviewCards = [];
  DeckReviewInfo? info;

  @override
  void initState() {
    super.initState();
    currentDeck = widget.deck;
    _loadCards();
  }

  Future<void> _loadCards() async {
    final loadedInfo = await DeckReviewInfo.load(
      widget.deck.id!,
      AppClock.now(),
    );
    if (!mounted) return;
    setState(() {
      cards = loadedInfo.cards;
      dailyLimit = loadedInfo.dailyLimit;
      remainingToday = loadedInfo.remainingToday;
      reviewCards = loadedInfo.reviewCards;
      info = loadedInfo;
    });
  }

  Future<void> _editDailyLimit() async {
    double sliderValue = dailyLimit.toDouble();

    final newLimit = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Cartes par jour : ${sliderValue.round()}"),
          content: SizedBox(
            height: 40,
            child: Slider(
              value: sliderValue,
              min: 5,
              max: 100,
              divisions: 19,
              onChanged: (value) {
                setDialogState(() {
                  sliderValue = value;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, sliderValue.round()),
              child: Text("OK"),
            ),
          ],
        ),
      ),
    );

    if (newLimit != null) {
      await ReviewLimit.save(widget.deck.id!, newLimit);
      _loadCards();
    }
  }

  String _reviewTitle() {
    if (reviewCards.isNotEmpty) {
      return "${reviewCards.length} cartes à réviser";
    }
    if (remainingToday == 0) {
      return "Limite du jour atteinte";
    }
    return "Rien à réviser aujourd'hui";
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
              title: Text(_reviewTitle()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.tune),
                    onPressed: _editDailyLimit,
                  ),
                  ElevatedButton(
                    onPressed: (reviewCards.isNotEmpty)
                        ? () => showReviewModeSheet(
                            context,
                            deckId: currentDeck.id!,
                            info: info!,
                            onFinished: _loadCards,
                          )
                        : null,
                    child: Text("Réviser"),
                  ),
                ],
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
