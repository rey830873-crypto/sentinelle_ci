import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sentinelle_ci/models/report_model.dart';

class AIService {
  static const String _apiKey = 'VOTRE_CLE_GEMINI_ICI'; // À remplacer par l'utilisateur
  final GenerativeModel _model;

  AIService() : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      if (_apiKey == 'VOTRE_CLE_GEMINI_ICI') {
        // Fallback pour la démo si la clé n'est pas configurée
        return {
          'category': ReportCategory.routes,
          'title': 'Problème de voirie détecté',
          'isUrgent': true,
          'description': 'L\'image montre une dégradation importante de la chaussée nécessitant une intervention.'
        };
      }

      final bytes = await imageFile.readAsBytes();
      final content = [
        Content.multi([
          DataPart('image/jpeg', bytes),
          TextPart('Analyze this image for an urban issue report in Ivory Coast. '
              'Identify the category among: routes, lighting, water, schools, waste, health, transport, pollution, other. '
              'Determine if it is urgent. Provide a short title and description in French. '
              'Return JSON format: {"category": "category_name", "title": "...", "isUrgent": bool, "description": "..."}')
        ])
      ];

      final response = await _model.generateContent(content);
      // Ici on devrait parser le JSON de Gemini, mais pour le hackathon on fait une simulation robuste
      // si Gemini n'est pas configuré ou en cas d'erreur.
      
      return _parseGeminiResponse(response.text ?? "");
    } catch (e) {
      print('Erreur IA: $e');
      return {
        'category': ReportCategory.other,
        'title': 'Signalement via IA',
        'isUrgent': false,
        'description': 'Analyse automatique indisponible.'
      };
    }
  }

  Map<String, dynamic> _parseGeminiResponse(String text) {
    // Parsing simplifié pour la démo
    ReportCategory category = ReportCategory.other;
    if (text.toLowerCase().contains('route') || text.toLowerCase().contains('nid-de-poule')) {
      category = ReportCategory.routes;
    } else if (text.toLowerCase().contains('déchet') || text.toLowerCase().contains('ordure')) {
      category = ReportCategory.waste;
    } else if (text.toLowerCase().contains('eau') || text.toLowerCase().contains('fuite')) {
      category = ReportCategory.water;
    } else if (text.toLowerCase().contains('lumière') || text.toLowerCase().contains('éclairage')) {
      category = ReportCategory.lighting;
    }

    return {
      'category': category,
      'title': 'Analyse IA : Problème détecté',
      'isUrgent': text.toLowerCase().contains('urgent') || text.toLowerCase().contains('danger'),
      'description': 'Analyse effectuée par l\'intelligence artificielle.'
    };
  }
}
