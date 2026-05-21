class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
    };
  }

  QuizQuestion copyWith({
    String? question,
    List<String>? options,
    int? correctIndex,
    String? explanation,
  }) {
    return QuizQuestion(
      question: question ?? this.question,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
    );
  }
}

class QuizSession {
  final String id;
  final String title;
  final String category;
  final List<QuizQuestion> questions;
  final int score; // -1 if not attempted yet
  final DateTime? completedAt;

  const QuizSession({
    required this.id,
    required this.title,
    required this.category,
    required this.questions,
    this.score = -1,
    this.completedAt,
  });

  bool get isAttempted => score >= 0;

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String? ?? 'General',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromJson(Map<String, dynamic>.from(q)))
              .toList() ??
          [],
      score: json['score'] as int? ?? -1,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'questions': questions.map((q) => q.toJson()).toList(),
      'score': score,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  QuizSession copyWith({
    String? id,
    String? title,
    String? category,
    List<QuizQuestion>? questions,
    int? score,
    DateTime? completedAt,
  }) {
    return QuizSession(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      questions: questions ?? this.questions,
      score: score ?? this.score,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
