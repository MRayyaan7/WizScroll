/// A scenario mapped to a specific audience.
class QuoteScenario {
  final String audience;
  final String text;

  const QuoteScenario({
    required this.audience,
    required this.text,
  });

  factory QuoteScenario.fromMap(Map<String, dynamic> data) {
    return QuoteScenario(
      audience: data['audience'] as String? ?? 'general',
      text: data['text'] as String? ?? '',
    );
  }
}

/// Quote data model mapping to a Firestore document in the `quotes` collection.
class Quote {
  final String id;
  final String quoteText;
  final String author;
  final String authorCategory;
  final String source;
  final String confidence;
  final List<String> categoryTags;
  final String explanation;
  final List<QuoteScenario> realLifeScenarios;
  final int likeCount;
  final DateTime createdAt;
  final bool active;

  const Quote({
    required this.id,
    required this.quoteText,
    required this.author,
    required this.authorCategory,
    required this.source,
    required this.confidence,
    required this.categoryTags,
    required this.explanation,
    required this.realLifeScenarios,
    required this.likeCount,
    required this.createdAt,
    required this.active,
  });

  /// Constructs a [Quote] from a Firestore document snapshot map.
  factory Quote.fromFirestore(Map<String, dynamic> data, String docId) {
    return Quote(
      id: docId,
      quoteText: data['quoteText'] as String? ?? '',
      author: data['author'] as String? ?? 'Unknown',
      authorCategory:
          (data['authorCategory'] as String? ?? 'other').toLowerCase(),
      source: data['source'] as String? ?? '',
      confidence: data['confidence'] as String? ?? 'commonly_attributed',
      categoryTags: List<String>.from(data['categoryTags'] as List? ?? []),
      explanation: data['explanation'] as String? ?? '',
      realLifeScenarios: (data['realLifeScenarios'] as List? ?? [])
          .map((e) => QuoteScenario.fromMap(e as Map<String, dynamic>))
          .toList(),
      likeCount: data['likeCount'] as int? ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate() as DateTime
          : DateTime.now(),
      active: data['active'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'Quote(id: $id, author: $author)';
}
