// import 'package:flutter_application_1/utils/constants.dart';

// class FlashcardScreen extends StatefulWidget {
//   @override
//   _FlashcardScreenState createState() => _FlashcardScreenState();
// }

// class _FlashcardScreenState extends State<FlashcardScreen> {
//   List<Map<String, dynamic>> _flashcards = [];
//   int _currentCard = 0;
//   bool _isFlipped = false;

//   void _addFlashcard() {
//     if (_flashcards.length >= 100) {
//       _showAlert("Limit Reached", "You can only have 100 flashcards per deck.");
//       return;
//     }

//     final newFlashcard = {
//       'id': _flashcards.length + 1,
//       'question': "Sample Question",
//       'answer': "Sample Answer",
//     };

//     setState(() {
//       _flashcards.add(newFlashcard);
//     });
//   }

//   void _deleteFlashcard() {
//     if (_flashcards.isEmpty) return;

//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text("Delete Flashcard"),
//             content: Text("Are you sure you want to delete this flashcard?"),
//             actions: [
//               TextButton(
//                 child: Text("Cancel"),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//               TextButton(
//                 child: Text("Delete"),
//                 onPressed: () {
//                   setState(() {
//                     _flashcards.removeWhere(
//                       (card) => card['id'] == _flashcards[_currentCard]['id'],
//                     );
//                     _currentCard = 0;
//                   });
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//     );
//   }

//   void _showAlert(String title, String message) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text(title),
//             content: Text(message),
//             actions: [
//               TextButton(
//                 child: Text("OK"),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flashcards'),
//         backgroundColor: AppColors.primary,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _flashcards.isNotEmpty
//                 ? GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _isFlipped = !_isFlipped;
//                     });
//                   },
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.8,
//                     height: 200,
//                     decoration: BoxDecoration(
//                       color: AppColors.primary,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     alignment: Alignment.center,
//                     child: Padding(
//                       padding: EdgeInsets.all(15),
//                       child: Text(
//                         _isFlipped
//                             ? "Answer: ${_flashcards[_currentCard]['answer']}"
//                             : "Question: ${_flashcards[_currentCard]['question']}",
//                         style: TextStyle(fontSize: 20, color: Colors.white),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 )
//                 : Text(
//                   "No flashcards available.",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primary,
//                   ),
//                 ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: _addFlashcard,
//               child: Text(
//                 "Add Flashcard",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.error,
//                 padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: _deleteFlashcard,
//               child: Text(
//                 "Delete Flashcard",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),

//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColors.primary,
//         onPressed: () {},
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
