// lib/data/models/sermon_media_item.dart

class SermonMediaItem {
  final String id;
  final String tenantId; // Injects multi-tenant partitioning boundaries
  final String title;
  final String speaker;
  final String mediaUrl;
  final String thumbnailUrl;
  final String category;

  const SermonMediaItem({
    required this.id,
    required this.tenantId,
    required this.title,
    required this.speaker,
    required this.mediaUrl,
    required this.thumbnailUrl,
    required this.category,
  });

  /// Deserialization factory translating cloud database payloads into runtime structures
  factory SermonMediaItem.fromJson(Map<String, dynamic> json) {
    return SermonMediaItem(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? 'global_shared',
      title: json['title'] as String? ?? 'Untitled Sermon',
      speaker: json['speaker'] as String? ?? 'Guest Speaker',
      mediaUrl: json['mediaUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
    );
  }

  /// Serialization adapter mapping parameters into key-value queries for Supabase storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'title': title,
      'speaker': speaker,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
    };
  }
}