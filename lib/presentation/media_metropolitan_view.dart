// lib/presentation/media_metropolitan_view.dart

import 'package:flutter/material.dart';
import '../data/models/sermon_media_item.dart';

class MediaMetropolitanView extends StatelessWidget {
  final List<SermonMediaItem> sermons;

  const MediaMetropolitanView({super.key, required this.sermons});

  @override
  Widget build(BuildContext context) {
    final featuredSermon = sermons.isNotEmpty ? sermons.first : null;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Premium Immersive Hero Banner Display
        if (featuredSermon != null)
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black87, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LATEST RELEASE',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        featuredSermon.title,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        featuredSermon.speaker,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Center(
                  child: Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
                ),
              ],
            ),
          ),
        
        // Horizontal Media Carousel Row Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Trending Sermon Series',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: sermons.length,
            itemBuilder: (context, index) {
              final sermon = sermons[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.video_library, color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sermon.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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