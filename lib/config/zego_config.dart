class ZegoConfig {
  // Replace these with your actual ZegoCloud credentials
  static const int appId = 123456789;  // Your ZegoCloud App ID
  static const String appSign = 'your_app_sign_here';  // Your ZegoCloud App Sign

  // Video configuration
  static const int defaultBitrate = 1500;  // kbps
  static const int defaultFPS = 30;
  static const int defaultHeight = 720;
  static const int defaultWidth = 1280;

  // Audio configuration
  static const int defaultAudioBitrate = 48;  // kbps

  // Stream quality presets
  static const Map<String, Map<String, dynamic>> qualityPresets = {
    'high': {
      'bitrate': 2000,
      'fps': 30,
      'width': 1280,
      'height': 720,
    },
    'medium': {
      'bitrate': 1000,
      'fps': 24,
      'width': 960,
      'height': 540,
    },
    'low': {
      'bitrate': 600,
      'fps': 15,
      'width': 640,
      'height': 360,
    },
  };

  // CDN configuration (if using CDN)
  static const bool enableCDN = false;
  static const String cdnUrl = 'your_cdn_url_here';

  // Room configuration
  static const int maxUsersInRoom = 100;
  static const int heartbeatInterval = 30;  // seconds

  // Beauty effects configuration
  static const double defaultSmoothness = 0.5;  // 0.0 to 1.0
  static const double defaultWhiteness = 0.3;  // 0.0 to 1.0
  static const double defaultRedness = 0.3;   // 0.0 to 1.0

  // Network configuration
  static const int reconnectTimeout = 10;  // seconds
  static const int reconnectRetryCount = 3;

  // Debug configuration
  static const bool enableDebugLog = true;
  static const bool enableHardwareEncoder = true;
  static const bool enableHardwareDecoder = true;
}
