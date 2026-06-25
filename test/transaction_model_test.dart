// test/transaction_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:church_gear/data/models/transaction_model.dart';

void main() {
  group('TransactionRecord Model Tests', () {
    test('Should parse Supabase JSON payload into data model correctly', () {
      final mockJson = {
        'id': 'tx-1001',
        'tenant_id': 'tenant-777',
        'contributor_name': 'Anonymous Guest',
        'amount': 250.50,
        'category': 'tithe',
        'status': 'completed',
        'timestamp': '2026-06-25T10:00:00Z'
      };

      final record = TransactionRecord.fromJson(mockJson);

      expect(record.id, equals('tx-1001'));
      expect(record.amount, equals(250.50));
      expect(record.category, equals(TransactionCategory.tithe));
      expect(record.status, equals(TransactionStatus.completed));
    });
  });
}