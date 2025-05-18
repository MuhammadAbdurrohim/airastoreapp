class LiveComment {
  final String id;
  final String streamId;
  final Map<String, dynamic> user;
  final String content;
  final DateTime createdAt;

  LiveComment({
    required this.id,
    required this.streamId,
    required this.user,
    required this.content,
    required this.createdAt,
  });

  factory LiveComment.fromJson(Map<String, dynamic> json) {
    return LiveComment(
      id: json['id'].toString(),
      streamId: json['stream_id'].toString(),
      user: Map<String, dynamic>.from(json['user'] ?? {}),
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stream_id': streamId,
      'user': user,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get userName => user['name'] ?? 'Unknown User';
  String get userAvatar => user['avatar_url'] ?? '';

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  LiveComment copyWith({
    String? id,
    String? streamId,
    Map<String, dynamic>? user,
    String? content,
    DateTime? createdAt,
  }) {
    return LiveComment(
      id: id ?? this.id,
      streamId: streamId ?? this.streamId,
      user: user ?? this.user,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveComment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          streamId == other.streamId &&
          user == other.user &&
          content == other.content &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      streamId.hashCode ^
      user.hashCode ^
      content.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'LiveComment{id: $id, userName: $userName, content: $content}';
  }
}
