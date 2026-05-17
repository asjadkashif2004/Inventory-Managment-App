abstract final class AppBreakpoints {
  static const mobile = 600.0;
  static const tablet = 900.0;
  static const desktop = 1200.0;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
}
