import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frame/utils/constants.dart';

class AISearchScreen extends StatefulWidget {
  const AISearchScreen({super.key});

  @override
  _AISearchScreenState createState() => _AISearchScreenState();
}

const String API_URL =
    'https://api-inference.huggingface.co/models/HuggingFaceH4/zephyr-7b-beta';
const String API_TOKEN = '1234'; // Replace with your Hugging Face token

class _AISearchScreenState extends State<AISearchScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _response = "";
  bool _isLoading = false;
  String _error = "";

  Future<void> _processText() async {
    String inputText =
        _inputController.text.trim(); // Trim to remove extra spaces

    if (inputText.isEmpty) {
      setState(() {
        _error = "Please enter some text to process.";
        _response = "";
      });
      return; // Stop execution if input is empty
    }

    // String apiUrl = dotenv.env['API_URL'] ?? '';
    // String apiToken = dotenv.env['API_TOKEN'] ?? '';

    // if (apiUrl.isEmpty || apiToken.isEmpty) {
    //   print("API_URL or API_TOKEN is missing in .env");
    //   return;
    // }

    setState(() {
      _isLoading = true;
      _response = "";
      _error = "";
    });

    try {
      final String promptMessage =
          'Explain in detail: $inputText ? Give the answer in at least 50 words.';

      final response = await http.post(
        Uri.parse(API_URL),
        headers: {
          'Authorization': 'Bearer $API_TOKEN',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': promptMessage}),
      );

      print(
        "The Hugging face response with code ${response.statusCode} & body as ${response.body} ",
      );

      if (response.statusCode == 200) {
        setState(() {
          _response = jsonDecode(response.body)[0]['generated_text'];
        });
      } else if (response.statusCode == 503) {
        print("Error: Model is loading. Retrying in 5 seconds...");
        setState(() {
          _error = "Model is Not Loaded. Please try again.";
        });
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        setState(() {
          _error =
              "Error occured with statuscode  ${response.statusCode} and Response as ${response.body}";
        });
      }
    } catch (err) {
      setState(() {
        _error = "Error: ${err.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('AI Search'),
        backgroundColor: AppColors.primary,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: EdgeInsets.all(20),
          // color: AppColors.background,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: TextField(
                          controller: _inputController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Paste your text here',
                            contentPadding: EdgeInsets.all(15),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _processText,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        alignment: Alignment.center,
                        child:
                            _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  'Analyze',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    if (_error.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          _error,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.all(15),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _response.isEmpty
                                ? "AI response will appear here..."
                                : _response,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}
