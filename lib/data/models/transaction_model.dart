// lib/data/models/transaction_model.dart

enum TransactionCategory { tithe, offering, buildingFund, charity, project }
enum TransactionStatus { completed, pending, failed }

class TransactionRecord {
  final String id;
  final String tenantId;
  final String contributorName;
  final double amount;
  final TransactionCategory category;
  final TransactionStatus status;
  final DateTime timestamp;

  TransactionRecord({
    required this.id,
    required this.tenantId,
    required this.contributorName,
    required this.amount,
    required this.category,
    required this.status,
    required this.timestamp,
  });

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      contributorName: json['contributor_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TransactionCategory.offering,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'contributor_name': contributorName,
      'amount': amount,
      'category': category.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}