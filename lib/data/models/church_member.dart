// lib/data/models/church_member.dart

class ChurchMember {
  final String id;
  final String tenantId;
  final String name;
  final String role;
  final String imageUrl;
  final String groupName;

  const ChurchMember({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.groupName,
  });

  factory ChurchMember.fromJson(Map<String, dynamic> json) {
    return ChurchMember(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? 'global_shared',
      name: json['name'] as String? ?? 'Unknown Member',
      role: json['role'] as String? ?? 'Member',
      imageUrl: json['imageUrl'] as String? ?? '',
      groupName: json['groupName'] as String? ?? 'General Congregation',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'name': name,
      'role': role,
      'imageUrl': imageUrl,
      'groupName': groupName,
    };
  }
}