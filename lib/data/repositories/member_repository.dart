// lib/data/repositories/member_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/church_member.dart';

class MemberRepository {
  final SupabaseClient _supabaseClient;

  MemberRepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Stream continuous real-time directory listings isolated by tenant scope
  Stream<List<ChurchMember>> streamMembers({required String tenantId}) {
    return _supabaseClient
        .from('members')
        .stream(primaryKey: ['id'])
        .eq('tenantId', tenantId)
        .map((listOfMaps) => listOfMaps
            .map((map) => ChurchMember.fromJson(map))
            .toList());
  }
}