// lib/data/repositories/admin_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/featured_update_model.dart';

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;

  /// Streams ALL updates for the specific tenant, regardless of status, so admins see everything
  Stream<List<FeaturedUpdateItem>> streamAllTenantUpdates(String tenantId) {
    return _client
        .from('featured_updates')
        .stream(primaryKey: ['id'])
        .eq('tenant_id', tenantId)
        .order('scheduled_for', ascending: false)
        .map((maps) => maps.map((json) => FeaturedUpdateItem.fromJson(json)).toList());
  }

  /// Pushes a freshly crafted update directly into the cloud database
  Future<void> createFeaturedUpdate(FeaturedUpdateItem item) async {
    await _client.from('featured_updates').insert(item.toJson());
  }

  /// Updates the lifecycle status of a specific home portal update card
  Future<void> updateContentStatus(String id, String newStatus) async {
    await _client
        .from('featured_updates')
        .update({'status': newStatus})
        .eq('id', id);
  }

  /// Permanently removes an old update card from the layout index
  Future<void> deleteFeaturedUpdate(String id) async {
    await _client.from('featured_updates').delete().eq('id', id);
  }
}