import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frame/screens/pdf_viewer_screen.dart';
import 'package:frame/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFReaderScreen extends StatefulWidget {
  final Function(String) onOpenPdf;

  const PDFReaderScreen({super.key, required this.onOpenPdf});
  @override
  _PDFReaderScreenState createState() => _PDFReaderScreenState();
}

class _PDFReaderScreenState extends State<PDFReaderScreen> {
  List<String> _recentFiles = [];

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
  }

  /// Load recent files from local storage
  Future<void> _loadRecentFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentFiles = prefs.getStringList('recent_pdfs') ?? [];
    });
  }

  /// Add a PDF to the recent files list
  // Future<void> _addToRecentFiles(String pdfPath) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   if (!_recentFiles.contains(pdfPath)) {
  //     setState(() {
  //       _recentFiles.insert(0, pdfPath); // Add at the beginning
  //       if (_recentFiles.length > 5) {
  //         _recentFiles.removeLast(); // Keep only 5 recent files
  //       }
  //     });

  //     await prefs.setStringList('recent_pdfs', _recentFiles);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Recent PDFs'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: _buildRecentFilesList(),
      ),
    );
  }

  /// Widget to display the PDF Viewer
  // Widget _buildPDFViewer() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.picture_as_pdf, size: 100, color: AppColors.pdfRed),
  //         SizedBox(height: 20),
  //         Text(
  //           'Viewing: ${widget.pdfPath!.split('/').last}', // Show the PDF name
  //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //         ),
  //         SizedBox(height: 20),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
  //           onPressed: () {
  //             // Implement PDF opening logic (e.g., using `flutter_pdfview`)
  //           },
  //           child: Text('Open PDF', style: TextStyle(color: Colors.white)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// Widget to display the PDF Viewer for local files
  // Widget _buildPDFViewer(String filePath) {
  //   File pdfFile = File(filePath);

  //   if (!pdfFile.existsSync()) {
  //     return Center(child: Text("File not found!"));
  //   }

  //   return SfPdfViewer.file(
  //     pdfFile, // Load PDF from local file
  //     key: GlobalKey(),
  //   );
  // }

  /// Widget to display the list of recently opened PDFs
  Widget _buildRecentFilesList() {
    if (_recentFiles.isEmpty) {
      return Center(
        child: Text(
          'No recent PDFs found.',
          style: TextStyle(
            fontSize: 18, // Adjust size as needed
            fontWeight: FontWeight.bold, // Make text bold
            color: Colors.grey, // Set color to grey
            // fontStyle: FontStyle.italic, // Make text italic
            // letterSpacing: 1.2, // Adjust letter spacing
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _recentFiles.length,
      itemBuilder: (context, index) {
        String filePath = _recentFiles[index];
        String fileName = filePath.split('/').last;

        return GestureDetector(
          onTap: () => widget.onOpenPdf(filePath),
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf, size: 40, color: AppColors.pdfRed),
                SizedBox(width: 15),
                Expanded(
                  // Prevents overflow
                  child: Text(
                    fileName,
                    style: TextStyle(fontSize: 16),
                    overflow:
                        TextOverflow
                            .ellipsis, // Adds "..." when text is too long
                    maxLines: 1, // Keeps it to one line
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
