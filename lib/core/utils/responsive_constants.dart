import 'package:flutter/material.dart';

/// Responsive constants and configurations
class ResponsiveConstants {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Padding & Margins
  static const double paddingXSmall = 8.0;
  static const double paddingSmall = 12.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeBody = 14.0;
  static const double fontSizeSubtitle = 16.0;
  static const double fontSizeHeading = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeXLarge = 32.0;

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 52.0;

  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;

  // Shadows
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(color: Color(0x29000000), blurRadius: 8, offset: Offset(0, 3)),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 8)),
  ];

  // Max Width Constraints
  static const double maxWidthMobile = double.infinity;
  static const double maxWidthTablet = 720;
  static const double maxWidthDesktop = 1200;

  // Grid Spacing
  static const double gridSpacingMobile = 12.0;
  static const double gridSpacingTablet = 16.0;
  static const double gridSpacingDesktop = 20.0;
}

/// Responsive padding provider
class ResponsivePaddingProvider {
  static EdgeInsets getHorizontalPadding(double screenWidth) {
    if (screenWidth < 600) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (screenWidth < 900) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  static EdgeInsets getVerticalPadding(double screenWidth) {
    if (screenWidth < 600) {
      return const EdgeInsets.symmetric(vertical: 12);
    } else if (screenWidth < 900) {
      return const EdgeInsets.symmetric(vertical: 16);
    } else {
      return const EdgeInsets.symmetric(vertical: 20);
    }
  }

  static EdgeInsets getSymmetricPadding(double screenWidth) {
    if (screenWidth < 600) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (screenWidth < 900) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
  }
}

/// Responsive dimension provider
class ResponsiveDimensionProvider {
  static double getResponsiveFontSize(
    double screenWidth, {
    required double baseSize,
    double? minSize,
    double? maxSize,
  }) {
    double size = baseSize;

    if (screenWidth >= 900) {
      size = baseSize * 1.1;
    } else if (screenWidth >= 600) {
      size = baseSize * 1.05;
    }

    if (minSize != null && size < minSize) {
      size = minSize;
    }
    if (maxSize != null && size > maxSize) {
      size = maxSize;
    }

    return size;
  }

  static double getResponsiveSpacing(double screenWidth) {
    if (screenWidth < 600) {
      return 12.0;
    } else if (screenWidth < 900) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  static double getResponsiveIconSize(double screenWidth) {
    if (screenWidth < 600) {
      return 24.0;
    } else if (screenWidth < 900) {
      return 28.0;
    } else {
      return 32.0;
    }
  }
}
