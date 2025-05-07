import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:fsrs/fsrs.dart' as SpacedRepetition;

class SharedPrefsStorage {
  static const String _decksKey = 'decks';
  // static const String _decksMappingKey = 'decksIdMapping';
  static const Map<SpacedRepetition.State, String> stateMapping = {
    SpacedRepetition.State.newState: 'newState',
    SpacedRepetition.State.learning: 'learning',
    SpacedRepetition.State.review: 'review',
    SpacedRepetition.State.relearning: 'relearning',
  };
  static const Uuid uuid = Uuid();

  static Future<String?> getDeckId(String deckName) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');

    // Iterate through the map to find the deckID
    for (var entry in decks.entries) {
      if (entry.value['deckName'] == deckName) {
        return entry.key; // Return the matching deck ID
      }
    }

    return null; // Return null if not found
  }

  static Future<void> saveDeck(String deckName) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');

    if (await getDeckId(deckName) == null) {
      String deckId = uuid.v4();
      decks[deckId] = {
        'deckName': deckName,
        'dailyLimit': 2,
        'currentLimit': 0,
        'learning': {},
        'review': {},
        'relearning': {},
        'newState': {},
        'dueCount': 0,
      };
    }

    await prefs.setString(_decksKey, jsonEncode(decks));
  }

  static Future<List<Map<String, dynamic>>> getDecksWithDetails() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');
    List<Map<String, dynamic>> deckList = [];

    for (var entry in decks.entries) {
      Map<String, dynamic> deck = entry.value;

      deckList.add({
        'deckName': deck['deckName'],
        'deckId': entry.key,
        'learningCount': deck['learning']?.length ?? 0,
        'relearningCount': deck['relearning']?.length ?? 0,
        'reviewCount': deck['review']?.length ?? 0,
        'newCount': deck['newState']?.length ?? 0,
        'dueCount': deck['dueCount'] ?? 0,
      });
    }

    // // Load stored mappings and decks
    // Map<String, dynamic> decksIdMapping = jsonDecode(
    //   prefs.getString(_decksMappingKey) ?? '{}',
    // );

    // List<Map<String, dynamic>> deckList = [];

    // // Iterate through decks and extract relevant details
    // decksIdMapping.forEach((deckName, deckId) {
    //   if (decks.containsKey(deckId)) {
    //     Map<String, dynamic> deck = decks[deckId];

    //     deckList.add({
    //       'deckName': deckName,
    //       'deckId': deckId,
    //       'learningCount': deck['learning']?.length ?? 0,
    //       'relearningCount': deck['relearning']?.length ?? 0,
    //       'reviewCount': deck['review']?.length ?? 0,
    //       'newCount': deck['newState']?.length ?? 0,
    //       'dueCount': deck['dueCount'] ?? 0,
    //     });
    //   }
    // });

    return deckList;
  }

  static Future<bool> renameDeck(
    String oldDeckName,
    String newDeckName,
    String deckId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');

    if (decks[deckId]['deckName'] == oldDeckName) {
      decks[deckId]['deckName'] = newDeckName;
      await prefs.setString(_decksKey, jsonEncode(decks));
      return true;
    }

    return false;
    // String? deckId = await getDeckId(oldDeckName);

    // if(deckId !=null){

    // }

    // if (decksIdMapping.containsKey(oldDeckName) &&
    //     !decksIdMapping.containsKey(newDeckName)) {
    //   String deckId = decksIdMapping[oldDeckName]!;
    //   decksIdMapping.remove(oldDeckName);
    //   decksIdMapping[newDeckName] = deckId;
    //   await prefs.setString(_decksMappingKey, jsonEncode(decksIdMapping));
    //   return true;
    // }
    // return false;
  }

  static Future<void> deleteDeck(String deckId) async {
    final prefs = await SharedPreferences.getInstance();
    // Map<String, dynamic> decksIdMapping = jsonDecode(
    //   prefs.getString(_decksMappingKey) ?? '{}',
    // );
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');
    decks.remove(deckId);

    // if (decksIdMapping.containsKey(deckName)) {
    //   String deckId = decksIdMapping[deckName]!;
    //   decks.remove(deckId);
    //   decksIdMapping.remove(deckName);
    // }

    // await prefs.setString(_decksMappingKey, jsonEncode(decksIdMapping));
    await prefs.setString(_decksKey, jsonEncode(decks));
  }

  static Future<void> updateDeckValue(
    String deckId,
    String key,
    dynamic value,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Load existing mappings and decks
    // Map<String, dynamic> decksIdMapping = jsonDecode(
    //   prefs.getString(_decksMappingKey) ?? '{}',
    // );
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');

    // Ensure the deck exists
    // if (!decksIdMapping.containsKey(deckName)) return;

    // String deckId = decksIdMapping[deckName]!;

    // Ensure the deck contains the key
    if (!decks[deckId].containsKey(key)) return;

    // Update the key with the new value
    decks[deckId][key] = value;

    // Save the updated decks
    await prefs.setString(_decksKey, jsonEncode(decks));
  }

  static Future<dynamic> getDeckValue(String deckId, String key) async {
    final prefs = await SharedPreferences.getInstance();

    // Load existing mappings and decks
    // Map<String, dynamic> decksIdMapping = jsonDecode(
    //   prefs.getString(_decksMappingKey) ?? '{}',
    // );
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');

    // Ensure the deck exists
    // if (!decksIdMapping.containsKey(deckName)) return;

    // String deckId = decksIdMapping[deckName]!;

    // Ensure the deck contains the key
    if (!decks[deckId].containsKey(key)) return null;

    return decks[deckId][key];

    // // Update the key with the new value
    // decks[deckId][key] = value;

    // // Save the updated decks
    // await prefs.setString(_decksKey, jsonEncode(decks));
  }

  static Future<Map<String, dynamic>?> getDeckDetails(String deckId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Map<String, dynamic> decksIdMapping = jsonDecode(
    //   prefs.getString(_decksMappingKey) ?? '{}',
    // );
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');

    // Ensure the deck exists
    // if (!decksIdMapping.containsKey(deckName)) return {};

    // String deckId = decksIdMapping[deckName]!;

    Map<String, dynamic> deck = decks[deckId];
    print("AAAAAAAAA ${deck['learning'].keys}");

    return {
      'deckName': deck['deckName'],
      'dailyLimit': deck['dailyLimit'],
      'totalCards':
          (deck['learning'].keys.length +
              deck['relearning'].keys.length +
              deck['newState'].keys.length +
              deck['review'].keys.length),
    };

    // Return null if deck not found
  }

  static Future<void> addFlashcard(
    String deckId,
    String question,
    String answer,
    dynamic card,
    dynamic reviewLog,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    // Map<String, dynamic> decksIdMapping = jsonDecode(
    //   prefs.getString(_decksMappingKey) ?? '{}',
    // );
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');

    // if (!decksIdMapping.containsKey(deckName)) return;

    // String deckId = decksIdMapping[deckName]!;
    String flashcardId = uuid.v4();

    Map<String, dynamic> flashcard = {
      'question': question,
      'answer': answer,
      'card': card,
      'reviewLog': reviewLog,
    };

    // Add to the appropriate category (assuming newCards for now)
    decks[deckId]['newState'][flashcardId] = flashcard;

    await prefs.setString(_decksKey, jsonEncode(decks));
  }

  static Future<List<Map>> getFlashcards(String deckId) async {
    final prefs = await SharedPreferences.getInstance();
    // Map<String, dynamic> decksIdMapping = jsonDecode(
    //   prefs.getString(_decksMappingKey) ?? '{}',
    // );
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');

    // if (!decksIdMapping.containsKey(deckName)) return [];

    // String deckId = decksIdMapping[deckName]!;
    print("@@@@@@@@@@@@@@@@@@@@@@@@ ${(decks[deckId])}");
    // Map<String, dynamic> deckSpecificData = jsonDecode(decks[deckId]);

    Map<String, dynamic> safeDecode(dynamic value) {
      if (value is String && value.isNotEmpty) {
        try {
          return jsonDecode(value);
        } catch (e) {
          print("JSON Decode Error: $e");
          return {}; // Return empty object if decoding fails
        }
      }
      return value is Map<String, dynamic> ? value : {}; // Ensure it's a Map
    }

    Map<String, dynamic> allFlashcards = {
      ...safeDecode(decks[deckId]['learning']),
      ...safeDecode(decks[deckId]['review']),
      ...safeDecode(decks[deckId]['relearning']),
      ...safeDecode(decks[deckId]['newState']),
    };

    print("@@@@@@@@@@@@@@@@@@@@ $allFlashcards");

    // Convert the map into a list of objects, including the ID
    return allFlashcards.entries.map((entry) {
      print("@@@@@@@@@@@@@@@ ${entry.key} ${entry.value}");
      return {
        'id': entry.key, // Flashcard ID
        ...(entry.value), // Flashcard data (question, answer, etc.)
      };
    }).toList();
  }

  static Future<void> editFlashcard(
    String deckId,
    String category,
    String flashcardId, {
    String? newQuestion,
    String? newAnswer,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // Map<String, dynamic> decksIdMapping = jsonDecode(
    //   prefs.getString(_decksMappingKey) ?? '{}',
    // );
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');

    // if (!decksIdMapping.containsKey(deckName)) return;

    // String deckId = decksIdMapping[deckName]!;

    if (decks[deckId][category].containsKey(flashcardId)) {
      if (newQuestion != null) {
        decks[deckId][category][flashcardId]['question'] = newQuestion;
      }
      if (newAnswer != null) {
        decks[deckId][category][flashcardId]['answer'] = newAnswer;
      }
      await prefs.setString(_decksKey, jsonEncode(decks));
    }
  }

  static Future<void> deleteFlashcard(
    String deckId,
    String category,
    String flashcardId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    // Map<String, dynamic> decksIdMapping = jsonDecode(
    //   prefs.getString(_decksMappingKey) ?? '{}',
    // );
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');

    // if (!decksIdMapping.containsKey(deckName)) return;

    // String deckId = decksIdMapping[deckName]!;

    if (decks[deckId][category].containsKey(flashcardId)) {
      decks[deckId][category].remove(flashcardId);
      await prefs.setString(_decksKey, jsonEncode(decks));
    }
  }

  static Future<void> updateFlashcardCategory(
    String deckId,
    String category,
    String flashcardId,
    Map<String, dynamic> flashcard,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Load stored mappings and decks
    // Map<String, dynamic> decksIdMapping = jsonDecode(
    //   prefs.getString(_decksMappingKey) ?? '{}',
    // );
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');

    // if (!decksIdMapping.containsKey(deckName)) return; // Deck doesn't exist

    // String deckId = decksIdMapping[deckName]!;

    print("@@@@@@@@@@@@@@ ${flashcard['card']} $flashcard");
    print("@@@@@@@@@@@@@@ ${flashcard['card'].state}");
    String? currentCategory = stateMapping[flashcard['card'].state];
    print("@@@@@@@@@@@@@@@@@@@@@ $currentCategory $deckId $category");

    // Determine the current category of the flashcard
    // String? currentCategory;
    // for (String cat in [
    //   'learningCards',
    //   'reviewCards',
    //   'relearningCards',
    //   'newCards',
    // ]) {
    //   if (decks[deckId][cat].any((card) => card['id'] == flashcardId)) {
    //     currentCategory = cat;
    //     break;
    //   }
    // }

    // If the category is the same, do nothing
    if (currentCategory == category) return;

    print("flashcard $flashcard");

    // Remove the flashcard from its current category
    if (decks[deckId][category].containsKey(flashcardId)) {
      decks[deckId][category].remove(flashcardId);
      print("flashcard removed to $category");
    }
    // Add the flashcard to the new category
    decks[deckId][currentCategory][flashcardId] = flashcard;
    print("flashcard moved to $currentCategory");

    // Check due date and update dueCount if it's today
    DateTime now = DateTime.now();
    DateTime dueDate = flashcard['card'].due;
    // Ensure dueDate is stored as an ISO string
    if (dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day) {
      decks[deckId]['dueCount'] += 1;
    }

    // Increment the currentLimit
    decks[deckId]['currentLimit'] += 1;

    // Save updated data
    await prefs.setString(_decksKey, jsonEncode(decks));
  }

  static Future<List<Map<String, dynamic>>> fetchDueFlashcards(
    String deckId,
    int N,
  ) async {
    //First Learning,releraning, remaining 40% of review , all remaing to new

    final prefs = await SharedPreferences.getInstance();

    // Load stored mappings and decks
    // Map<String, dynamic> decksIdMapping = jsonDecode(
    //   prefs.getString(_decksMappingKey) ?? '{}',
    // );
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');

    // if (!decksIdMapping.containsKey(deckName)) return []; // Deck doesn't exist

    // String deckId = decksIdMapping[deckName]!;
    List<Map<String, dynamic>> resultFlashcards = [];

    print('@@@@@@@@@@@@@@@ decks data ${decks[deckId]}');

    // Function to extract and sort flashcards from a category
    List<Map> getSortedFlashcards(String category) {
      // Ensure the category exists and is a Map
      // if()
      // if (decks[deckId][category] is! Map) return [];
      print("@@@@@@@@@@@@@@@@@ decks ${decks[deckId]}");

      Map<String, dynamic> categoryMap = decks[deckId][category] ?? {};

      print(
        "@@@@@@@@@@@@@@@@@ map ${decks[deckId][category]} $category $categoryMap",
      );

      // Extract flashcards as a list
      List<Map> cards =
          categoryMap.entries.map((entry) {
            return {
              'id': entry.key, // Flashcard ID
              ...entry.value, // Flashcard Data
            };
          }).toList();

      // Sort by due date (oldest first)
      cards.sort(
        (a, b) => DateTime.parse(
          a['card']['due'],
        ).compareTo(DateTime.parse(b['card']['due'])),
      );

      return cards;
    }

    // Fetch and append cards from each category in priority order
    for (String category in ['learning', 'relearning']) {
      if (resultFlashcards.length >= N) break;

      List<Map> sortedCards = getSortedFlashcards(category);
      print("@@@@@@@@@@@@@@@@@@ $sortedCards $category");

      for (var card in sortedCards) {
        if (resultFlashcards.length >= N) break;
        resultFlashcards.add(card.cast<String, dynamic>());
      }
    }

    List<Map> reviewSortedCards = getSortedFlashcards('review');
    List<Map> newSortedCards = getSortedFlashcards('newState');

    int remainingCards = (N - resultFlashcards.length);
    int reviewCards =
        (((remainingCards * 0.4).floor()) > reviewSortedCards.length)
            ? ((remainingCards * 0.4).floor())
            : reviewSortedCards.length;
    int newCards = (remainingCards - reviewCards);

    print("@@@@@@@@@@@@@@@@@@@@ reviewCards:$reviewCards newCards:$newCards");

    // Add `reviewCards` number of cards from `reviewSortedCards` to `res`
    resultFlashcards.addAll(
      reviewSortedCards
          .take(reviewCards)
          .map((card) => card.cast<String, dynamic>()),
    );

    // Add `newCards` number of cards from `newSortedCards` to `res`
    resultFlashcards.addAll(
      newSortedCards.take(newCards).map((card) => card.cast<String, dynamic>()),
    );

    return resultFlashcards;
  }

  static Future<void> syncDueCounts() async {
    final prefs = await SharedPreferences.getInstance();

    // Load stored decks and their mapping
    // Map<String, dynamic> decksIdMapping = jsonDecode(
    //   prefs.getString(_decksMappingKey) ?? '{}',
    // );
    Map<String, dynamic> decks = jsonDecode(prefs.getString(_decksKey) ?? '{}');

    DateTime now = DateTime.now();

    for (var deckId in decks.keys) {
      // String deckId = decksIdMapping[deckName]!;
      // if (!decks.containsKey(deckId)) continue;

      int dueCount = 0;

      // Categories to check
      List<String> categories = [
        'newState',
        'learning',
        'relearning',
        'review',
      ];

      for (var category in categories) {
        if (decks[deckId][category] is! Map) {
          continue; // Ensure it's a valid map
        }

        decks[deckId][category].forEach((flashcardId, flashcard) {
          if (flashcard is! Map || !flashcard.containsKey('card')) return;

          var rawDue = flashcard['card']['due'];
          DateTime dueDate = rawDue is String ? DateTime.parse(rawDue) : rawDue;

          if (dueDate.isBefore(now) || dueDate.isAtSameMomentAs(now)) {
            dueCount++;
          }
        });
      }

      // Update the due count in the deck
      decks[deckId]['dueCount'] = dueCount;
      print("syncing deck ${decks[deckId]['deckName']} & dueCount $dueCount");
    }

    print("sync completed");
    // Save updated decks back to SharedPreferences
    await prefs.setString('decks', jsonEncode(decks));
  }
}






  // static Future<List<String>> getDecks() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   Map<String, dynamic> decksIdMapping = jsonDecode(
  //     prefs.getString(_decksMappingKey) ?? '{}',
  //   );
  //   return decksIdMapping.keys.toList();
  // }


// static Future<void> saveDeck(String deckName) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   List<String> decks = prefs.getStringList(_decksKey) ?? [];

  //   // Store as JSON object
  //   Map<String, dynamic> newDeck = {'name': deckName, 'flashcards': []};

  //   decks.add(jsonEncode(newDeck));
  //   await prefs.setStringList(_decksKey, decks);
  // }

  // static Future<List> getDecks() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   List<String> decks = prefs.getStringList(_decksKey) ?? [];

  //   return decks.map((deck) => jsonDecode(deck)).toList();
  // }

  // static Future<void> deleteDeck(String deckName) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   List<String> decks = prefs.getStringList(_decksKey) ?? [];

  //   decks.removeWhere((deck) {
  //     final Map<String, dynamic> decodedDeck = jsonDecode(deck);
  //     return decodedDeck['name'] == deckName;
  //   });

  //   await prefs.setStringList(_decksKey, decks);
  // }

 
  // static Future<void> addFlashcard(
  //   String deckName,
  //   String question,
  //   String answer,
  //   SpacedRepetition.Card card,
  //   SpacedRepetition.ReviewLog reviewLog,
  // ) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   List<String> decks = prefs.getStringList(_decksKey) ?? [];

  //   List decodedDecks = decks.map((deck) => jsonDecode(deck)).toList();

  //   for (var deck in decodedDecks) {
  //     if (deck['name'] == deckName) {
  //       deck['flashcards'].add({'question': question, 'answer': answer});
  //       break;
  //     }
  //   }

  //   List<String> updatedDecks =
  //       decodedDecks.map((deck) => jsonEncode(deck)).toList();
  //   await prefs.setStringList(_decksKey, updatedDecks);
  // }

  // static Future<List<Map<String, dynamic>>> getFlashcards(
  //   String deckName,
  // ) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   List<String> decks = prefs.getStringList(_decksKey) ?? [];

  //   for (String deck in decks) {
  //     final Map<String, dynamic> decodedDeck = jsonDecode(deck);
  //     if (decodedDeck['name'] == deckName) {
  //       return List<Map<String, dynamic>>.from(decodedDeck['flashcards']);
  //     }
  //   }
  //   return [];
  // }
