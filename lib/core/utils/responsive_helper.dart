import 'package:flutter/material.dart';

/// Responsive design helper for consistent layouts across different screen sizes
class ResponsiveHelper {
  
  /// Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  /// Check if screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  /// Check if screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }
  
  /// Check if screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
  
  /// Get responsive grid cross axis count
  static int getGridCrossAxisCount(BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
  
  /// Get responsive grid child aspect ratio
  static double getGridChildAspectRatio(BuildContext context, {
    double mobile = 1.2,
    double tablet = 1.1,
    double desktop = 1.0,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
  
  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context, {
    EdgeInsets mobile = const EdgeInsets.all(16),
    EdgeInsets tablet = const EdgeInsets.all(20),
    EdgeInsets desktop = const EdgeInsets.all(24),
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
  
  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, {
    double mobile = 14,
    double tablet = 16,
    double desktop = 18,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
  
  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, {
    double mobile = 20,
    double tablet = 24,
    double desktop = 28,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
  
  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, {
    double mobile = 8,
    double tablet = 12,
    double desktop = 16,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
  
  /// Get responsive card elevation
  static double getResponsiveElevation(BuildContext context, {
    double mobile = 2,
    double tablet = 4,
    double desktop = 6,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
  
  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, {
    double mobile = 8,
    double tablet = 12,
    double desktop = 16,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
  
  /// Get responsive bottom navigation height
  static double getBottomNavigationHeight(BuildContext context) {
    if (isDesktop(context)) return 80;
    if (isTablet(context)) return 70;
    return 60;
  }
  
  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isDesktop(context)) return 64;
    if (isTablet(context)) return 60;
    return 56;
  }
  
  /// Get responsive maximum width for content
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 800;
    return double.infinity;
  }
  
  /// Build responsive grid delegate
  static SliverGridDelegate buildResponsiveGridDelegate(
    BuildContext context, {
    int mobileCrossAxisCount = 2,
    int tabletCrossAxisCount = 3,
    int desktopCrossAxisCount = 4,
    double mobileChildAspectRatio = 1.2,
    double tabletChildAspectRatio = 1.1,
    double desktopChildAspectRatio = 1.0,
    double crossAxisSpacing = 12,
    double mainAxisSpacing = 12,
  }) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: getGridCrossAxisCount(
        context,
        mobile: mobileCrossAxisCount,
        tablet: tabletCrossAxisCount,
        desktop: desktopCrossAxisCount,
      ),
      childAspectRatio: getGridChildAspectRatio(
        context,
        mobile: mobileChildAspectRatio,
        tablet: tabletChildAspectRatio,
        desktop: desktopChildAspectRatio,
      ),
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );
  }
  
  /// Build responsive layout with constraints
  static Widget buildResponsiveLayout({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint && desktop != null) {
          return desktop;
        } else if (constraints.maxWidth >= mobileBreakpoint && tablet != null) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
  
  /// Get responsive container constraints
  static BoxConstraints getResponsiveConstraints(BuildContext context) {
    final maxWidth = getMaxContentWidth(context);
    return BoxConstraints(
      maxWidth: maxWidth,
      minWidth: 0,
    );
  }
  
  /// Get responsive text scale factor
  static double getTextScaleFactor(BuildContext context) {
    if (isDesktop(context)) return 1.1;
    if (isTablet(context)) return 1.05;
    return 1.0;
  }
  
  /// Get responsive safe area padding
  static EdgeInsets getResponsiveSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    
    if (isDesktop(context)) {
      return EdgeInsets.only(
        top: padding.top + 16,
        bottom: padding.bottom + 16,
        left: 24,
        right: 24,
      );
    } else if (isTablet(context)) {
      return EdgeInsets.only(
        top: padding.top + 12,
        bottom: padding.bottom + 12,
        left: 20,
        right: 20,
      );
    } else {
      return EdgeInsets.only(
        top: padding.top + 8,
        bottom: padding.bottom + 8,
        left: 16,
        right: 16,
      );
    }
  }
  
  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  /// Get responsive column count for lists
  static int getListColumnCount(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }
}

/// Extension for easy access to responsive helpers
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get isLandscape => ResponsiveHelper.isLandscape(this);
  
  EdgeInsets get responsivePadding => ResponsiveHelper.getResponsivePadding(this);
  double get responsiveSpacing => ResponsiveHelper.getResponsiveSpacing(this);
  double get responsiveBorderRadius => ResponsiveHelper.getResponsiveBorderRadius(this);
  double get maxContentWidth => ResponsiveHelper.getMaxContentWidth(this);
}
