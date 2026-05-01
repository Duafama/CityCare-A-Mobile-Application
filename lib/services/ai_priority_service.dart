import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  // ==================== TRAINING DATA ====================
  static final Map<String, List<Map<String, dynamic>>> _advancedTraining = {
    'High': [
      {
        'keywords': ['accident', 'crash', 'collision', 'hit and run'],
        'weight': 10
      },
      {
        'keywords': ['fire', 'burning', 'smoke', 'flames', 'blaze'],
        'weight': 10
      },
      {
        'keywords': ['flood', 'flooding', 'water level', 'submerged'],
        'weight': 9
      },
      {
        'keywords': ['collapse', 'fallen', 'cracked', 'broken', 'damaged'],
        'weight': 9
      },
      {
        'keywords': ['gas leak', 'chemical', 'toxic', 'hazardous'],
        'weight': 10
      },
      {
        'keywords': ['electrical', 'shock', 'wire', 'sparking', 'pole down'],
        'weight': 9
      },
      {
        'keywords': ['open manhole', 'missing cover', 'deep pit'],
        'weight': 8
      },
      {
        'keywords': ['injury', 'bleeding', 'unconscious', 'trapped'],
        'weight': 10
      },
      {
        'keywords': ['emergency', 'urgent', 'critical', 'immediate'],
        'weight': 9
      },
      {
        'keywords': ['child', 'elderly', 'school', 'hospital'],
        'weight': 8
      },
    ],
    'Medium': [
      {
        'keywords': ['pothole', 'road damage', 'uneven road'],
        'weight': 6
      },
      {
        'keywords': ['garbage', 'trash', 'waste', 'dumping'],
        'weight': 5
      },
      {
        'keywords': ['water shortage', 'no water', 'low pressure'],
        'weight': 5
      },
      {
        'keywords': ['water not clean', 'dirty water', 'contaminated water'],
        'weight': 5
      },
      {
        'keywords': ['drainage', 'clogged', 'blocked drain'],
        'weight': 5
      },
      {
        'keywords': ['street light', 'dark street', 'light not working'],
        'weight': 4
      },
      {
        'keywords': ['broken footpath', 'sidewalk', 'pavement'],
        'weight': 4
      },
      {
        'keywords': ['sewage', 'overflow', 'backflow'],
        'weight': 6
      },
      {
        'keywords': ['traffic signal', 'stop light broken'],
        'weight': 4
      },
      {
        'keywords': ['noise complaint', 'loud music', 'construction'],
        'weight': 3
      },
      {
        'keywords': ['stray animals', 'dogs', 'cattle on road'],
        'weight': 4
      },
    ],
    'Low': [
      {
        'keywords': ['graffiti', 'wall painting', 'vandalism art'],
        'weight': 2
      },
      {
        'keywords': ['beautification', 'plantation', 'gardening'],
        'weight': 1
      },
      {
        'keywords': ['cleanliness', 'sweeping', 'dustbin'],
        'weight': 2
      },
      {
        'keywords': ['tree trimming', 'pruning', 'cutting grass'],
        'weight': 2
      },
      {
        'keywords': ['bench repair', 'park maintenance'],
        'weight': 2
      },
      {
        'keywords': ['paint peeling', 'faded signboard'],
        'weight': 2
      },
      {
        'keywords': ['cosmetic', 'aesthetic', 'looks bad'],
        'weight': 1
      },
    ]
  };

  // FIXED: Added 'Other' category with proper weights
  static final Map<String, Map<String, int>> _categoryWeights = {
    'Emergency': {'High': 20, 'Medium': 0, 'Low': 0},
    'Safety': {'High': 15, 'Medium': 5, 'Low': 0},
    'Infrastructure': {'High': 5, 'Medium': 10, 'Low': 2},
    'Roads': {'High': 8, 'Medium': 8, 'Low': 1},
    'Water & Drainage': {'High': 0, 'Medium': 12, 'Low': 3},
    'Waste Management': {'High': 0, 'Medium': 10, 'Low': 5},
    'Electricity': {'High': 10, 'Medium': 6, 'Low': 1},
    'Public Health': {'High': 15, 'Medium': 5, 'Low': 0},
    'Other': {'High': 0, 'Medium': 5, 'Low': 5}, // ADDED THIS LINE
  };

  // ==================== MAIN FUNCTION - Keyword First, AI Fallback ====================
  static Future<String> getPriority({
    required String description,
    required String category,
    required List<String> imageUrls,
  }) async {
    try {
      // STEP 1: Try keyword matching first (fast and free)
      final keywordResult = _getKeywordPriority(description, category);

      // STEP 2: If keywords found a clear match, return it immediately
      if (keywordResult != null) {
        return keywordResult;
      }

      // STEP 3: No keyword match found - use AI as fallback
      final aiPriority = await _getAIPriority(description, category, imageUrls);
      if (aiPriority.isNotEmpty) {
        return aiPriority;
      }

      // STEP 4: Ultimate fallback
      return 'Medium';
    } catch (e) {
      print('Error in AIService.getPriority: $e');
      return 'Medium'; // Safe fallback
    }
  }

  // ==================== KEYWORD PRIORITY (Primary) ====================
  static String? _getKeywordPriority(String description, String category) {
    try {
      final ruleScore = _calculateRuleBasedScore(description, category);

      // Calculate total score
      int highScore = ruleScore['High'] ?? 0;
      int mediumScore = ruleScore['Medium'] ?? 0;
      int lowScore = ruleScore['Low'] ?? 0;

      // If any score is significantly higher, return it
      if (highScore > mediumScore && highScore > lowScore && highScore >= 5) {
        return 'High';
      }
      if (lowScore > highScore && lowScore > mediumScore && lowScore >= 3) {
        return 'Low';
      }
      if (mediumScore > 0 &&
          mediumScore >= highScore &&
          mediumScore >= lowScore) {
        return 'Medium';
      }

      // No clear keyword match
      return null;
    } catch (e) {
      print('Error in _getKeywordPriority: $e');
      return null;
    }
  }

  // ==================== IMAGE ANALYSIS ====================
  static Future<Map<String, int>> _analyzeImages(List<String> imageUrls) async {
    Map<String, int> imageScores = {'High': 0, 'Medium': 0, 'Low': 0};

    if (imageUrls.isEmpty) {
      return imageScores;
    }

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return imageScores;
    }

    try {
      List<Map<String, dynamic>> imageParts = [];
      for (int i = 0; i < imageUrls.length && i < 2; i++) {
        final imageData = await _downloadAndEncodeImage(imageUrls[i]);
        if (imageData.isNotEmpty) {
          imageParts.add({
            "inline_data": {"mime_type": "image/jpeg", "data": imageData}
          });
        }
      }

      if (imageParts.isEmpty) {
        return imageScores;
      }

      final imagePrompt = '''
Analyze these complaint images and determine priority based on VISUAL EVIDENCE only.

VISUAL RULES:
- High: Visible fire, smoke, flood, collapsed structure, accident, injured person, open manhole, fallen electric pole, severe damage
- Medium: Large pothole, garbage pile, water logging, broken infrastructure, clogged drain
- Low: Graffiti, minor cracks, overgrown plants, cosmetic issues

Return ONLY JSON: {"priority": "High", "confidence": 90}
''';

      final response = await http.post(
        Uri.parse(
            "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": imagePrompt},
                ...imageParts
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data["candidates"][0]["content"]["parts"][0]["text"];
        final jsonMatch = RegExp(r'\{[^{}]*\}').firstMatch(text);

        if (jsonMatch != null) {
          final jsonData = jsonDecode(jsonMatch.group(0)!);
          final priority = jsonData['priority']?.toString().toUpperCase();

          if (priority == 'High') {
            imageScores['High'] = imageScores['High']! + 15;
          } else if (priority == 'Medium') {
            imageScores['Medium'] = imageScores['Medium']! + 10;
          } else if (priority == 'Low') {
            imageScores['Low'] = imageScores['Low']! + 5;
          }
        }
      }
    } catch (e) {
      print('Error in _analyzeImages: $e');
    }

    return imageScores;
  }

  // Helper: Download and encode image
  static Future<String> _downloadAndEncodeImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return base64Encode(response.bodyBytes);
      }
      return '';
    } catch (e) {
      print('Error downloading image: $e');
      return '';
    }
  }

  // ==================== RULE-BASED SCORING ====================
  static Map<String, int> _calculateRuleBasedScore(
      String description, String category) {
    try {
      final text = description.toLowerCase();
      Map<String, int> scores = {'High': 0, 'Medium': 0, 'Low': 0};

      // Score from keywords
      for (var level in _advancedTraining.keys) {
        final rules = _advancedTraining[level];
        if (rules != null) {
          for (var rule in rules) {
            final keywords = rule['keywords'] as List<String>?;
            if (keywords != null) {
              for (var keyword in keywords) {
                if (text.contains(keyword)) {
                  final weight = rule['weight'] as int? ?? 0;
                  scores[level] = (scores[level] ?? 0) + weight;
                }
              }
            }
          }
        }
      }

      // Score from category - WITH NULL SAFETY
      final categoryWeight = _categoryWeights[category];
      if (categoryWeight != null) {
        scores['High'] = (scores['High'] ?? 0) + (categoryWeight['High'] ?? 0);
        scores['Medium'] =
            (scores['Medium'] ?? 0) + (categoryWeight['Medium'] ?? 0);
        scores['Low'] = (scores['Low'] ?? 0) + (categoryWeight['Low'] ?? 0);
      } else {
        // Default weights for unknown categories
        scores['Medium'] = (scores['Medium'] ?? 0) + 5;
        scores['Low'] = (scores['Low'] ?? 0) + 5;
      }

      // 🔥 Special rule: Water quality should NOT be HIGH
      if (text.contains('water') &&
          (text.contains('not clean') ||
              text.contains('dirty') ||
              text.contains('contaminated') ||
              text.contains('smelly'))) {
        if ((scores['High'] ?? 0) > 0) {
          scores['Medium'] = (scores['Medium'] ?? 0) + (scores['High'] ?? 0);
          scores['High'] = 0;
        }
      }

      return scores;
    } catch (e) {
      print('Error in _calculateRuleBasedScore: $e');
      return {'High': 0, 'Medium': 5, 'Low': 5}; // Safe fallback
    }
  }

  // ==================== AI VERIFICATION (Fallback only) ====================
  static Future<String> _getAIPriority(
      String description, String category, List<String> imageUrls) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      return '';
    }

    try {
      List<Map<String, dynamic>> imageParts = [];
      for (int i = 0; i < imageUrls.length && i < 2; i++) {
        final imageData = await _downloadAndEncodeImage(imageUrls[i]);
        if (imageData.isNotEmpty) {
          imageParts.add({
            "inline_data": {"mime_type": "image/jpeg", "data": imageData}
          });
        }
      }

      final smartPrompt = '''
You are an expert city complaint analyst. Analyze this complaint.

Category: $category
Description: $description

Return ONLY ONE WORD: High, Medium, or Low
''';

      final response = await http.post(
        Uri.parse(
            "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": smartPrompt},
                ...imageParts
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data["candidates"][0]["content"]["parts"][0]["text"].toUpperCase();

        if (text.contains('High')) return 'High';
        if (text.contains('Medium')) return 'Medium';
        if (text.contains('Low')) return 'Low';
      }

      return '';
    } catch (e) {
      print('Error in _getAIPriority: $e');
      return '';
    }
  }
}
