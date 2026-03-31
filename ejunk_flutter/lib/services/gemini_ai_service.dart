 import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';

class GeminiAIService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;

  GeminiAIService() {
    // Section A: Secure Connection Debugging
    final allKeys = dotenv.env.keys;
    print('📦 AI Engine: Available .env keys: $allKeys');
    
    if (_apiKey.isNotEmpty) {
      print('⚡ AI Engine: Key loaded: ${_apiKey.substring(0, 5)}...');
    } else {
      print('❌ AI Engine: GEMINI_API_KEY is missing from .env!');
      print('🔍 DEBUG: dotenv.env content: ${dotenv.env}');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        "You are a professional Electronics Engineer. If you see a Lithium battery, always include a safety warning. "
        "Use your professional expertise to identify components accurately and suggest viable upcycling projects."
      ),
    );
  }

  // Section A: Validate Key presence and format
  bool validateKey() {
    if (_apiKey.isEmpty) return false;
    if (!_apiKey.startsWith('AIza')) return false; // Basic format check
    return true;
  }

  Future<Map<String, dynamic>> analyzeComponent({
    required Uint8List imageBytes,
    required String userDesc,
    required List<String> pastComponents,
  }) async {
    try {
      final String context = pastComponents.isNotEmpty
          ? "The user has previously worked with: ${pastComponents.join(', ')}. Try to integrate with these."
          : "Suggest a unique mini-project.";

      final content = [
        Content.multi([
          DataPart('image/jpeg', imageBytes),
          TextPart("""
            Identity the component in this image. 
            The user thinks it is a: "$userDesc".
            
            TASK (Section B): 
            1. If it is NOT the component described by the user, return 'mismatch': true and explain why in 'explanation'.
            2. If it is a match, return 'mismatch': false and provide a unique upcycling project using the details.
            3. Consider 'Past Components' context: $context.
            
            RETURN ONLY A JSON OBJECT with these keys:
            - 'mismatch': boolean (true if userDesc is incorrect)
            - 'explanation': string (why it is or isn't a match)
            - 'aiSuggestedProject': string (detailed project suggestion if no mismatch)
            - 'dismantleTime': string (e.g. '15-20 mins')
            - 'aiLabel': string (technical name)
            
            Strictly follow the JSON format for zero-error parsing.
          """),
        ])
      ];

      final response = await _model.generateContent(content);
      final String? text = response.text;
      
      if (text == null) throw Exception('AI returned empty response');

      final Map<String, dynamic> data = safeParseJson(text);

      return {
        'mismatch': data['mismatch'] ?? false,
        'explanation': data['explanation'] ?? '',
        'project': data['aiSuggestedProject'] ?? "Could not generate project.",
        'time': data['dismantleTime'] ?? "15-20 mins",
        'label': data['aiLabel'] ?? "Electronic Component",
      };
    } catch (e) {
      return {
        'mismatch': false,
        'explanation': 'Analysis failed: $e',
        'project': "Error: $e",
        'time': "N/A",
        'label': "Error",
      };
    }
  }

  Map<String, dynamic> safeParseJson(String text) {
    try {
      final jsonRegex = RegExp(r'\{[^{}]*?(?:\{[^{}]*?\}[^{}]*?)*\}');
      final match = jsonRegex.firstMatch(text);
      final cleaned = match?.group(0) ?? '{}';
      Map<String, dynamic> parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      return parsed;
    } catch (e) {
      print('JSON Parse Safe Fallback: $e');
      return {
        'mismatch': false,
        'explanation': 'Parse failed',
        'aiSuggestedProject': 'AI Error',
        'dismantleTime': 'N/A',
        'aiLabel': 'Unknown',
      };
    }
  }
}
