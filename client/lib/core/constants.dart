import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  /// Automatically picks the right URL based on the platform:
  ///   - Web / desktop  → localhost:3000
  ///   - Android emulator → 10.0.2.2:3000  (host machine alias)
  ///   - Physical device  → set YOUR_LAN_IP below
  static const String _lanIp = '10.0.2.2'; // ← change to your LAN IP for physical device

  static String get serverUrl {
    if (kIsWeb) return 'http://localhost:3000';
    return 'http://$_lanIp:3000';
  }
}
