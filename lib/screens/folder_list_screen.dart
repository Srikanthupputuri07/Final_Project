import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frame/screens/pdf_add_screen.dart';
import 'package:frame/utils/constants.dart';
import 'package:frame/widgets/confirmation_dialog.dart';
import 'package:path_provider/path_provider.dart';

class FolderListScreen extends StatefulWidget {
  final Function(String) onOpenPdf; // Accepts pdfPath as parameter

  const FolderListScreen({super.key, required this.onOpenPdf});
  @override
  _FolderListScreenState createState() => _FolderListScreenState();
}

class _FolderListScreenState extends State<FolderListScreen> {
  List<Map<String, dynamic>> _folders = [];
  String _folderPath = '';
  bool _isEditing = false;
  int? _editingId;
  final TextEditingController _folderNameController = TextEditingController();

  Future<void> _fetchStoredFolders() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> entities = appDocDir.listSync();

    List<Map<String, dynamic>> fetchedFolders = [];

    for (var entity in entities) {
      if (entity is Directory) {
        String folderName = entity.path.split('/').last;
        // Ignore 'flutter_assets' folder
        if (folderName != 'flutter_assets') {
          fetchedFolders.add({
            'id': fetchedFolders.length + 1,
            'name': folderName,
          });
        }
      }
    }

    setState(() {
      _folders = fetchedFolders;
    });
    setState(() {
      _folderPath = appDocDir.path;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStoredFolders(); // Load stored folders on app start
  }

  Future<void> createPrivateFolder(String folderName) async {
    // final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory privateFolder = Directory('$_folderPath/$folderName');

    if (!await privateFolder.exists()) {
      await privateFolder.create(recursive: true);
      print("Private folder created: ${privateFolder.path}");
    } else {
      print("Folder already exists.");
    }
  }

  void _addFolder() async {
    // Limit to a maximum of 15 folders
    if (_folders.length >= 15) return;

    final newFolder = {
      'id': _folders.length + 1,
      'name': 'Folder ${_folders.length}',
    };

    // Create folder in internal storage
    await createPrivateFolder(newFolder['name'] as String);

    setState(() {
      _folders.add(newFolder);
    });
  }

  void _startEditing(int folderId, String folderName) {
    setState(() {
      _isEditing = true;
      _editingId = folderId;
      _folderNameController.text = folderName;
    });
  }

  Future<void> _deleteFolder(int folderId, String folderName) async {
    final Directory folder = Directory('$_folderPath/$folderName');

    if (await folder.exists()) {
      await folder.delete(recursive: true); // Delete folder and its contents
      print("Folder deleted: ${folder.path}");
    } else {
      print("Folder not found: ${folder.path}");
    }

    setState(() {
      _folders.removeWhere((folder) => folder['id'] == folderId);
    });
  }

  Future<void> _saveFolderName() async {
    if (_editingId != null) {
      String oldName =
          _folders.firstWhere((f) => f['id'] == _editingId!)['name'];
      String newName = _folderNameController.text.trim();

      if (newName.isEmpty || oldName == newName) {
        _cancelEditing();
        return;
      }

      final Directory oldFolder = Directory('$_folderPath/$oldName');
      final Directory newFolder = Directory('$_folderPath/$newName');

      if (await oldFolder.exists()) {
        if (!await newFolder.exists()) {
          await oldFolder.rename(newFolder.path); // Rename in storage

          setState(() {
            _folders =
                _folders.map((folder) {
                  if (folder['id'] == _editingId) {
                    return {'id': _editingId, 'name': newName};
                  }
                  return folder;
                }).toList();
            _isEditing = false;
            _editingId = null;
            _folderNameController.clear();
          });

          print("Folder renamed from '$oldName' to '$newName'");
        } else {
          print(
            "Rename failed: A folder with the name '$newName' already exists.",
          );
        }
      } else {
        print("Rename failed: Folder '$oldName' does not exist.");
      }

      _cancelEditing();
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingId = null;
      _folderNameController.text = '';
    });
  }

  void _navigateToPDFAddScreen(String folderName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PDFAddScreen(
              folderPath: folderName,
              onOpenPdf: (String path) => widget.onOpenPdf(path),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('File Organizer'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child:
            (_folders.isNotEmpty)
                ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _folders.length,
                  itemBuilder: (context, index) {
                    final folder = _folders[index];
                    return GestureDetector(
                      onTap:
                          () => _navigateToPDFAddScreen(
                            "$_folderPath/${folder['name']}",
                          ),
                      onLongPress:
                          () => _startEditing(folder['id'], folder['name']),
                      onDoubleTap:
                          () => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmationDialog(
                                title: "Delete Folder",
                                content: "Are you sure to delete this folder?",
                                onConfirm: () async {
                                  await _deleteFolder(
                                    folder['id'],
                                    folder['name'],
                                  );
                                },
                                confirmText: "Delete",
                                cancelText: "Cancel",
                              );
                            },
                          ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isEditing && _editingId == folder['id'])
                              Column(
                                children: [
                                  TextField(
                                    controller: _folderNameController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                    onSubmitted: (_) => _saveFolderName(),
                                    autofocus: true,
                                  ),
                                  TextButton(
                                    onPressed: _cancelEditing,
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  Icon(
                                    Icons.folder,
                                    size: 100,
                                    color: AppColors.folderBlue,
                                  ),
                                  SizedBox(height: 5),
                                  Text(folder['name']),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                )
                : Center(
                  child: Text(
                    'No Folders Available.',
                    style: TextStyle(
                      fontSize: 18, // Adjust size as needed
                      fontWeight: FontWeight.bold, // Make text bold
                      color: Colors.grey, // Set color to grey
                      // fontStyle: FontStyle.italic, // Make text italic
                      // letterSpacing: 1.2, // Adjust letter spacing
                    ),
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFolder,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }
}
