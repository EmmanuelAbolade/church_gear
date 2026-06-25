// test/church_member_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:church_gear/data/models/church_member.dart';

void main() {
  group('ChurchMember Model Unit Tests', () {
    final Map<String, dynamic> validJson = {
      'id': 'mem_091',
      'tenantId': 'grace_chapel',
      'name': 'Alex Bruce',
      'role': 'Small Group Leader',
      'imageUrl': '',
      'groupName': 'Young Adults Fellowship',
    };

    test('Should correctly instantiate from valid JSON map structures', () {
      final member = ChurchMember.fromJson(validJson);

      expect(member.id, 'mem_091');
      expect(member.tenantId, 'grace_chapel');
      expect(member.name, 'Alex Bruce');
      expect(member.role, 'Small Group Leader');
      expect(member.groupName, 'Young Adults Fellowship');
    });

    test('Should compile cleanly back into a standard output JSON map format', () {
      final member = ChurchMember.fromJson(validJson);
      final outJson = member.toJson();

      expect(outJson['id'], 'mem_091');
      expect(outJson['name'], 'Alex Bruce');
    });
  });
}