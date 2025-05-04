import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frame/screens/deck_screen.dart';
import 'package:frame/screens/folder_list_screen.dart';
import 'package:frame/screens/pdf_reader_screen.dart';
import 'package:frame/screens/ai_search_screen.dart';
import 'package:frame/screens/flashcard_screen.dart';
import 'package:frame/screens/pdf_viewer_screen.dart';
import 'package:frame/utils/lock_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path; // Add this import
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  print('Current directory: ${Directory.current.path}');
  // Debug: Print the resolved .env path
  final envPath = path.join(Directory.current.path, '.env');
  print('Looking for .env at: $envPath');

  try {
    await dotenv.load(
      fileName: r"D:\Projects\Frame\flutter_application_1\frame\.env",
    ); // Use full absolute path
    print('Successfully loaded .env!');
  } catch (e) {
    print("Error loading .env: $e");
  }
  final envFile = File('.env');
  print('Does .env exist? ${envFile.existsSync()}');
  print('Absolute path: ${envFile.absolute.path}');

  runApp(
    ChangeNotifierProvider(
      create: (context) => LockProvider(), // Provide the lock state
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FRAME ',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: Color(0xFF8A2BE2),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLocked = false; // Track lock state
  String _pdfPath = '';
  // final lockProvider = Provider.of<LockProvider>(context);

  @override
  void initState() {
    super.initState();
    _loadLockState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Load lock state from storage
  Future<void> _loadLockState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLocked = prefs.getBool('pdf_locked') ?? false;
      _pdfPath = prefs.getString('pdf_path') ?? '';
    });
  }

  /// Toggle lock state
  Future<void> toggleLock(String pdfPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLocked = !_isLocked;
      _pdfPath = pdfPath;
      _selectedIndex = 1;
    });
    await prefs.setBool('pdf_locked', _isLocked);
    await prefs.setString('pdf_path', pdfPath);
    print("@@@AAAAA $pdfPath $_isLocked $_selectedIndex");
    // _onItemTapped(1);
    // ✅ Pop all screens until we reach HomeScreen
    Navigator.popUntil(context, (route) => route.isFirst);

    // ✅ Update the selected tab to the PDF screen
    setState(() {
      _selectedIndex = 1;
    });
  }

  /// Navigate to PDFViewerScreen and pass `toggleLock()`
  void _openPDF(String pdfPath) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PDFViewerScreen(
              pdfPath: pdfPath,
              onLockToggle: (String path) => toggleLock(path),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      FolderListScreen(onOpenPdf: (String path) => _openPDF(path)),
      _isLocked
          ? PDFViewerScreen(
            pdfPath: _pdfPath,
            onLockToggle: (String path) => toggleLock(path),
          )
          : PDFReaderScreen(onOpenPdf: (String path) => _openPDF(path)),

      AISearchScreen(),
      DeckScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.picture_as_pdf),
            label: 'PDF',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'AI',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.style), label: 'FlashLearn'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
