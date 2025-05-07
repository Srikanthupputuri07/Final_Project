import 'package:flutter/material.dart';
import 'package:frame/database/shared_prefs_storage.dart';
import 'package:frame/utils/constants.dart';

class DeckSettingsScreen extends StatefulWidget {
  final String deckId;

  const DeckSettingsScreen({super.key, required this.deckId});

  @override
  _DeckSettingsScreenState createState() => _DeckSettingsScreenState();
}

class _DeckSettingsScreenState extends State<DeckSettingsScreen> {
  late TextEditingController _deckNameController;
  late TextEditingController _deckLimitController;
  Map<String, dynamic>? _deck;
  bool isEditingName = false;
  bool isEditingLimit = false;

  @override
  void initState() {
    super.initState();
    _initializeDeckDetails();
  }

  Future<void> _initializeDeckDetails() async {
    Map<String, dynamic>? deck = await SharedPrefsStorage.getDeckDetails(
      widget.deckId,
    );
    print("AAAAAAAAAAAAAAA $deck");
    setState(() {
      _deckNameController = TextEditingController(text: deck?['deckName']);
      _deckLimitController = TextEditingController(
        text: deck?['dailyLimit'].toString(),
      );
      _deck = deck!;
    });
    print("AAAAAA $_deck");
  }

  @override
  void dispose() {
    _deckNameController.dispose();
    _deckLimitController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    setState(() {
      isEditingName = false;
      isEditingLimit = false;
    });
    // TODO: Save changes to SharedPreferences or Database
  }

  void _renameDeck() async {
    String newDeckName = _deckNameController.text.trim();
    if (_deck?['deckName'] != null &&
        newDeckName.isNotEmpty &&
        newDeckName != _deck?['deckName']) {
      bool success = await SharedPrefsStorage.renameDeck(
        _deck?['deckName'],
        newDeckName,
        widget.deckId,
      );
      if (success) {
        setState(() {
          isEditingName = false;
        });
        // widget.onDeckNameUpdated(
        //   newDeckName,
        // ); // Update previous screen // Send new name back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Deck renamed successfully!")),
        );
        await _initializeDeckDetails();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to rename deck.")));
      }
    }
  }

  void _setLimit() async {
    String newLimit = _deckLimitController.text.trim();
    print("AAAAA $newLimit");

    // Check if the input is a valid number
    if (newLimit.isEmpty || int.tryParse(newLimit) == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter a valid number!")));
      return;
    }

    if (int.tryParse(newLimit)! > _deck?['totalCards']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Limit cannot be more than total Cards!")),
      );
      return;
    }

    int limit = int.parse(newLimit);

    // Update the deck limit in SharedPreferences
    await SharedPrefsStorage.updateDeckValue(
      widget.deckId,
      'dailyLimit',
      limit,
    );

    // Show confirmation
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Deck limit updated to $limit!")));

    await _initializeDeckDetails();

    // Refresh UI (if needed)
    // setState(() {}); // This may be required depending on implementation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deck Settings'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Deck Name",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child:
                      isEditingName
                          ? TextField(
                            controller: _deckNameController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: "Enter new deck name",
                            ),
                          )
                          : Text(
                            _deck?['deckName'],
                            style: TextStyle(fontSize: 18),
                          ),
                ),
                IconButton(
                  icon: Icon(isEditingName ? Icons.check : Icons.edit),
                  onPressed: () {
                    if (isEditingName) _renameDeck();
                    setState(() {
                      isEditingName = !isEditingName;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Daily Limit",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child:
                      isEditingLimit
                          ? TextField(
                            controller: _deckLimitController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Enter daily limit",
                            ),
                          )
                          : Text(
                            _deck!['dailyLimit'].toString(),
                            style: TextStyle(fontSize: 18),
                          ),
                ),
                IconButton(
                  icon: Icon(isEditingLimit ? Icons.check : Icons.edit),
                  onPressed: () {
                    if (isEditingLimit) _setLimit();
                    setState(() {
                      isEditingLimit = !isEditingLimit;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
