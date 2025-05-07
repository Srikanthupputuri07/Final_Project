import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF8A2BE2);
  static const Color error = Colors.red;
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color folderBlue = Color(0xFF0055FF);
  static const Color pdfRed = Color(0xFFE74C3C);
  static const Color backgroundColor = Color(0xFFF3E5F5);
}

class ApiConstants {
  static const String API_URL_1 =
      "https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2";
  static const String API_URL_3 =
      "https://api-inference.huggingface.co/models/gpt2";
  static const String API_URL_2 =
      "https://api-inference.huggingface.co/models/google/pegasus-xsum";
}
