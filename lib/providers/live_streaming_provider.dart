import 'package:flutter/foundation.dart';
import '../models/live_stream.dart';
import '../models/live_comment.dart';
import '../services/api_service.dart';
import '../services/zego_service.dart';

class LiveStreamingProvider extends ChangeNotifier {
  List<LiveStream> _activeStreams = [];
  List<LiveComment> _comments = [];
  bool _isLoading = false;
  String? _error;
  bool _isStreaming = false;

  // Getters
  List<LiveStream> get activeStreams => _activeStreams;
  List<LiveComment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isStreaming => _isStreaming;

  // Initialize the provider
  Future<void> init() async {
    try {
      await ZegoService.initSDK();
    } catch (e) {
      _error = 'Failed to initialize streaming service: $e';
      notifyListeners();
    }
  }

  // Dispose resources
  void dispose() {
    ZegoService.uninitSDK();
    super.dispose();
  }

  // Load active streams
  Future<void> loadActiveStreams() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final streams = await ApiService.getActiveStreams();
      _activeStreams = streams.map((json) => LiveStream.fromJson(json)).toList();
    } catch (e) {
      _error = 'Failed to load streams: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load comments for a stream
  Future<void> loadComments(String streamId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final comments = await ApiService.getLiveComments(streamId);
      _comments = comments.map((json) => LiveComment.fromJson(json)).toList();
    } catch (e) {
      _error = 'Failed to load comments: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send a comment
  Future<void> sendComment(String streamId, String content) async {
    try {
      _error = null;
      final comment = await ApiService.sendLiveComment(streamId, content);
      _comments.insert(0, LiveComment.fromJson(comment));
      notifyListeners();
    } catch (e) {
      _error = 'Failed to send comment: $e';
      notifyListeners();
    }
  }

  // Join a stream
  Future<void> joinStream(String streamId) async {
    try {
      _error = null;
      await ApiService.joinStream(streamId);
      await loadComments(streamId);
    } catch (e) {
      _error = 'Failed to join stream: $e';
      notifyListeners();
    }
  }

  // Leave a stream
  Future<void> leaveStream(String streamId) async {
    try {
      _error = null;
      await ApiService.leaveStream(streamId);
      _comments.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to leave stream: $e';
      notifyListeners();
    }
  }

  // Start streaming
  Future<void> startStreaming({
    required String userId,
    required String userName,
    required Function(bool) onCameraStateChanged,
    required Function(bool) onMicrophoneStateChanged,
  }) async {
    try {
      _error = null;
      await ZegoService.startPreview(
        userID: userId,
        userName: userName,
        onCameraStateChanged: onCameraStateChanged,
        onMicrophoneStateChanged: onMicrophoneStateChanged,
      );
      _isStreaming = true;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to start streaming: $e';
      notifyListeners();
    }
  }

  // Stop streaming
  Future<void> stopStreaming() async {
    try {
      _error = null;
      await ZegoService.stopPreview();
      _isStreaming = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to stop streaming: $e';
      notifyListeners();
    }
  }

  // Toggle camera
  Future<void> toggleCamera(bool enabled) async {
    try {
      _error = null;
      await ZegoService.toggleCamera(enabled);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle camera: $e';
      notifyListeners();
    }
  }

  // Toggle microphone
  Future<void> toggleMicrophone(bool enabled) async {
    try {
      _error = null;
      await ZegoService.toggleMicrophone(enabled);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle microphone: $e';
      notifyListeners();
    }
  }

  // Switch camera
  Future<void> switchCamera() async {
    try {
      _error = null;
      await ZegoService.switchCamera();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to switch camera: $e';
      notifyListeners();
    }
  }

  // Toggle beauty effect
  Future<void> toggleBeautyEffect(bool enabled) async {
    try {
      _error = null;
      await ZegoService.setBeautyEffect(enabled);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle beauty effect: $e';
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
