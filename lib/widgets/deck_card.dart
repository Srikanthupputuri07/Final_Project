import 'package:flutter/material.dart';
import 'package:frame/widgets/confirmation_dialog.dart';

class DeckCard extends StatelessWidget {
  final Map deck;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const DeckCard({
    required this.deck,
    required this.onDelete,
    required this.onTap,
    super.key,
  });

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: "Delete Deck",
          content: "Are you sure to delete this deck?",
          onConfirm: onDelete,
          confirmText: "Delete",
          cancelText: "Cancel",
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      // width: screenWidth * 0.5, // Takes half the screen width
      constraints: BoxConstraints(
        maxHeight: 250, // 🔥 Set max height (Adjust as needed)
      ),

      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onLongPress:
            () => _showDeleteDialog(context), // Show dialog on long press
        onTap: onTap,
        child: Card(
          // color: Color(0xFFF3E5F5),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Color(0xFF333333), // Change this color as needed
                fontSize: 16, // Optional: Set a default font size
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Height adjusts dynamically
                children: [
                  Text(
                    deck['deckName'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ), // Keeps bold but inherits color
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Total Cards: ${deck['learningCount'] + deck['reviewCount'] + deck['newCount'] + deck['relearningCount']}",
                  ),
                  Text("Due : ${deck['dueCount']}"),
                  Text(
                    "Learn : ${deck['learningCount'] + deck['relearningCount']}",
                  ),
                  Text("Review : ${deck['reviewCount']}"),
                  Text("New : ${deck['newCount']}"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
