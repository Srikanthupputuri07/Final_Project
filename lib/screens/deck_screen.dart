import 'package:flutter/material.dart';
import 'package:frame/database/shared_prefs_storage.dart';
import 'package:frame/screens/flashcard_screen.dart';
import 'package:frame/utils/constants.dart';
import 'package:frame/widgets/deck_card.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DeckScreen extends StatefulWidget {
  const DeckScreen({super.key});

  @override
  _DeckScreenState createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  // List<Map<String, dynamic>> _flashcards = [];
  List<Map<String, dynamic>> _decks = [];
  // int _currentCard = 0;
  // bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    final decks = await SharedPrefsStorage.getDecksWithDetails();
    setState(() {
      _decks = List<Map<String, dynamic>>.from(decks);
    });
  }

  // void _addFlashcard() {
  //   if (_flashcards.length >= 100) {
  //     _showAlert("Limit Reached", "You can only have 100 flashcards per deck.");
  //     return;
  //   }

  //   final newFlashcard = {
  //     'id': _flashcards.length + 1,
  //     'question': "Sample Question",
  //     'answer': "Sample Answer",
  //   };

  //   setState(() {
  //     _flashcards.add(newFlashcard);
  //   });
  // }

  // void _deleteFlashcard() {
  //   if (_flashcards.isEmpty) return;

  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: Text("Delete Flashcard"),
  //           content: Text("Are you sure you want to delete this flashcard?"),
  //           actions: [
  //             TextButton(
  //               child: Text("Cancel"),
  //               onPressed: () => Navigator.of(context).pop(),
  //             ),
  //             TextButton(
  //               child: Text("Delete"),
  //               onPressed: () {
  //                 setState(() {
  //                   _flashcards.removeWhere(
  //                     (card) => card['id'] == _flashcards[_currentCard]['id'],
  //                   );
  //                   _currentCard = 0;
  //                 });
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         ),
  //   );
  // }

  void _showDeckNameDialog() {
    TextEditingController deckNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create New Deck"),
          content: TextField(
            controller: deckNameController,
            maxLength: 20, // Limit to 20 characters
            decoration: InputDecoration(
              hintText: "Enter deck name",
              border: OutlineInputBorder(),
              counterText: "", // Hide character counter
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text("Save", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                String deckName = deckNameController.text.trim();
                if (deckName.isEmpty) {
                  _showAlert("Error", "Deck name cannot be empty!");
                } else if (deckName.length > 20) {
                  _showAlert("Error", "Deck name cannot exceed 20 characters!");
                } else {
                  await SharedPrefsStorage.saveDeck(deckName);
                  print("New deck created: $deckName");
                  // Show success toast
                  Fluttertoast.showToast(
                    msg: "Deck '$deckName' created successfully!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                  // await SharedPrefsStorage.saveDeck(deckName);
                  _loadDecks();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3E5F5),
      appBar: AppBar(
        title: Text('Flash Card Decks'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.sync), // 🔄 Sync Icon
            onPressed: () {
              SharedPrefsStorage.syncDueCounts(); // Call the sync function
            },
          ),
        ],
      ),
      body:
          (_decks.isNotEmpty)
              ? SingleChildScrollView(
                // backgroundColor: Color('#F3E5F5')
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GridView.builder(
                    shrinkWrap:
                        true, // Ensures GridView doesn't take infinite height
                    physics:
                        const NeverScrollableScrollPhysics(), // Disables GridView's own scrolling
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Two cards per row
                          childAspectRatio:
                              0.95, // Adjusts height-to-width ratio
                          crossAxisSpacing: 0, // 4px horizontal space
                          mainAxisSpacing: 0, // 4px vertical space
                        ),
                    itemCount: _decks.length,
                    itemBuilder: (context, index) {
                      return DeckCard(
                        deck: _decks[index],
                        onDelete: () async {
                          await SharedPrefsStorage.deleteDeck(
                            _decks[index]['deckId'],
                          );
                          _loadDecks();
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => FlashcardScreen(
                                    deckId: _decks[index]['deckId'],
                                  ),
                            ),
                          ).then((_) {
                            _loadDecks(); // Refresh deck name
                            // _loadFlashcards(); // Refresh flashcards
                          });
                        },
                      );
                    },
                  ),
                ),
              )
              : Center(
                child: Text(
                  'No Flashcards Available.',
                  style: TextStyle(
                    fontSize: 18, // Adjust size as needed
                    fontWeight: FontWeight.bold, // Make text bold
                    color: Colors.grey, // Set color to grey
                    // fontStyle: FontStyle.italic, // Make text italic
                    // letterSpacing: 1.2, // Adjust letter spacing
                  ),
                ),
              ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showDeckNameDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
