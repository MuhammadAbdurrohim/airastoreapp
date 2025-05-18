import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import '../providers/live_streaming_provider.dart';
import '../models/live_comment.dart';
import '../config/zego_config.dart';

class LiveStreamingScreen extends StatefulWidget {
  final String streamId;
  final bool isHost;
  final String userId;
  final String userName;

  const LiveStreamingScreen({
    Key? key,
    required this.streamId,
    required this.isHost,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  _LiveStreamingScreenState createState() => _LiveStreamingScreenState();
}

class _LiveStreamingScreenState extends State<LiveStreamingScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isCameraOn = true;
  bool _isMicrophoneOn = true;
  bool _isBeautyEnabled = false;
  bool _isShowingProducts = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LiveStreamingProvider>();
      if (widget.isHost) {
        provider.startStreaming(
          userId: widget.userId,
          userName: widget.userName,
          onCameraStateChanged: (enabled) => setState(() => _isCameraOn = enabled),
          onMicrophoneStateChanged: (enabled) => setState(() => _isMicrophoneOn = enabled),
        );
      } else {
        provider.joinStream(widget.streamId);
      }
      provider.loadComments(widget.streamId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleExit();
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Live Streaming View
            ZegoUIKitPrebuiltLiveStreaming(
              appID: ZegoConfig.appId,
              appSign: ZegoConfig.appSign,
              userID: widget.userId,
              userName: widget.userName,
              liveID: widget.streamId,
              config: widget.isHost
                  ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
                  : ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
            ),

            // Comments Section
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer<LiveStreamingProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      reverse: true,
                      itemCount: provider.comments.length,
                      itemBuilder: (context, index) {
                        final comment = provider.comments[index];
                        return _buildCommentBubble(comment);
                      },
                    );
                  },
                ),
              ),
            ),

            // Comment Input
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                color: Colors.black.withOpacity(0.5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendComment,
                    ),
                  ],
                ),
              ),
            ),

            // Host Controls
            if (widget.isHost)
              Positioned(
                top: 40,
                right: 16,
                child: Column(
                  children: [
                    _buildControlButton(
                      icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                      onPressed: () => _toggleCamera(!_isCameraOn),
                    ),
                    const SizedBox(height: 16),
                    _buildControlButton(
                      icon: _isMicrophoneOn ? Icons.mic : Icons.mic_off,
                      onPressed: () => _toggleMicrophone(!_isMicrophoneOn),
                    ),
                    const SizedBox(height: 16),
                    _buildControlButton(
                      icon: Icons.switch_camera,
                      onPressed: _switchCamera,
                    ),
                    const SizedBox(height: 16),
                    _buildControlButton(
                      icon: Icons.face_retouching_natural,
                      color: _isBeautyEnabled ? Colors.pink : Colors.white,
                      onPressed: () => _toggleBeautyEffect(!_isBeautyEnabled),
                    ),
                    const SizedBox(height: 16),
                    _buildControlButton(
                      icon: Icons.shopping_bag,
                      color: _isShowingProducts ? Colors.green : Colors.white,
                      onPressed: _toggleProducts,
                    ),
                  ],
                ),
              ),

            // Exit Button
            Positioned(
              top: 40,
              left: 16,
              child: _buildControlButton(
                icon: Icons.close,
                onPressed: _handleExit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCommentBubble(LiveComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: comment.userAvatar.isNotEmpty
                ? NetworkImage(comment.userAvatar)
                : null,
            child: comment.userAvatar.isEmpty
                ? Text(
                    comment.userName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendComment() {
    if (_commentController.text.trim().isEmpty) return;

    context.read<LiveStreamingProvider>().sendComment(
          widget.streamId,
          _commentController.text.trim(),
        );
    _commentController.clear();
  }

  void _toggleCamera(bool enabled) {
    context.read<LiveStreamingProvider>().toggleCamera(enabled);
  }

  void _toggleMicrophone(bool enabled) {
    context.read<LiveStreamingProvider>().toggleMicrophone(enabled);
  }

  void _switchCamera() {
    context.read<LiveStreamingProvider>().switchCamera();
  }

  void _toggleBeautyEffect(bool enabled) {
    setState(() => _isBeautyEnabled = enabled);
    context.read<LiveStreamingProvider>().toggleBeautyEffect(enabled);
  }

  void _toggleProducts() {
    setState(() => _isShowingProducts = !_isShowingProducts);
    // TODO: Implement products panel
  }

  Future<void> _handleExit() async {
    final provider = context.read<LiveStreamingProvider>();
    
    if (widget.isHost) {
      await provider.stopStreaming();
    } else {
      await provider.leaveStream(widget.streamId);
    }
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
