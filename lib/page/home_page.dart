import 'package:flashcard_app/page/create_deck_page.dart';
import 'package:flashcard_app/widget/deck_tile.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/database/deck_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
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
      body: Column(
        children: [
          SizedBox(height: 60),
          Text(
            "Unités récentes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.separated(
              itemCount: allDecks.length,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                return DeckTile(
                  deck: allDecks[index],
                  onDeckChanged: _loadDecks,
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(width: 10);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 35,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        onTap: (value) async {
          if (value == 1) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateDeckPage()),
            );
            _loadDecks();
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ' '),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ' '),
        ],
      ),
    );
  }
}
