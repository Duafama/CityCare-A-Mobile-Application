import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  // ==================== TRAINING DATA ====================
  static final Map<String, List<Map<String, dynamic>>> _advancedTraining = {
    'HIGH': [
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
    'MEDIUM': [
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
    'LOW': [
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

  static final Map<String, Map<String, int>> _categoryWeights = {
    'Emergency': {'HIGH': 20, 'MEDIUM': 0, 'LOW': 0},
    'Safety': {'HIGH': 15, 'MEDIUM': 5, 'LOW': 0},
    'Infrastructure': {'HIGH': 5, 'MEDIUM': 10, 'LOW': 2},
    'Roads': {'HIGH': 8, 'MEDIUM': 8, 'LOW': 1},
    'Water & Drainage': {
      'HIGH': 0,
      'MEDIUM': 12,
      'LOW': 3
    }, // Fixed: No HIGH for water
    'Waste Management': {
      'HIGH': 0,
      'MEDIUM': 10,
      'LOW': 5
    }, // Fixed: No HIGH for waste
    'Electricity': {'HIGH': 10, 'MEDIUM': 6, 'LOW': 1},
    'Public Health': {'HIGH': 15, 'MEDIUM': 5, 'LOW': 0},
    'Other': {'HIGH': 0, 'MEDIUM': 5, 'LOW': 5},
  };

  // ==================== MAIN FUNCTION - Keyword First, AI Fallback ====================
  static Future<String> getPriority({
    required String description,
    required String category,
    required List<String> imageUrls,
  }) async {
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
    return 'MEDIUM';
  }

  // ==================== KEYWORD PRIORITY (Primary) ====================
  static String? _getKeywordPriority(String description, String category) {
    final ruleScore = _calculateRuleBasedScore(description, category);

    // Calculate total score
    int highScore = ruleScore['HIGH'] ?? 0;
    int mediumScore = ruleScore['MEDIUM'] ?? 0;
    int lowScore = ruleScore['LOW'] ?? 0;

    // If any score is significantly higher, return it
    if (highScore > mediumScore && highScore > lowScore && highScore >= 5) {
      return 'HIGH';
    }
    if (lowScore > highScore && lowScore > mediumScore && lowScore >= 3) {
      return 'LOW';
    }
    if (mediumScore > 0 &&
        mediumScore >= highScore &&
        mediumScore >= lowScore) {
      return 'MEDIUM';
    }

    // No clear keyword match
    return null;
  }

  // ==================== IMAGE ANALYSIS ====================
  static Future<Map<String, int>> _analyzeImages(List<String> imageUrls) async {
    Map<String, int> imageScores = {'HIGH': 0, 'MEDIUM': 0, 'LOW': 0};

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
- HIGH: Visible fire, smoke, flood, collapsed structure, accident, injured person, open manhole, fallen electric pole, severe damage
- MEDIUM: Large pothole, garbage pile, water logging, broken infrastructure, clogged drain
- LOW: Graffiti, minor cracks, overgrown plants, cosmetic issues

Return ONLY JSON: {"priority": "HIGH", "confidence": 90}
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

          if (priority == 'HIGH') {
            imageScores['HIGH'] = imageScores['HIGH']! + 15;
          } else if (priority == 'MEDIUM') {
            imageScores['MEDIUM'] = imageScores['MEDIUM']! + 10;
          } else if (priority == 'LOW') {
            imageScores['LOW'] = imageScores['LOW']! + 5;
          }
        }
      }
    } catch (e) {
      // Silent fail
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
      return '';
    }
  }

  // ==================== RULE-BASED SCORING ====================
  static Map<String, int> _calculateRuleBasedScore(
      String description, String category) {
    final text = description.toLowerCase();
    Map<String, int> scores = {'HIGH': 0, 'MEDIUM': 0, 'LOW': 0};

    // Score from keywords
    for (var level in _advancedTraining.keys) {
      for (var rule in _advancedTraining[level]!) {
        for (var keyword in rule['keywords'] as List<String>) {
          if (text.contains(keyword)) {
            scores[level] = scores[level]! + (rule['weight'] as int);
          }
        }
      }
    }

    // Score from category
    final categoryWeight = _categoryWeights[category];
    if (categoryWeight != null) {
      scores['HIGH'] = scores['HIGH']! + (categoryWeight['HIGH'] ?? 0);
      scores['MEDIUM'] = scores['MEDIUM']! + (categoryWeight['MEDIUM'] ?? 0);
      scores['LOW'] = scores['LOW']! + (categoryWeight['LOW'] ?? 0);
    }

    // 🔥 Special rule: Water quality should NOT be HIGH
    if (text.contains('water') &&
        (text.contains('not clean') ||
            text.contains('dirty') ||
            text.contains('contaminated') ||
            text.contains('smelly'))) {
      if (scores['HIGH']! > 0) {
        scores['MEDIUM'] = scores['MEDIUM']! + scores['HIGH']!;
        scores['HIGH'] = 0;
      }
    }

    return scores;
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

Return ONLY ONE WORD: HIGH, MEDIUM, or LOW
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

        if (text.contains('HIGH')) return 'HIGH';
        if (text.contains('MEDIUM')) return 'MEDIUM';
        if (text.contains('LOW')) return 'LOW';
      }

      return '';
    } catch (e) {
      return '';
    }
  }
}
