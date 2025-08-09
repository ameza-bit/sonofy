import 'package:flutter/material.dart';
import 'package:samva/core/constants/app_constants.dart';

/// Responsive layout utility for consistent responsive design
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    this.web,
    super.key,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? web;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        if (AppBreakpoints.isMobile(screenWidth)) {
          return mobile;
        } else if (AppBreakpoints.isTablet(screenWidth)) {
          return tablet ?? mobile;
        } else {
          return web ?? tablet ?? mobile;
        }
      },
    );
  }
}

/// Responsive value utility
class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.web,
  });

  final T mobile;
  final T? tablet;
  final T? web;

  T getValue(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (AppBreakpoints.isMobile(screenWidth)) {
      return mobile;
    } else if (AppBreakpoints.isTablet(screenWidth)) {
      return tablet ?? mobile;
    } else {
      return web ?? tablet ?? mobile;
    }
  }
}

/// Responsive grid utility
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    required this.children,
    this.spacing = AppSpacing.md,
    this.runSpacing,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.maxItemWidth = AppLayout.cardMaxWidth,
    this.minItemWidth = AppLayout.cardMinWidth,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final double? runSpacing;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;
  final double maxItemWidth;
  final double minItemWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal item width
        final availableWidth = constraints.maxWidth;
        final itemsPerRow = (availableWidth / maxItemWidth).floor().clamp(1, 4);
        final itemWidth = (availableWidth - (spacing * (itemsPerRow - 1))) / itemsPerRow;
        
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing ?? spacing,
          alignment: alignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children.map((child) {
            return SizedBox(
              width: itemWidth.clamp(minItemWidth, maxItemWidth),
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

/// Responsive columns utility
class ResponsiveColumns extends StatelessWidget {
  const ResponsiveColumns({
    required this.children,
    this.spacing = AppSpacing.md,
    this.maxColumns = AppLayout.maxGridColumns,
    this.minColumns = AppLayout.minGridColumns,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final int maxColumns;
  final int minColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        int columns;
        if (AppBreakpoints.isMobile(screenWidth)) {
          columns = minColumns;
        } else if (AppBreakpoints.isTablet(screenWidth)) {
          columns = (maxColumns * 0.75).round();
        } else {
          columns = maxColumns;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: AppLayout.gridChildAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// Responsive padding utility
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    required this.child,
    this.mobile = const EdgeInsets.all(AppSpacing.md),
    this.tablet,
    this.web,
    super.key,
  });

  final Widget child;
  final EdgeInsets mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? web;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        EdgeInsets padding;
        if (AppBreakpoints.isMobile(screenWidth)) {
          padding = mobile;
        } else if (AppBreakpoints.isTablet(screenWidth)) {
          padding = tablet ?? const EdgeInsets.all(AppSpacing.lg);
        } else {
          padding = web ?? const EdgeInsets.all(AppSpacing.xl);
        }
        
        return Padding(
          padding: padding,
          child: child,
        );
      },
    );
  }
}

/// Responsive text utility
class ResponsiveText extends StatelessWidget {
  const ResponsiveText(
    this.text, {
    super.key,
    this.mobileStyle,
    this.tabletStyle,
    this.webStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? mobileStyle;
  final TextStyle? tabletStyle;
  final TextStyle? webStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        TextStyle? style;
        if (AppBreakpoints.isMobile(screenWidth)) {
          style = mobileStyle;
        } else if (AppBreakpoints.isTablet(screenWidth)) {
          style = tabletStyle ?? mobileStyle;
        } else {
          style = webStyle ?? tabletStyle ?? mobileStyle;
        }
        
        return Text(
          text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

/// Responsive container utility
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
    this.alignment = Alignment.center,
    super.key,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        double containerMaxWidth;
        if (AppBreakpoints.isMobile(screenWidth)) {
          containerMaxWidth = screenWidth;
        } else if (AppBreakpoints.isTablet(screenWidth)) {
          containerMaxWidth = maxWidth ?? AppBreakpoints.tabletFormMaxWidth;
        } else {
          containerMaxWidth = maxWidth ?? AppBreakpoints.webComponentMaxWidth;
        }
        
        return Container(
          width: double.infinity,
          padding: padding,
          margin: margin,
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: containerMaxWidth,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Extension methods for responsive design
extension ResponsiveExtensions on BuildContext {
  /// Get current screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get current screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if current screen is mobile
  bool get isMobile => AppBreakpoints.isMobile(screenWidth);

  /// Check if current screen is tablet
  bool get isTablet => AppBreakpoints.isTablet(screenWidth);

  /// Check if current screen is web
  bool get isWeb => AppBreakpoints.isWeb(screenWidth);

  /// Get responsive value based on screen size
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? web,
  }) {
    if (isMobile) {
      return mobile;
    } else if (isTablet) {
      return tablet ?? mobile;
    } else {
      return web ?? tablet ?? mobile;
    }
  }
}