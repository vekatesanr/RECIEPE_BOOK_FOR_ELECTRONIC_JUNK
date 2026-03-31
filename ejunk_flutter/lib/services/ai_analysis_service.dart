import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/junk_component.dart';
import '../constants.dart';

class AiAnalysisService {
  final GenerativeModel _model;

  AiAnalysisService()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash-latest',
          apiKey: AppConstants.geminiApiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );

  Future<Map<String, dynamic>> analyzeComponent({
    required Uint8List imageBytes,
    required String userDamageDesc,
    required List<String> pastComponentNames,
  }) async {
    final prompt = '''
      You are an expert E-Waste Recycling Assistant. 
      Analyze the attached image of an electronic component and the user's description: "${userDamageDesc}".
      
      Compare this new component with the user's past components: ${pastComponentNames.join(', ')}.
      
      Your task is to:
      1. Identify the specific component and its technical specifications.
      2. Estimate the time required to safely dismantle it ("dismantleTime").
      3. Suggest 3 unique "Micro-projects" or "New Component Outcomes".
      4. INTEGRATION CHECK: Suggest ONE creative "Integrated Device" that combines this new part with one of the past parts listed above.
      
      RETURN ONLY A JSON OBJECT in this format:
      {
        "aiLabel": "Specific Component Name",
        "origin": "Identify likely origin (e.g. Server, Old TV)",
        "dismantleTime": "Time in minutes/hours",
        "aiSuggestedProject": "Primary suggested micro-project",
        "integrationSuggestions": ["Project 2", "Project 3", "Integrated Device Suggestion"]
      }
    ''';

    final response = await _model.generateContent([
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ]),
    ]);

    final text = response.text;
    if (text == null) throw Exception('AI Analysis returned empty response');
    
    return safeParseJson(text);
  }

  Map<String, dynamic> safeParseJson(String text) {
    try {
      final jsonRegex = RegExp(r'\{[^{}]*?(?:\{[^{}]*?\}[^{}]*?)*\}');
      final match = jsonRegex.firstMatch(text);
      final cleaned = match?.group(0) ?? '{}';
      Map<String, dynamic> parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      return parsed;
    } catch (e) {
      print('AI Analysis JSON Fallback: $e');
      return {
        'aiLabel': 'Unknown',
        'origin': 'N/A',
        'dismantleTime': 'N/A',
        'aiSuggestedProject': 'Parse Error',
        'integrationSuggestions': [],
      };
    }
  }
}
