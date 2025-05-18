import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/live_streaming_provider.dart';
import '../models/live_stream.dart';

class LiveStreamListScreen extends StatefulWidget {
  const LiveStreamListScreen({Key? key}) : super(key: key);

  @override
  _LiveStreamListScreenState createState() => _LiveStreamListScreenState();
}

class _LiveStreamListScreenState extends State<LiveStreamListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveStreamingProvider>().loadActiveStreams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Streams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/live-stream',
                arguments: {
                  'streamId': DateTime.now().millisecondsSinceEpoch.toString(),
                  'isHost': true,
                  'userId': 'user_123', // Replace with actual user ID
                  'userName': 'John Doe', // Replace with actual user name
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<LiveStreamingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadActiveStreams();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.activeStreams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No active streams',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadActiveStreams();
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadActiveStreams(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.activeStreams.length,
              itemBuilder: (context, index) {
                final stream = provider.activeStreams[index];
                return _buildStreamCard(stream);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreamCard(LiveStream stream) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/live-stream',
            arguments: {
              'streamId': stream.id,
              'isHost': false,
              'userId': 'user_123', // Replace with actual user ID
              'userName': 'John Doe', // Replace with actual user name
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: stream.thumbnailPath.isNotEmpty
                  ? Image.network(
                      stream.thumbnailPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.live_tv,
                            size: 48,
                            color: Colors.white,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.live_tv,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stream Title and Live Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          stream.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (stream.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Host Info and Viewer Count
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: stream.hostAvatar.isNotEmpty
                            ? NetworkImage(stream.hostAvatar)
                            : null,
                        child: stream.hostAvatar.isEmpty
                            ? Text(
                                stream.hostName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stream.hostName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${stream.formattedViewerCount} viewers',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        stream.timeAgo,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  
                  // Products Count
                  if (stream.productCount > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${stream.productCount} products',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
