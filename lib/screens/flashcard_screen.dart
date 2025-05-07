import 'package:flutter/material.dart';
import 'package:frame/screens/deck_settings_screen.dart';
import 'package:frame/widgets/confirmation_dialog.dart';
import 'package:fsrs/fsrs.dart' as SpacedRepetition;
import 'package:frame/database/shared_prefs_storage.dart';
import 'package:frame/utils/constants.dart';

class FlashcardScreen extends StatefulWidget {
  final String deckId;

  const FlashcardScreen({super.key, required this.deckId});

  @override
  FlashcardScreenState createState() => FlashcardScreenState();
}

class FlashcardScreenState extends State<FlashcardScreen> {
  String? _deckName;
  List<Map> _flashcards = [];
  var fsrs = SpacedRepetition.FSRS();

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDeckData(); // Fetch data again when returning to the screen
  }

  Future<void> _loadDeckData() async {
    final deckName = await SharedPrefsStorage.getDeckValue(
      widget.deckId,
      'deckName',
    );
    print("deck $deckName");
    setState(() {
      _deckName = deckName;
    });
  }

  Future<void> _loadFlashcards() async {
    final flashcards = await SharedPrefsStorage.getFlashcards(widget.deckId);
    final deckName = await SharedPrefsStorage.getDeckValue(
      widget.deckId,
      'deckName',
    );
    setState(() {
      _flashcards = List<Map>.from(flashcards);
      _deckName = deckName;
    });
  }

  void _addFlashcardDialog() {
    TextEditingController questionController = TextEditingController();
    TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Flashcard"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: InputDecoration(labelText: "Question"),
              ),
              TextField(
                controller: answerController,
                decoration: InputDecoration(labelText: "Answer"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () async {
                String question = questionController.text.trim();
                String answer = answerController.text.trim();
                var now = DateTime.now();
                print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@date is $now");
                var fsrsCard = SpacedRepetition.Card();
                print(
                  "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@card is $fsrsCard",
                );
                var schedulingCards = fsrs.repeat(fsrsCard, now);
                print(
                  "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Scheduling card is $schedulingCards",
                );
                schedulingCards.forEach((rating, schedulingInfo) {
                  print("Rating: $rating");
                  print("Card: ${schedulingInfo.card}");
                  print("Review Log: ${schedulingInfo.reviewLog}");
                  print("------");
                });

                if (question.isNotEmpty && answer.isNotEmpty) {
                  await SharedPrefsStorage.addFlashcard(
                    widget.deckId,
                    question,
                    answer,
                    fsrsCard,
                    {},
                  );
                  _loadFlashcards();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // void _showFlashcardDialog(Map<String, dynamic> flashcard) {
  //   bool showAnswer = false;

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false, // Prevent closing without selection
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: Text("Flashcard"),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   flashcard['question'],
  //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                 ),
  //                 SizedBox(height: 20),

  //                 if (showAnswer) ...[
  //                   Text(
  //                     flashcard['answer'],
  //                     style: TextStyle(fontSize: 16, color: Colors.blueAccent),
  //                   ),
  //                   SizedBox(height: 20),
  //                   Wrap(
  //                     alignment: WrapAlignment.center,
  //                     spacing: 8, // Space between buttons
  //                     runSpacing: 8, // Space between rows when wrapped
  //                     children: [
  //                       _buildDifficultyButton(
  //                         "Again",
  //                         Colors.red,
  //                         SpacedRepetition.Rating.again,
  //                         flashcard,
  //                       ),
  //                       _buildDifficultyButton(
  //                         "Hard",
  //                         Colors.orange,
  //                         SpacedRepetition.Rating.hard,
  //                         flashcard,
  //                       ),
  //                       _buildDifficultyButton(
  //                         "Good",
  //                         Colors.green,
  //                         SpacedRepetition.Rating.good,
  //                         flashcard,
  //                       ),
  //                       _buildDifficultyButton(
  //                         "Easy",
  //                         Colors.blue,
  //                         SpacedRepetition.Rating.easy,
  //                         flashcard,
  //                       ),
  //                     ],
  //                   ),
  //                 ] else ...[
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       setState(() {
  //                         showAnswer = true; // Show answer & buttons
  //                       });
  //                     },
  //                     child: Text("Show Answer"),
  //                   ),
  //                 ],
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // Widget _buildDifficultyButton(
  //   String text,
  //   Color color,
  //   SpacedRepetition.Rating rating,
  //   Map<String, dynamic> flashCard,
  // ) {
  //   return ElevatedButton(
  //     style: ElevatedButton.styleFrom(backgroundColor: color),
  //     onPressed: () {
  //       var now = DateTime.now();
  //       var schedulingCards = fsrs.repeat(flashCard['card'], now);
  //       var updatedCard = schedulingCards[rating]!.card ?? flashCard['card'];
  //       var updatedFlashCard = {...flashCard, 'card': updatedCard};
  //       SharedPrefsStorage.updateFlashcardCategory(
  //         widget.deckName,
  //         flashCard['card']['state'],
  //         flashCard['id'],
  //         updatedFlashCard,
  //       );
  //       Navigator.of(context).pop();
  //     },
  //     child: Text(text),
  //   );
  // }

  void _showFlashcardsSequentially(
    List<Map<String, dynamic>> flashcards, [
    int index = 0,
  ]) {
    if (index >= flashcards.length) return; // Stop if all cards are shown
    bool showAnswer = false;
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing without selection
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Flashcard"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    flashcards[index]['question'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  if (showAnswer) ...[
                    Text(
                      flashcards[index]['answer'],
                      style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildDifficultyButton(
                          "Again",
                          Colors.red,
                          SpacedRepetition.Rating.again,
                          flashcards[index],
                          index,
                          flashcards,
                        ),
                        _buildDifficultyButton(
                          "Hard",
                          Colors.orange,
                          SpacedRepetition.Rating.hard,
                          flashcards[index],
                          index,
                          flashcards,
                        ),
                        _buildDifficultyButton(
                          "Good",
                          Colors.green,
                          SpacedRepetition.Rating.good,
                          flashcards[index],
                          index,
                          flashcards,
                        ),
                        _buildDifficultyButton(
                          "Easy",
                          Colors.blue,
                          SpacedRepetition.Rating.easy,
                          flashcards[index],
                          index,
                          flashcards,
                        ),
                      ],
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showAnswer = true;
                        });
                      },
                      child: Text("Show Answer"),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDifficultyButton(
    String text,
    Color color,
    SpacedRepetition.Rating rating,
    Map<String, dynamic> flashCard,
    int index,
    List<Map<String, dynamic>> flashcards,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: () {
        var now = DateTime.now();
        print("@@@@@@@@@@@@@@@@@ $flashCard ${flashCard['card']}");
        SpacedRepetition.Card card = SpacedRepetition.Card.fromJson(
          flashCard['card'],
        );
        var schedulingCards = fsrs.repeat(card, now);
        var updatedCard = schedulingCards[rating]!.card ?? flashCard['card'];
        var updatedFlashCard = {...flashCard, 'card': updatedCard};

        SharedPrefsStorage.updateFlashcardCategory(
          widget.deckId,
          flashCard['card']['state'],
          flashCard['id'],
          updatedFlashCard,
        );

        Navigator.of(context).pop(); // Close current dialog

        // Show next flashcard
        _showFlashcardsSequentially(flashcards, index + 1);
      },
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3E5F5),
      appBar: AppBar(
        title: Text(_deckName!),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addFlashcardDialog, // Opens add flashcard dialog
          ),
          IconButton(
            icon: Icon(Icons.settings), // ⚙️ Settings Icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DeckSettingsScreen(deckId: widget.deckId),
                ),
              ).then((_) {
                _loadDeckData(); // Refresh deck name
                // _loadFlashcards(); // Refresh flashcards
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            // Makes the flashcards list scrollable
            child: ListView.builder(
              itemCount: _flashcards.length,
              itemBuilder: (context, index) {
                final card = _flashcards[index];
                return Card(
                  elevation: 4, // Adds a shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Smooth corners
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3,
                  ), // Spacing between cards
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Ensures ripple effect matches card shape
                    // onTap: () {
                    //   _showFlashcardDialog(card); // Call function when tapped
                    // },
                    onLongPress:
                        () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ConfirmationDialog(
                              title: "Delete Flashcard",
                              content: "Are you sure to delete this flashcard?",
                              onConfirm: () async {
                                await SharedPrefsStorage.deleteFlashcard(
                                  widget.deckId,
                                  card['card']['state'],
                                  card['id'],
                                );
                                _loadFlashcards();
                              },
                              confirmText: "Delete",
                              cancelText: "Cancel",
                            );
                          },
                        ),
                    child: Padding(
                      padding: EdgeInsets.all(12), // Padding inside the card
                      child: Text(
                        "${index + 1}. ${card['question']}", // Question number + question
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ), // Styled text
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            // Fixed "Study" button at the bottom
            width: double.infinity,
            padding: EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 12),
            color: Colors.transparent,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    8,
                  ), // Removes rounded corners
                ),
              ),
              onPressed: () async {
                int currentLimit = await SharedPrefsStorage.getDeckValue(
                  widget.deckId,
                  'currentLimit',
                );
                int deckLimit = await SharedPrefsStorage.getDeckValue(
                  widget.deckId,
                  'dailyLimit',
                );
                int remaining = (deckLimit) - (currentLimit);
                if (remaining <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Daily Limit Completed!")),
                  );
                  return;
                }
                List<Map<String, dynamic>> dueFlashcards =
                    await SharedPrefsStorage.fetchDueFlashcards(
                      widget.deckId,
                      remaining,
                    );
                if (dueFlashcards.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("No due flashcards available!")),
                  );
                  return;
                }
                _showFlashcardsSequentially(dueFlashcards);
              },

              child: Text(
                "Practice Now",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
