class Flashcard {
  final String id;
  final String frontText;
  final String backText;
  final String difficultyRating; // 'unreviewed', 'easy', 'medium', 'hard'
  final String category;

  const Flashcard({
    required this.id,
    required this.frontText,
    required this.backText,
    this.difficultyRating = 'unreviewed',
    required this.category,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      frontText: json['frontText'] as String,
      backText: json['backText'] as String,
      difficultyRating: json['difficultyRating'] as String? ?? 'unreviewed',
      category: json['category'] as String? ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'frontText': frontText,
      'backText': backText,
      'difficultyRating': difficultyRating,
      'category': category,
    };
  }

  Flashcard copyWith({
    String? id,
    String? frontText,
    String? backText,
    String? difficultyRating,
    String? category,
  }) {
    return Flashcard(
      id: id ?? this.id,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      difficultyRating: difficultyRating ?? this.difficultyRating,
      category: category ?? this.category,
    );
  }
}

class FlashcardDeck {
  final String id;
  final String title;
  final String category;
  final List<Flashcard> cards;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FlashcardDeck({
    required this.id,
    required this.title,
    required this.category,
    required this.cards,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FlashcardDeck.fromJson(Map<String, dynamic> json) {
    return FlashcardDeck(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String? ?? 'General',
      cards: (json['cards'] as List<dynamic>?)
              ?.map((c) => Flashcard.fromJson(Map<String, dynamic>.from(c)))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'cards': cards.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  FlashcardDeck copyWith({
    String? id,
    String? title,
    String? category,
    List<Flashcard>? cards,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FlashcardDeck(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      cards: cards ?? this.cards,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
