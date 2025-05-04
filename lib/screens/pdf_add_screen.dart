import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frame/screens/pdf_reader_screen.dart';
import 'package:frame/screens/pdf_viewer_screen.dart';
import 'package:frame/utils/constants.dart';

class PDFAddScreen extends StatefulWidget {
  final String folderPath;
  final Function(String) onOpenPdf; // Accepts pdfPath as parameter

  const PDFAddScreen({
    super.key,
    required this.folderPath,
    required this.onOpenPdf,
  });

  @override
  _PDFAddScreenState createState() => _PDFAddScreenState();
}

class _PDFAddScreenState extends State<PDFAddScreen> {
  List<Map<String, dynamic>> _documents = [];

  @override
  void initState() {
    super.initState();
    _fetchDocuments(); // Fetch PDFs when screen loads
  }

  /// Fetch all PDFs inside the folder
  Future<void> _fetchDocuments() async {
    final Directory folderDir = Directory(widget.folderPath);
    if (await folderDir.exists()) {
      setState(() {
        _documents =
            folderDir
                .listSync()
                .whereType<File>()
                .where((file) => file.path.endsWith('.pdf')) // Filter only PDFs
                .map(
                  (file) => {
                    'name': file.uri.pathSegments.last, // Get file name
                    'path': file.path, // Full file path
                  },
                )
                .toList();
      });
    }
  }

  // Future<void> _uploadFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom, // Restrict file type
  //     allowedExtensions: ['pdf'], // Allow only PDF files
  //   );

  //   if (result != null) {
  //     File selectedFile = File(result.files.single.path!);
  //     String fileName = result.files.single.name;
  //     String newFilePath = '${widget.folderName}/$fileName';

  //     await selectedFile.copy(newFilePath);
  //     print("PDF uploaded to: $newFilePath");
  //   } else {
  //     print("No file selected.");
  //   }
  // }

  Future<void> _addDocument() async {
    if (_documents.length >= 6) {
      _showAlert('Limit Reached', 'You can only add up to 6 documents.');
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Allow only PDFs
    );

    if (result != null) {
      File selectedFile = File(result.files.single.path!);
      String fileName = result.files.single.name;

      // Get the directory path where PDFs should be stored
      // final appDocDir = await getApplicationDocumentsDirectory();
      // final folderPath = '${appDocDir.path}/${widget.folderName}';
      final destinationFile = File('${widget.folderPath}/$fileName');

      // Ensure folder exists
      // if (!await Directory(folderPath).exists()) {
      //   await Directory(folderPath).create(recursive: true);
      // }

      // Copy file to the new location
      await selectedFile.copy(destinationFile.path);
      print("PDF uploaded to: ${destinationFile.path}");

      // Update UI to show the newly added document
      setState(() {
        _documents = [
          ..._documents,
          {
            'id': _documents.length + 1,
            'name': fileName,
            'path': destinationFile.path,
          },
        ];
      });
    } else {
      print("No file selected.");
    }
  }

  // void _addDocument() {
  //   if (_documents.length >= 6) {
  //     _showAlert('Limit Reached', 'You can only add up to 6 documents.');
  //     return;
  //   }

  //   // Logic to add a new document (this is just a placeholder)
  //   final newDoc = {
  //     'id': _documents.length + 1,
  //     'name': 'Document ${_documents.length + 1}'
  //   };

  //   setState(() {
  //     _documents.add(newDoc);
  //   });
  // }

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

  // void _openPDF(String filePath, String fileName) {
  //   // setState(() {
  //   //   if (!_recentlyOpened.contains(filePath)) {
  //   //     _recentlyOpened.insert(0, filePath);
  //   //     if (_recentlyOpened.length > 5) {
  //   //       _recentlyOpened.removeLast(); // Keep max 5 recent files
  //   //     }
  //   //   }
  //   // });

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder:
  //           (context) => PDFViewerScreen(
  //             pdfPath: filePath,
  //             onLockToggle: (String path) => widget.onLockToggle(path),
  //           ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderPath.split('/').last),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   widget.folderName,
            //   style: TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _addDocument,
              child: Text(
                'Add Document',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _documents.length,
                itemBuilder: (context, index) {
                  final document = _documents[index];

                  return GestureDetector(
                    onTap: () => widget.onOpenPdf(document['path']),
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 40,
                            color: AppColors.pdfRed,
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            // Prevents overflow
                            child: Text(
                              document['name'],
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
