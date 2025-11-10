import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../l10n/app_localizations.dart';

class MediaPlayerDialog extends StatefulWidget {
  final String mediaUrl;
  final String title;
  final MediaType? mediaType;

  const MediaPlayerDialog({
    Key? key,
    required this.mediaUrl,
    required this.title,
    this.mediaType,
  }) : super(key: key);

  @override
  State<MediaPlayerDialog> createState() => _MediaPlayerDialogState();

  // Static method to show the dialog
  static Future<void> show({
    required BuildContext context,
    required String mediaUrl,
    required String title,
    MediaType? mediaType,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => MediaPlayerDialog(
        mediaUrl: mediaUrl,
        title: title,
        mediaType: mediaType,
      ),
    );
  }
}

enum MediaType { image, video }

class _MediaPlayerDialogState extends State<MediaPlayerDialog> {
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  MediaType? _detectedMediaType;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  Future<void> _initializeMedia() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Determine media type if not provided
      _detectedMediaType =
          widget.mediaType ?? _detectMediaType(widget.mediaUrl);

      if (_detectedMediaType == MediaType.video) {
        await _initializeVideoPlayer();
      } else {
        // For images, we'll handle loading state in CachedNetworkImage
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = ' ${e.toString()}';
      });
    }
  }

  MediaType _detectMediaType(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return MediaType.image;

    final extension = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last.split('.').last.toLowerCase()
        : '';

    const videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v'];
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'];

    if (videoExtensions.contains(extension)) {
      return MediaType.video;
    } else if (imageExtensions.contains(extension)) {
      return MediaType.image;
    }

    // Default to image if can't determine
    return MediaType.image;
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.mediaUrl),
      );

      await _videoController!.initialize();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Auto-play the video
        _videoController!.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = '  ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Media Content
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: _buildMediaContent(),
              ),
            ),
            // Controls (for video)
            if (_detectedMediaType == MediaType.video &&
                _videoController != null &&
                _videoController!.value.isInitialized)
              _buildVideoControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 12),
            Text(
              localizations.error_loading_media,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeMedia,
              child: Text(localizations.retry),
            ),
          ],
        ),
      );
    }

    if (_detectedMediaType == MediaType.video) {
      return _buildVideoPlayer();
    } else {
      return _buildImageViewer();
    }
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: VideoPlayer(_videoController!),
    );
  }

  Widget _buildImageViewer() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: CachedNetworkImage(
        imageUrl: widget.mediaUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              localizations.failed_to_load_data,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                if (_videoController!.value.isPlaying) {
                  _videoController!.pause();
                } else {
                  _videoController!.play();
                }
              });
            },
            icon: Icon(
              _videoController!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
          ),
          Expanded(
            child: VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Theme.of(context).primaryColor,
                bufferedColor: Colors.grey[300]!,
                backgroundColor: Colors.grey[200]!,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _videoController!.setVolume(
                _videoController!.value.volume == 0 ? 1.0 : 0.0,
              );
              setState(() {});
            },
            icon: Icon(
              _videoController!.value.volume == 0
                  ? Icons.volume_off
                  : Icons.volume_up,
            ),
          ),
        ],
      ),
    );
  }
}
