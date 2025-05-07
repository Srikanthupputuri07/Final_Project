// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// // class PDFViewerScreen extends StatelessWidget {
// //   final String? pdfPath;

// //   PDFViewerScreen({this.pdfPath});

// //   Future<void> _addToRecentFiles(String pdfPath) async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     List<String> recentFiles = prefs.getStringList('recent_pdfs') ?? [];

// //     if (!recentFiles.contains(pdfPath)) {
// //       recentFiles.insert(0, pdfPath);
// //       if (recentFiles.length > 5) {
// //         recentFiles.removeLast();
// //       }

// //       await prefs.setStringList('recent_pdfs', recentFiles);
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     if (pdfPath == null || !File(pdfPath!).existsSync()) {
// //       return Scaffold(
// //         appBar: AppBar(title: Text("File Not Found")),
// //         body: Center(child: Text("The selected PDF file does not exist.")),
// //       );
// //     }

// //     _addToRecentFiles(pdfPath!); // Add to recent files

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text("PDF Viewer"),
// //         backgroundColor: Colors.deepPurple,
// //       ),
// //       body: SfPdfViewer.file(File(pdfPath!), key: GlobalKey()),
// //     );
// //   }
// // }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfPath;
  final Function(String) onLockToggle; // Function to toggle lock

  const PDFViewerScreen({
    super.key,
    required this.pdfPath,
    required this.onLockToggle,
  });

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool _isLocked = false; // Track lock state
  late PdfViewerController _pdfController;
  int _lastPage = 0;
  double _lastOffset = 0.0;

  @override
  void initState() {
    super.initState();
    print("@@2 init state");
    _pdfController = PdfViewerController();
    _loadLockState();
    if (widget.pdfPath != '') {
      _addToRecentFiles(widget.pdfPath);
    }
    // print("@@@ ${_isLocked}");
    // if (_isLocked) {
    //   _loadLastPosition();
    // }
  }

  Future<void> _addToRecentFiles(String pdfPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentFiles = prefs.getStringList('recent_pdfs') ?? [];

    if (!recentFiles.contains(pdfPath)) {
      recentFiles.insert(0, pdfPath);
      if (recentFiles.length > 5) {
        recentFiles.removeLast();
      }

      await prefs.setStringList('recent_pdfs', recentFiles);
    }
  }

  /// Load lock state from SharedPreferences
  Future<void> _loadLockState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLocked = prefs.getBool('pdf_locked') ?? false;
    });

    print("@@@ Lock state loaded: $_isLocked");

    if (_isLocked) {
      await _loadLastPosition(); // 🔹 Load last position AFTER updating lock state
    }
  }

  Future<void> _loadLastPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastPage = prefs.getInt('${widget.pdfPath}_lastPage') ?? 0;
      _lastOffset = prefs.getDouble('${widget.pdfPath}_lastOffset') ?? 0.0;
    });

    print("AAAAAAAA $_lastOffset $_lastPage");

    // Restore page & exact position
    Future.delayed(Duration(milliseconds: 500), () {
      _pdfController.jumpToPage(_lastPage);
      _pdfController.jumpTo(yOffset: _lastOffset);
    });
  }

  /// Save last viewed page & scroll position (ONLY IF LOCKED)
  Future<void> _saveLastPosition() async {
    print(
      "@@@ saved ${_pdfController.pageNumber} ${_pdfController.scrollOffset.dy} $_isLocked",
    );
    if (!_isLocked) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${widget.pdfPath}_lastPage', _pdfController.pageNumber);
    await prefs.setDouble(
      '${widget.pdfPath}_lastOffset',
      _pdfController.scrollOffset.dy,
    );
  }

  @override
  void dispose() {
    _saveLastPosition(); // Save only if locked
    super.dispose();
  }

  /// Toggle lock state and update UI
  Future<void> _toggleLock() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLocked = !_isLocked; // Toggle the lock state
    });

    // await prefs.setBool('pdf_locked', _isLocked);
    widget.onLockToggle(widget.pdfPath); // Notify parent
  }

  @override
  Widget build(BuildContext context) {
    print("@@@ page $_lastOffset $_lastPage $_isLocked");
    if (!File(widget.pdfPath).existsSync()) {
      return Scaffold(
        appBar: AppBar(title: Text("File Not Found")),
        body: Center(child: Text("The selected PDF file does not exist.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(
              _isLocked ? Icons.lock : Icons.lock_open,
            ), // Change icon dynamically
            onPressed: () {
              _toggleLock(); // Toggle lock state
              // Navigator.pop(context); // Return to HomeScreen
            },
          ),
        ],
      ),
      body: SfPdfViewer.file(
        File(widget.pdfPath),
        key: GlobalKey(),
        controller: _pdfController,
        onPageChanged: (details) {
          if (_isLocked) {
            _lastPage = details.newPageNumber;
            _saveLastPosition();
          }
        },
        onDocumentLoaded: (_) {
          print("@@@@ $_isLocked");
          if (_isLocked) {
            Future.delayed(Duration(milliseconds: 500), () {
              _pdfController.jumpToPage(_lastPage);
              _pdfController.jumpTo(yOffset: _lastOffset);
            });
          } else {
            _pdfController.jumpToPage(1); // Unlocked mode starts from page 1
          }
        },
      ),
    );
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// class PDFViewerScreen extends StatefulWidget {
//   final String pdfPath;
//   final bool isLocked;
//   final VoidCallback onLockToggle;

