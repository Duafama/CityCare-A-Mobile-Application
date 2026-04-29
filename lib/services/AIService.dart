import 'package:safe_text/safe_text.dart';

class AIService {
  static bool _isInitialized = false;
  
  // Aapki custom bad words list (same as before)
  static final List<String> _customBadWords = [
    // English
    'stupid', 'idiot', 'fool', 'dumb', 'moron', 'loser',
    'shut up', 'nonsense', 'rubbish', 'useless', 'worthless',
    'liar', 'fraud', 'cheat', 'incompetent', 'pathetic',
    'shameless', 'disgrace', 'scum', 'trash', 'criminal',

    // Urdu / Roman Urdu
    'bakwas', 'nalayak', 'ahmaq', 'bewakoof', 'pagal',
    'beghairat', 'bekaar', 'nalaik', 'badtameez', 'gustakh',
    'ghatiya', 'naayhal', 'chawal', 'kamina', 'kameena',
    'lafanga', 'harami', 'haramzaada', 'naali',
    'gadha', 'gadhe', 'ullu', 'suar', 'kutta', 'kutiya',
    'jhootha', 'jhoothi', 'chor', 'dhokebaaz', 'munafiq',
    'dagabaaz', 'besharam', 'behaya', 'zalim', 'jaahil',
    'anparh', 'ganwar', 'badmash', 'awara', 'mawali',
    'goonda', 'nikamma', 'buzdil', 'darpok',
    
    // Additional moderate words
    'jhalli', 'jhalla', 'sasta', 'ghaleez', 'badnaam',
    'badkaar', 'bayghairat', 'be-izzat', 'bayizzat',
    'zillat', 'ruswa', 'dhoka', 'faraib', 'makkar',
    'faraibi', 'makkaar', 'khosar', 'naamard', 'kayar',
    'choor', 'uchaakka', 'thag', 'thagi', 'lootay',
    'tangay', 'phakkar', 'awaargi', 'badchalan',
    'be-adab', 'beadab', 'gustakhi', 'taanay',

    // Bypass Variations (leetspeak - safe_text automatically handles these)
    // Note: safe_text already normalizes leet, so many variations may not be needed
    'b3waqoof', 'p@gal', 'idi0t', 'kam1na',
  ];
  static final List<String> _governmentKeywords = [

    'Govt','govt','authority', 'authorities', 'municipal', 'municipality',
  'corporation', 'commissioner', 'secretary', 'bureaucracy',
  'bureaucrat', 'official', 'officials', 'administration',
  'administrative', 'public works', 'civil service',
  'department', 'ministry', 'minister', 'cabinet',
  'council', 'councillor', 'mayor', 'deputy commissioner',
  'dc office', 'dco', 'ac', 'assistant commissioner',
  'government should', 'government must', 'government is',
  'sarkar ko', 'hakomat ko', 'government ne',
  'government nay', 'authority should', 'authority is',
  
  // Position holders (often imply government)
  'cm', 'c.m.', 'chief minister', 'prime minister', 'pm',
  'president', 'governor', 'dco', 'd.c.o.', 'commissioner',
  'secretary of', 'director of',
  
  // Department names (common in complaints)
  'local government', 'lgd', 'public health', 'pwd',
  'works department', 'irrigation department',
  'water and sanitation', 'wasa', 'mcl', 'cda', 'lda',
  
  // Additional Roman Urdu
  'hukumat', 'hokomat', 'sarkaar', 'sarakaar', 'sirkar',
  'hukumati', 'sarkaari', 'hakumat', 'hakomat',
  ];

  // Initialize safe_text (call this once in main.dart)
  static Future<void> initialize() async {
    if (!_isInitialized) {
      // Using English and Hindi (Hindi helps with common South Asian words)
      await SafeTextFilter.init(
        languages: [Language.english, Language.hindi],
      );
      _isInitialized = true;
    }
  }

  // ✅ Updated: Now checks government keywords + profanity
  // Returns true if SAFE to show publicly, false if flagged
  Future<bool> moderateComment(String text) async {
    await AIService.initialize();
    
    final String cleanedText = text.trim().toLowerCase();
    
    // 1. Check government keywords (ANY mention -> flag)
    for (String keyword in _governmentKeywords) {
      if (cleanedText.contains(keyword.toLowerCase())) {
        return false;   // flagged, goes to admin review
      }
    }
    bool containsBadWord = await SafeTextFilter.containsBadWord(
  text: cleanedText,
  extraWords: _customBadWords,
  useDefaultWords: true,
);
    return !containsBadWord; // true = safe, false = bad word found
  }
}
