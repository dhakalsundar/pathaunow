import 'package:flutter/material.dart';

class ResponsiveHelper {
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 900) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
  }

  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobileSize,
    double? tabletSize,
    double? desktopSize,
  }) {
    final deviceType = getDeviceType(context);

    return switch (deviceType) {
      DeviceType.mobile => mobileSize,
      DeviceType.tablet => tabletSize ?? mobileSize + 2,
      DeviceType.desktop => desktopSize ?? mobileSize + 4,
    };
  }

  static double getResponsiveSpacing(BuildContext context) {
    final width = screenWidth(context);

    if (width < 600) {
      return 16.0;
    } else if (width < 900) {
      return 20.0;
    } else {
      return 24.0;
    }
  }

  static int getGridColumns(BuildContext context) {
    final deviceType = getDeviceType(context);

    return switch (deviceType) {
      DeviceType.mobile => 2,
      DeviceType.tablet => 3,
      DeviceType.desktop => 4,
    };
  }

  static double getMaxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);

    return switch (deviceType) {
      DeviceType.mobile => double.infinity,
      DeviceType.tablet => 720,
      DeviceType.desktop => 1200,
    };
  }

  static double getBottomNavHeight(BuildContext context) {
    return isMobile(context) ? 70.0 : 0.0;
  }

  static double getAppBarHeight(BuildContext context) {
    return kToolbarHeight;
  }

  static double getResponsiveIconSize(BuildContext context) {
    final deviceType = getDeviceType(context);

    return switch (deviceType) {
      DeviceType.mobile => 24.0,
      DeviceType.tablet => 28.0,
      DeviceType.desktop => 32.0,
    };
  }
}

enum DeviceType { mobile, tablet, desktop }

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);

    return switch (deviceType) {
      DeviceType.mobile => mobile,
      DeviceType.tablet => tablet ?? mobile,
      DeviceType.desktop => desktop ?? tablet ?? mobile,
    };
  }
}

class ResponsiveLayoutBuilder extends StatelessWidget {
  final WidgetBuilder mobileBuilder;
  final WidgetBuilder? tabletBuilder;
  final WidgetBuilder? desktopBuilder;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);

    return switch (deviceType) {
      DeviceType.mobile => mobileBuilder(context),
      DeviceType.tablet => (tabletBuilder ?? mobileBuilder)(context),
      DeviceType.desktop => (desktopBuilder ?? tabletBuilder ?? mobileBuilder)(
        context,
      ),
    };
  }
}