//   PDFViewerScreen({
//     required this.pdfPath,
//     required this.isLocked,
//     required this.onLockToggle,
//   });

//   @override
//   _PDFViewerScreenState createState() => _PDFViewerScreenState();
// }

// class _PDFViewerScreenState extends State<PDFViewerScreen> {
//   late PdfViewerController _pdfController;
//   int _lastPage = 0;
//   double _lastOffset = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _pdfController = PdfViewerController();

//     if (widget.isLocked) {
//       _loadLastPosition();
//     }
//   }

//   /// Load last page & scroll offset (ONLY IF LOCKED)
//   Future<void> _loadLastPosition() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _lastPage = prefs.getInt('${widget.pdfPath}_lastPage') ?? 0;
//       _lastOffset = prefs.getDouble('${widget.pdfPath}_lastOffset') ?? 0.0;
//     });

//     // Restore page & exact position
//     Future.delayed(Duration(milliseconds: 500), () {
//       _pdfController.jumpToPage(_lastPage);
//       _pdfController.jumpTo(yOffset: _lastOffset);
//     });
//   }

//   /// Save last viewed page & scroll position (ONLY IF LOCKED)
//   Future<void> _saveLastPosition() async {
//     if (!widget.isLocked) return;
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('${widget.pdfPath}_lastPage', _pdfController.pageNumber);
//     await prefs.setDouble(
//       '${widget.pdfPath}_lastOffset',
//       _pdfController.scrollOffset.dy,
//     );
//   }

//   @override
//   void dispose() {
//     _saveLastPosition(); // Save only if locked
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!File(widget.pdfPath).existsSync()) {
//       return Scaffold(
//         appBar: AppBar(title: Text("File Not Found")),
//         body: Center(child: Text("The selected PDF file does not exist.")),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("PDF Viewer"),
//         backgroundColor: Colors.deepPurple,
//         actions: [
//           IconButton(
//             icon: Icon(widget.isLocked ? Icons.lock : Icons.lock_open),
//             onPressed: () {
//               widget.onLockToggle();
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//       body: SfPdfViewer.file(
//         File(widget.pdfPath),
//         key: GlobalKey(),
//         controller: _pdfController,
//         onPageChanged: (details) {
//           if (widget.isLocked) {
//             _lastPage = details.newPageNumber;
//             _saveLastPosition();
//           }
//         },
//         onDocumentLoaded: (_) {
//           if (widget.isLocked) {
//             Future.delayed(Duration(milliseconds: 500), () {
//               _pdfController.jumpToPage(_lastPage);
//               _pdfController.jumpTo(yOffset: _lastOffset);
//             });
//           } else {
//             _pdfController.jumpToPage(1); // Unlocked mode starts from page 1
//           }
//         },
//       ),
//     );
//   }
// }
