import 'package:flutter/material.dart';
import 'package:samva/core/constants/app_constants.dart';
import 'package:samva/core/extensions/color_extensions.dart';
import 'package:samva/core/extensions/theme_extensions.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;

  const SectionCard({
    required this.title,
    required this.children,
    this.padding,
    this.showDivider = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Widget container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.card),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withAlpha(25)
                    : Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children:
            children
                .asMap()
                .map((index, child) {
                  final isLast = index == children.length - 1;
                  return MapEntry(
                    index,
                    Column(
                      children: [
                        child,
                        if (!isLast && showDivider)
                          Divider(
                            height: 1,
                            thickness: 1,
                            indent: 70,
                            endIndent: 15,
                            color:
                                isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                          ),
                      ],
                    ),
                  );
                })
                .values
                .toList(),
      ),
    );

    if (title.isEmpty) {
      return container;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: context.scaleText(16.0),
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
        ),
        container,
      ],
    );
  }
}
