import 'package:flutter/material.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';

class SongCard extends StatelessWidget {
  const SongCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Different world of music',
              style: TextStyle(
                fontSize: context.scaleText(16),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your library settings and preferences.',
              style: TextStyle(fontSize: context.scaleText(12)),
            ),
          ],
        ),
      ),
    );
  }
}
