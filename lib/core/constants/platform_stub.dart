// Stub file used when dart:io is not available (i.e., web platform)
// This provides a fake Platform class so the code compiles on web.

class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isLinux => false;
  static bool get isMacOS => false;
  static bool get isWindows => false;
}
