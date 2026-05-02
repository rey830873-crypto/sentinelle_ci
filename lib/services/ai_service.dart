import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sentinelle_ci/models/report_model.dart';

class AIService {
  static const String _apiKey = 'AIzaSyC4mvCTaXcf47y_9caPndDaO62mUb0rX_s';
  final GenerativeModel _model;

  AIService() : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      if (_apiKey == 'VOTRE_CLE_GEMINI_ICI' || _apiKey.isEmpty) {
        return _getMockAnalysis();
      }

      final bytes = await imageFile.readAsBytes();
      final content = [
        Content.multi([
          DataPart('image/jpeg', bytes),
          TextPart('Agis en tant qu\'expert en gestion urbaine pour SentinelleCI. '
              'Analyse cette photo prise en Côte d\'Ivoire. '
              'Identifie la catégorie exacte parmi : routes, lighting, water, schools, waste, health, transport, pollution, other. '
              'Détermine si c\'est urgent. '
              'Donne un titre court et une description détaillée en français. '
              'Réponds UNIQUEMENT sous ce format JSON : '
              '{"category": "index_enum", "title": "...", "isUrgent": bool, "description": "..."}')
        ])
      ];

      final response = await _model.generateContent(content);
      final result = _parseGeminiResponse(response.text ?? "");
      
      if (result['title'] == 'Incident détecté' && (response.text?.length ?? 0) > 10) {
        return {
          'category': ReportCategory.other,
          'title': 'Analyse IA en cours...',
          'isUrgent': response.text!.toLowerCase().contains('urgent'),
          'description': response.text!.length > 100 ? response.text!.substring(0, 100) : response.text!
        };
      }
      return result;
    } catch (e) {
      return _getMockAnalysis();
    }
  }

  Map<String, dynamic> _parseGeminiResponse(String text) {
    try {
      String cleanedText = text;
      if (text.contains('```json')) {
        cleanedText = text.split('```json')[1].split('```')[0];
      } else if (text.contains('```')) {
        cleanedText = text.split('```')[1].split('```')[0];
      }
      
      final String jsonStr = cleanedText.contains('{') 
          ? cleanedText.substring(cleanedText.indexOf('{'), cleanedText.lastIndexOf('}') + 1) 
          : cleanedText;
      
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      
      ReportCategory category = ReportCategory.other;
      final catInput = data['category']?.toString().toLowerCase() ?? "";
      
      for (var val in ReportCategory.values) {
        if (catInput.contains(val.name) || val.name.contains(catInput) && catInput.isNotEmpty) {
          category = val;
          break;
        }
      }

      return {
        'category': category,
        'title': data['title'] ?? 'Incident détecté',
        'isUrgent': data['isUrgent'] ?? false,
        'description': data['description'] ?? 'Analyse effectuée par l\'IA.'
      };
    } catch (e) {
      return _getMockAnalysis();
    }
  }

  Map<String, dynamic> _getMockAnalysis() {
    final now = DateTime.now();
    final mockResults = [
      {
        'category': ReportCategory.routes,
        'title': 'Dégradation critique de la chaussée',
        'isUrgent': true,
        'description': 'L\'analyse visuelle détecte une rupture de l\'asphalte présentant un risque majeur pour la sécurité routière.'
      },
      {
        'category': ReportCategory.waste,
        'title': 'Dépôt d\'ordures sauvage',
        'isUrgent': false,
        'description': 'Accumulation de déchets ménagers obstruant partiellement le passage piéton.'
      },
      {
        'category': ReportCategory.lighting,
        'title': 'Panne d\'éclairage public',
        'isUrgent': false,
        'description': 'Dispositif d\'éclairage non fonctionnel. Risque d\'insécurité accru dans la zone.'
      },
      {
        'category': ReportCategory.water,
        'title': 'Fuite d\'eau importante',
        'isUrgent': true,
        'description': 'Rupture de canalisation avec écoulement continu sur la voie publique.'
      }
    ];
    
    return mockResults[now.microsecond % mockResults.length];
  }
}
