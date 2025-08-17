import 'package:flutter/material.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, this.subtitle = '', super.key});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: context.scaleText(24),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: context.scaleText(12),
                color: context.musicLightGrey,
              ),
            ),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
