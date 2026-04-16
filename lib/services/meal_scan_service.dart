import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:test_splash/models/food_model.dart';

class MealScanService {
  // TODO: Move to env / secure storage before release
  static const _apiKey = 'AIzaSyDbszbY_Qzj1fIJGZmm5lwZnl24MPiB5xU';

  static final _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: _apiKey,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      temperature: 0.3,
    ),
  );

  /// Analyse a meal photo and return a [Food] with estimated macros per 100 g.
  static Future<Food> analyseImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final mimeType = _guessMime(imageFile.path);

    final prompt = TextPart(
      '''You are a professional nutritionist AI. Analyse the food in this image.
Return a JSON object with these exact keys (no markdown, no extra text):
{
  "name": "meal name",
  "description": "short 1-sentence description of the meal",
  "calories": <number, estimated kcal per 100g or 100ml>,
  "protein": <number, grams per 100g or 100ml>,
  "carbs": <number, grams per 100g or 100ml>,
  "fats": <number, grams per 100g or 100ml>,
  "category": "one of: Protein, Carbs, Fats, Dairy, Fruits, Vegetables, Drinks, Snacks",
  "unitName": "one of: g, ml, piece",
  "weightPerUnit": <number, estimated weight of 1 piece in grams. If the food is not typically counted in pieces, return 100>
}
Only return the JSON. No explanation.''',
    );

    final imagePart = DataPart(mimeType, bytes);

    final response = await _model.generateContent([
      Content.multi([prompt, imagePart]),
    ]);

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Gemini returned an empty response');
    }

    // Strip any accidental markdown fences the model might add
    final cleaned = text
        .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'```\s*$', multiLine: true), '')
        .trim();

    final Map<String, dynamic> json = jsonDecode(cleaned);

    return Food(
      name: json['name'] ?? 'Unknown Meal',
      description: json['description'],
      category: json['category'],
      unitName: json['unitName'] ?? 'g',
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fats: (json['fats'] ?? 0).toDouble(),
      weightPerUnit: (json['weightPerUnit'] ?? 100.0).toDouble(),
    );
  }

  static String _guessMime(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}
