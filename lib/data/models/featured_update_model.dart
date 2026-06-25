// lib/data/models/featured_update_model.dart

class FeaturedUpdateItem {
  final String id;
  final String tenantId;
  final String badgeText;
  final String titleText;
  final String subtitleText;
  final Map<String, int> reactions;
  final DateTime scheduledFor;
  final String status;

  FeaturedUpdateItem({
    required this.id,
    required this.tenantId,
    required this.badgeText,
    required this.titleText,
    required this.subtitleText,
    required this.reactions,
    required this.scheduledFor,
    required this.status,
  });

  factory FeaturedUpdateItem.fromJson(Map<String, dynamic> json) {
    // Gracefully cast nested dynamic JSONB maps safely into strict type maps
    final rawReactions = json['reactions'] as Map<String, dynamic>? ?? {};
    final castedReactions = rawReactions.map((key, value) => MapEntry(key, value as int));

    return FeaturedUpdateItem(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      badgeText: json['badge_text'] as String,
      titleText: json['title_text'] as String,
      subtitleText: json['subtitle_text'] as String,
      reactions: castedReactions,
      scheduledFor: DateTime.parse(json['scheduled_for'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'badge_text': badgeText,
      'title_text': titleText,
      'subtitle_text': subtitleText,
      'reactions': reactions,
      'scheduled_for': scheduledFor.toIso8601String(),
      'status': status,
    };
  }
}