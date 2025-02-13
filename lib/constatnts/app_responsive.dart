import 'package:flutter/material.dart';

class AppResponsive extends StatelessWidget {
  const AppResponsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 1000;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width < 1100 && MediaQuery.of(context).size.width >= 1000;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return desktop;
    }
  }
}
