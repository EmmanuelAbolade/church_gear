// lib/data/repositories/sermon_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sermon_media_item.dart';

class SermonRepository {
  final SupabaseClient _supabaseClient;

  SermonRepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Stream continuous real-time sermon listings isolated by tenant scope
  Stream<List<SermonMediaItem>> streamSermons({required String tenantId}) {
    return _supabaseClient
        .from('sermons')
        .stream(primaryKey: ['id'])
        .eq('tenantId', tenantId)
        .map((listOfMaps) => listOfMaps
            .map((map) => SermonMediaItem.fromJson(map))
            .toList());
  }
}