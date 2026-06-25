// test/sermon_media_item_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:church_gear/data/models/sermon_media_item.dart';

void main() {
  group('SermonMediaItem Model Unit Tests', () {
    final Map<String, dynamic> validJson = {
      'id': 'sermon_001',
      'tenantId': 'grace_chapel',
      'title': 'Walking in True Grace',
      'speaker': 'Pastor John Doe',
      'mediaUrl': 'https://cdn.churchgear.com/grace_chapel/sermons/grace.mp4',
      'thumbnailUrl': 'https://cdn.churchgear.com/grace_chapel/thumbnails/grace.jpg',
      'category': 'Faith',
    };

    test('Should correctly instantiate from a valid JSON map architecture', () {
      final sermon = SermonMediaItem.fromJson(validJson);

      expect(sermon.id, 'sermon_001');
      expect(sermon.tenantId, 'grace_chapel');
      expect(sermon.title, 'Walking in True Grace');
      expect(sermon.speaker, 'Pastor John Doe');
      expect(sermon.mediaUrl, 'https://cdn.churchgear.com/grace_chapel/sermons/grace.mp4');
      expect(sermon.thumbnailUrl, 'https://cdn.churchgear.com/grace_chapel/thumbnails/grace.jpg');
      expect(sermon.category, 'Faith');
    });

    test('Should compile cleanly into a valid output JSON string structure map', () {
      final sermon = SermonMediaItem.fromJson(validJson);
      final outJson = sermon.toJson();

      expect(outJson['id'], 'sermon_001');
      expect(outJson['title'], 'Walking in True Grace');
      expect(outJson['category'], 'Faith');
    });
  });
}