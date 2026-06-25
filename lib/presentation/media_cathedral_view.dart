// lib/presentation/media_cathedral_view.dart

import 'package:flutter/material.dart';
import '../data/models/sermon_media_item.dart';

class MediaCathedralView extends StatelessWidget {
  final List<SermonMediaItem> sermons;

  const MediaCathedralView({super.key, required this.sermons});

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Faith', 'Grace', 'Leadership', 'Prayer'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Filter Scroll Row
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(categories[index]),
                  selected: index == 0,
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        
        // Vertical Feed Scroll Frame
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sermons.length,
            itemBuilder: (context, index) {
              final sermon = sermons[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 180,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.play_circle_outline, size: 48, color: Colors.white70),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sermon.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sermon.speaker,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}