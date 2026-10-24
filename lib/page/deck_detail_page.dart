import 'dart:convert';
import 'package:flashcard_app/database/deck_repository.dart';
import 'package:flashcard_app/model/app_clock.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/model/deck_review_info.dart';
import 'package:flashcard_app/model/deck_share.dart';
import 'package:flashcard_app/model/review_limit.dart';
import 'package:flashcard_app/model/text_utils.dart';
import 'package:flashcard_app/page/create_deck_page.dart';
import 'package:flashcard_app/widget/study_mode_sheet.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Page d'un deck : ses cartes, le bloc Révision et l'accès aux modes.
///
/// Depuis l'AppBar, le deck peut être partagé ou modifié.
class DeckDetailPage extends StatefulWidget {
  final Deck deck;
  const DeckDetailPage({super.key, required this.deck});

  @override
  State<DeckDetailPage> createState() => _DeckDetailPageState();
}

class _DeckDetailPageState extends State<DeckDetailPage> {
  /// Le deck affiché, rechargé après une modification (nom, type, langues).
  late Deck currentDeck;

  /// Cartes et révisions du deck, `null` tant qu’elles ne sont pas chargées.
  DeckReviewInfo? info;

  /// Raccourcis vers [info], avec une valeur par défaut pendant le chargement.
  List<Flashcard> get cards => info?.cards ?? [];
  int get dailyLimit => info?.dailyLimit ?? ReviewLimit.defaultLimit;
  int get remainingToday => info?.remainingToday ?? 0;
  List<Flashcard> get reviewCards => info?.reviewCards ?? [];

  @override
  void initState() {
    super.initState();
    currentDeck = widget.deck;
    _loadCards();
  }

  /// Recharge les cartes et les infos de révision du deck.
  Future<void> _loadCards() async {
    final loadedInfo = await DeckReviewInfo.load(
      widget.deck.id!,
      AppClock.now(),
    );
    if (!mounted) return;
    setState(() {
      info = loadedInfo;
    });
  }

  /// Ouvre un curseur pour régler le nombre de cartes à réviser par jour (5 à 100).
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

  /// Partage le deck en fichier JSON.
  ///
  /// Les « / » du nom sont remplacés, car ils ne sont pas permis dans
  /// un nom de fichier.
  Future<void> _shareDeck() async {
    final text = DeckShare.encode(currentDeck, cards);
    final file = XFile.fromData(
      utf8.encode(text),
      mimeType: 'application/json',
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        fileNameOverrides: ['${currentDeck.name.replaceAll('/', '-')}.json'],
      ),
    );
  }

  /// Titre du bloc Révision : le nombre de cartes à réviser,
  /// ou pourquoi il n’y en a pas.
  String _reviewTitle() {
    if (reviewCards.isNotEmpty) {
      return "${cardCountLabel(reviewCards.length)} à réviser";
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
            onPressed: cards.isEmpty ? null : _shareDeck,
            icon: Icon(Icons.ios_share),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateDeckPage(existingDeck: currentDeck),
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
                        ? () => showStudyModeSheet(
                            context,
                            deck: currentDeck,
                            flashcards: info!.reviewCards,
                            allCards: info!.cards,
                            isReview: true,
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
        onPressed: () =>
            showStudyModeSheet(context, deck: currentDeck, flashcards: cards),
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
