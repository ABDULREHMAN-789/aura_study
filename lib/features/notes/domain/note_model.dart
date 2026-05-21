class StudyNote {
  final String id;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final bool isPinned;
  final String colorHex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudyNote({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    required this.isPinned,
    required this.colorHex,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Automatically truncated preview of the content for note card display
  String get snippet {
    final cleanContent = content.trim();
    if (cleanContent.length <= 120) return cleanContent;
    return '${cleanContent.substring(0, 117)}...';
  }

  factory StudyNote.fromJson(Map<String, dynamic> json) {
    return StudyNote(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String? ?? 'General',
      tags: List<String>.from(json['tags'] ?? []),
      isPinned: json['isPinned'] as bool? ?? false,
      colorHex: json['colorHex'] as String? ?? '0xFF00F0FF',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'tags': tags,
      'isPinned': isPinned,
      'colorHex': colorHex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  StudyNote copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    bool? isPinned,
    String? colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
