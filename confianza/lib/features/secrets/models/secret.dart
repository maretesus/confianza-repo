/// Modelo de un secreto en video
class Secret {
  final String id;
  final String? userId; // Nullable para permitir secretos anónimos sin login
  final String videoUrl;
  final String title;
  final String? description;
  final String category;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final bool isAnonymous;
  final List<String> likedByUserIds; // Lista de UIDs que han dado like

  const Secret({
    required this.id,
    this.userId,
    required this.videoUrl,
    required this.title,
    this.description,
    required this.category,
    this.likes = 0,
    this.comments = 0,
    required this.createdAt,
    this.isAnonymous = true,
    this.likedByUserIds = const [],
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
    List<String>? likedByUserIds,
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
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
    );
  }

  /// Convierte el modelo a Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'videoUrl': videoUrl,
      'title': title,
      'description': description,
      'category': category,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt,
      'isAnonymous': isAnonymous,
      'likedByUserIds': likedByUserIds,
    };
  }

  /// Crea un Secret desde un Map (desde Firestore)
  factory Secret.fromMap(Map<String, dynamic> map, String id) {
    return Secret(
      id: id,
      userId: map['userId'] as String?,
      videoUrl: map['videoUrl'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      likes: map['likes'] as int? ?? 0,
      comments: map['comments'] as int? ?? 0,
      createdAt: (map['createdAt'] as dynamic).toDate(),
      isAnonymous: map['isAnonymous'] as bool? ?? true,
      likedByUserIds: List<String>.from(map['likedByUserIds'] as List? ?? []),
    );
  }
}
