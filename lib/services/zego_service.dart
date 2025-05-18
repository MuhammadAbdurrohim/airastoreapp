import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import '../config/zego_config.dart';

class ZegoService {
  static bool _isInitialized = false;

  static Future<void> initSDK() async {
    if (_isInitialized) return;

    await ZegoUIKit.init(
      appID: ZegoConfig.appId,
      appSign: ZegoConfig.appSign,
    );

    _isInitialized = true;
  }

  static void uninitSDK() {
    if (!_isInitialized) return;
    ZegoUIKit.uninit();
    _isInitialized = false;
  }

  static Future<void> startPreview({
    required String userID,
    required String userName,
    required Function(bool) onCameraStateChanged,
    required Function(bool) onMicrophoneStateChanged,
  }) async {
    if (!_isInitialized) {
      throw Exception('ZegoService not initialized');
    }

    await ZegoUIKit.instance.login(userID, userName);

    // Set up event listeners
    ZegoUIKit.instance.getCameraStateNotifier().addListener(() {
      onCameraStateChanged(ZegoUIKit.instance.getCameraStateNotifier().value);
    });

    ZegoUIKit.instance.getMicrophoneStateNotifier().addListener(() {
      onMicrophoneStateChanged(ZegoUIKit.instance.getMicrophoneStateNotifier().value);
    });
  }

  static Future<void> stopPreview() async {
    if (!_isInitialized) return;
    await ZegoUIKit.instance.logout();
  }

  static Future<void> toggleCamera(bool enabled) async {
    if (!_isInitialized) return;
    await ZegoUIKit.instance.turnCameraOn(enabled);
  }

  static Future<void> toggleMicrophone(bool enabled) async {
    if (!_isInitialized) return;
    await ZegoUIKit.instance.turnMicrophoneOn(enabled);
  }

  static Future<void> switchCamera() async {
    if (!_isInitialized) return;
    await ZegoUIKit.instance.switchFrontFacingCamera();
  }

  static Future<void> setBeautyEffect(bool enabled) async {
    if (!_isInitialized) return;
    await ZegoUIKit.instance.enableBeauty(enabled);
  }

  static Future<void> setVideoConfig({
    int? bitrate,
    int? fps,
    ZegoVideoConfigPreset? preset,
  }) async {
    if (!_isInitialized) return;

    final config = ZegoVideoConfig.preset(
      preset ?? ZegoVideoConfigPreset.preset720P,
    );

    if (bitrate != null) {
      config.bitrate = bitrate;
    }
    if (fps != null) {
      config.fps = fps;
    }

    await ZegoUIKit.instance.setVideoConfig(config);
  }

  static Future<void> setAudioConfig({
    int? bitrate,
    ZegoAudioConfigPreset? preset,
  }) async {
    if (!_isInitialized) return;

    final config = ZegoAudioConfig.preset(
      preset ?? ZegoAudioConfigPreset.standardQuality,
    );

    if (bitrate != null) {
      config.bitrate = bitrate;
    }

    await ZegoUIKit.instance.setAudioConfig(config);
  }

  static Future<void> setCustomVideoProcessing({
    required bool enabled,
    int maxWidth = 1280,
    int maxHeight = 720,
  }) async {
    if (!_isInitialized) return;

    await ZegoUIKit.instance.enableCustomVideoProcessing(
      enabled,
      ZegoVideoProcessConfig(
        resolution: ZegoResolution(maxWidth, maxHeight),
      ),
    );
  }

  static Future<void> setNetworkMode(ZegoStreamQualityLevel level) async {
    if (!_isInitialized) return;
    await ZegoUIKit.instance.setStreamQualityLevel(level);
  }

  static Future<void> muteAllPlayStreamAudio(bool mute) async {
    if (!_isInitialized) return;
    await ZegoUIKit.instance.muteAllPlayStreamAudio(mute);
  }

  static Future<void> startPublishingStream(String streamID) async {
    if (!_isInitialized) return;
    await ZegoUIKit.instance.startPublishingStream(streamID);
  }

  static Future<void> stopPublishingStream() async {
    if (!_isInitialized) return;
    await ZegoUIKit.instance.stopPublishingStream();
  }

  static Future<void> startPlayingStream(String streamID) async {
    if (!_isInitialized) return;
    await ZegoUIKit.instance.startPlayingStream(streamID);
  }

  static Future<void> stopPlayingStream(String streamID) async {
    if (!_isInitialized) return;
    await ZegoUIKit.instance.stopPlayingStream(streamID);
  }
}
