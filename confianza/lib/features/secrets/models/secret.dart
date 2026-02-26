/// Modelo de un secreto en video
class Secret {
  final String id;
  final String userId;
  final String videoUrl;
  final String title;
  final String? description;
  final String category;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final bool isAnonymous;

  const Secret({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.title,
    this.description,
    required this.category,
    this.likes = 0,
    this.comments = 0,
    required this.createdAt,
    this.isAnonymous = true,
  });

  /// Crea una copia del Secret con campos actualizados
  Secret copyWith({
    String? id,
    String? userId,
    String? videoUrl,
    String? title,
    String? description,
    String? category,
    int? likes,
    int? comments,
    DateTime? createdAt,
    bool? isAnonymous,
  }) {
    return Secret(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      videoUrl: videoUrl ?? this.videoUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  /// Convierte el modelo a Map (para Firebase en el futuro)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'videoUrl': videoUrl,
      'title': title,
      'description': description,
      'category': category,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt.toIso8601String(),
      'isAnonymous': isAnonymous,
    };
  }

  /// Crea un Secret desde un Map (para Firebase en el futuro)
  factory Secret.fromMap(Map<String, dynamic> map) {
    return Secret(
      id: map['id'] as String,
      userId: map['userId'] as String,
      videoUrl: map['videoUrl'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      likes: map['likes'] as int? ?? 0,
      comments: map['comments'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isAnonymous: map['isAnonymous'] as bool? ?? true,
    );
  }
}
