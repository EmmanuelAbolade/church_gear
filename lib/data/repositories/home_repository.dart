// lib/data/repositories/home_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/featured_update_model.dart';

class HomeRepository {
  final SupabaseClient _client;

  HomeRepository({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;

  /// Listens live to your admin scheduled updates stream filtered by tenant workspace context
  Stream<List<FeaturedUpdateItem>> streamFeaturedUpdates(String tenantId) {
    // 💡 FIX: Pass the primary tenant filter into the stream configuration directly,
    // then filter scheduling parameters cleanly inside the local Dart collection map.
    return _client
        .from('featured_updates')
        .stream(primaryKey: ['id'])
        .eq('tenant_id', tenantId)
        .order('scheduled_for', ascending: false)
        .map((maps) => maps
            .map((json) => FeaturedUpdateItem.fromJson(json))
            .where((item) => item.status == 'published') // Enforces your admin visibility scheduling rules!
            .toList());
  }

  /// Pushes an incremental emoji addition straight to the Supabase cloud table layer
  Future<void> incrementEmojiReaction(String cardId, String emoji, Map<String, int> currentReactions) async {
    final updatedReactions = Map<String, int>.from(currentReactions);
    updatedReactions[emoji] = (updatedReactions[emoji] ?? 0) + 1;

    await _client
        .from('featured_updates')
        .update({'reactions': updatedReactions})
        .eq('id', cardId);
  }
}