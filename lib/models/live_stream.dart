class LiveStream {
  final String id;
  final String title;
  final String thumbnailPath;
  final Map<String, dynamic> user;
  final int viewerCount;
  final List<Map<String, dynamic>> products;
  final String status;
  final DateTime createdAt;

  LiveStream({
    required this.id,
    required this.title,
    required this.thumbnailPath,
    required this.user,
    required this.viewerCount,
    required this.products,
    required this.status,
    required this.createdAt,
  });

  factory LiveStream.fromJson(Map<String, dynamic> json) {
    return LiveStream(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled Stream',
      thumbnailPath: json['thumbnail_path'] ?? '',
      user: Map<String, dynamic>.from(json['user'] ?? {}),
      viewerCount: json['viewer_count'] ?? 0,
      products: List<Map<String, dynamic>>.from(json['products'] ?? []),
      status: json['status'] ?? 'inactive',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail_path': thumbnailPath,
      'user': user,
      'viewer_count': viewerCount,
      'products': products,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';

  String get hostName => user['name'] ?? 'Unknown Host';
  
  String get hostAvatar => user['avatar_url'] ?? '';

  int get productCount => products.length;

  String get formattedViewerCount {
    if (viewerCount >= 1000000) {
      return '${(viewerCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewerCount >= 1000) {
      return '${(viewerCount / 1000).toStringAsFixed(1)}K';
    }
    return viewerCount.toString();
  }

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

  LiveStream copyWith({
    String? id,
    String? title,
    String? thumbnailPath,
    Map<String, dynamic>? user,
    int? viewerCount,
    List<Map<String, dynamic>>? products,
    String? status,
    DateTime? createdAt,
  }) {
    return LiveStream(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      user: user ?? this.user,
      viewerCount: viewerCount ?? this.viewerCount,
      products: products ?? this.products,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveStream &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          thumbnailPath == other.thumbnailPath &&
          user == other.user &&
          viewerCount == other.viewerCount &&
          products == other.products &&
          status == other.status &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      thumbnailPath.hashCode ^
      user.hashCode ^
      viewerCount.hashCode ^
      products.hashCode ^
      status.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'LiveStream{id: $id, title: $title, viewerCount: $viewerCount, status: $status}';
  }
}
