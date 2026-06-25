// lib/data/repositories/operations_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:church_gear/data/models/transaction_model.dart';

class OperationsRepository {
  final SupabaseClient _client;

  OperationsRepository({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;

  /// Returns a live stream of transaction logs filtered securely by tenantId
  Stream<List<TransactionRecord>> streamTransactions(String tenantId) {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('tenant_id', tenantId)
        .order('timestamp', ascending: false)
        .map((maps) => maps.map((json) => TransactionRecord.fromJson(json)).toList());
  }
}