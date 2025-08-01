import 'package:flutter/material.dart';

/// Utility class for responsive layouts and overflow prevention
class ResponsiveLayout {
  /// Get responsive font size based on screen width
  static double getFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return baseFontSize * 0.9; // Smaller screens
    } else if (screenWidth > 600) {
      return baseFontSize * 1.1; // Larger screens
    }
    return baseFontSize; // Default
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return const EdgeInsets.all(12);
    } else if (screenWidth > 600) {
      return const EdgeInsets.all(20);
    }
    return const EdgeInsets.all(16);
  }

  /// Get responsive spacing based on screen size
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return baseSpacing * 0.8;
    } else if (screenWidth > 600) {
      return baseSpacing * 1.2;
    }
    return baseSpacing;
  }

  /// Get number of columns for grid based on screen width
  static int getGridColumns(BuildContext context, {int maxColumns = 4}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return 2;
    } else if (screenWidth < 600) {
      return 3;
    } else if (screenWidth < 900) {
      return 4;
    }
    return maxColumns;
  }

  /// Check if screen is small
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Check if screen is large
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  /// Get responsive card height
  static double getCardHeight(BuildContext context, double baseHeight) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 600) {
      return baseHeight * 0.8;
    } else if (screenHeight > 800) {
      return baseHeight * 1.2;
    }
    return baseHeight;
  }
}

/// Widget that prevents text overflow with responsive sizing
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool responsive;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.responsive = true,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle? finalStyle = style;
    
    if (responsive && style != null && style!.fontSize != null) {
      finalStyle = style!.copyWith(
        fontSize: ResponsiveLayout.getFontSize(context, style!.fontSize!),
      );
    }

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.fade,
      softWrap: true,
    );
  }
}

/// Flexible container that adapts to content
class FlexibleContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final double? minHeight;
  final double? maxHeight;

  const FlexibleContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.boxShadow,
    this.minHeight,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      padding: padding ?? ResponsiveLayout.getResponsivePadding(context),
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

/// Responsive grid that adapts column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? maxColumns;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.maxColumns,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveLayout.getGridColumns(
      context,
      maxColumns: maxColumns ?? 4,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive row that wraps to column on small screens
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isSmallScreen(context)) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children
            .expand((child) => [child, SizedBox(height: spacing)])
            .take(children.length * 2 - 1)
            .toList(),
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children
          .expand((child) => [child, SizedBox(width: spacing)])
          .take(children.length * 2 - 1)
          .toList(),
    );
  }
}

/// Safe area wrapper that prevents overflow
class SafeScrollView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;

  const SafeScrollView({
    super.key,
    required this.children,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: physics ?? const BouncingScrollPhysics(),
      padding: padding ?? ResponsiveLayout.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
