import 'dart:developer' as developer;
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../api/api_service/media_service.dart';
import '../constants/color_constants.dart';
import '../constants/token_manager.dart';
import '../l10n/app_localizations.dart';
import 'dotted_border.dart';
import 'eye_blink.dart';

class MediaUploader extends StatefulWidget {
  final String label;
  final String? initialUrl;
  final Function(String) onMediaUploaded;
  final Function(List<String>)? onMultipleMediaUploaded;
  final IconData icon;
  final Color? color;
  final bool showPreview;
  final bool required;
  final List<String>? allowedExtensions;
  final int? maxFileSizeInMB;
  final String kind;
  final bool showDirectImage;
  final bool useGallery;
  final bool multipleFiles;
  final bool useEyeBlinkDetection;
  final bool allowReupload;
  final bool showDottedBorder;
  final bool allowVideo;
  final bool allowImage;

  const MediaUploader({
    super.key,
    required this.label,
    this.initialUrl,
    required this.onMediaUploaded,
    this.onMultipleMediaUploaded,
    this.icon = Icons.cloud_upload_outlined,
    this.color,
    this.showPreview = true,
    this.required = false,
    this.allowedExtensions,
    this.maxFileSizeInMB = 10,
    required this.kind,
    this.showDirectImage = false,
    this.useGallery = true,
    this.multipleFiles = false,
    this.allowReupload = false,
    this.useEyeBlinkDetection = false,
    this.showDottedBorder = true,
    this.allowVideo = false,
    this.allowImage = true,
  });

  @override
  State<MediaUploader> createState() => _MediaUploaderState();
}

class _MediaUploaderState extends State<MediaUploader> {
  static const String _logTag = 'MediaUploader';
  final MediaService _mediaService = MediaService();

  String? _mediaUrl; // For single file mode
  List<String> _mediaUrls = []; // For multiple files mode
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  List<CameraDescription>? _cameras;
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    if (widget.multipleFiles) {
      _mediaUrls = widget.initialUrl != null ? [widget.initialUrl!] : [];
    } else {
      _mediaUrl = widget.initialUrl;
    }
    _checkAuthentication();

    if (widget.useEyeBlinkDetection) {
      _initializeCameras();
    }
  }

  // Modified _initializeCameras method with better error handling
  Future<void> _initializeCameras() async {
    try {
      developer.log('Initializing cameras...', name: _logTag);
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        developer.log('No cameras available on this device', name: _logTag);
        if (mounted) {
          setState(() {
            _errorMessage = AppLocalizations.of(context)!.noCamerasAvailable;
          });
        }
        return;
      }

      // Find front camera for better selfie/eye detection

      CameraDescription? frontCamera;
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _cameras = cameras;
          // Log camera details for troubleshooting
          developer.log('Cameras found: ${cameras.length}', name: _logTag);
          for (int i = 0; i < cameras.length; i++) {
            developer.log(
                'Camera $i: ${cameras[i].name}, direction: ${cameras[i].lensDirection}',
                name: _logTag);
          }
        });
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing cameras',
        error: e,
        stackTrace: stackTrace,
        name: _logTag,
      );

      if (mounted) {
        setState(() {
          _errorMessage =
              '${AppLocalizations.of(context)!.retry}: ${e.toString()}';
        });
      }
    }
  }

  // Show reupload confirmation dialog
  void _showReuploadConfirmDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.replace_media),
          content: Text(
            loc.confirm_replace,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearCurrentMedia();
                _showMediaSourceDialog();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(loc.replace),
            ),
          ],
        );
      },
    );
  }
  // Clear current media
  void _clearCurrentMedia() {
    setState(() {
      if (widget.multipleFiles) {
        _mediaUrls.clear();
        widget.onMultipleMediaUploaded?.call(_mediaUrls);
      } else {
        _mediaUrl = null;
      }
      _errorMessage = null;
    });
  }

  // Improved _openEyeBlinkDetector method
  Future<void> _openEyeBlinkDetector() async {
    if (!_isAuthenticated) {
      _showAuthRequiredDialog();
      return;
    }

    // Initialize cameras if not yet initialized
    if (_cameras == null) {
      await _initializeCameras();
    }

    if (_cameras == null || _cameras!.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.noCamerasAvailable;
      });
      // Show a more informative error dialog
      _showCameraErrorDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      developer.log('Opening eye blink detector...', name: _logTag);
      // Find front camera for better selfie/eye detection
      CameraDescription cameraToUse = _cameras!.first;
      for (var camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.front) {
          cameraToUse = camera;
          break;
        }
      }
      final String? imagePath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FaceEyeBlinkCapture(
            onPhotoCaptured: (path) => path,

            cameras: [cameraToUse], // Pass preferred camera
          ),
        ),
      );

      if (imagePath != null && imagePath.isNotEmpty) {
        developer.log('Photo captured from eye blink detector: $imagePath',
            name: _logTag);

        // Create File object
        final File imageFile = File(imagePath);

        // Check if file exists
        if (!await imageFile.exists()) {
          throw Exception(AppLocalizations.of(context)!.retry);
        }

        // Upload the captured image
        final String? url = await _mediaService.uploadFileAndGetUrl(
          imageFile,
          kind: widget.kind,
        );

        if (url != null && mounted) {
          developer.log('Successfully uploaded eye blink image: $url',
              name: _logTag);
          setState(() {
            if (widget.multipleFiles) {
              _mediaUrls.add(url);
              widget.onMultipleMediaUploaded?.call(_mediaUrls);
            } else {
              _mediaUrl = url;
              widget.onMediaUploaded(url);
            }
            _errorMessage = null;
          });
        } else {
          throw Exception(AppLocalizations.of(context)!.retry);
        }
      } else {
        developer.log('No image captured or user cancelled', name: _logTag);
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error in eye blink detection',
        error: e,
        stackTrace: stackTrace,
        name: _logTag,
      );

      if (mounted) {
        setState(() {
          _errorMessage = 'Capture failed: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Add a more informative camera error dialog
  void _showCameraErrorDialog() {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.camera_error),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.camera_access_issue),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ${loc.camera_permission_check}'),
                    Text('• ${loc.working_camera_check}'),
                    Text('• ${loc.camera_in_use_check}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkAuthentication() async {
    try {
      final bool isAuth = await TokenManager.isLoggedIn();

      if (mounted) {
        setState(() {
          _isAuthenticated = isAuth;
          if (!isAuth) {
            _errorMessage =
                AppLocalizations.of(context)!.authentication_required;
          }
        });
      }

      developer.log('Authentication status: $isAuth', name: _logTag);
    } catch (e, stackTrace) {
      developer.log(
        'Error checking authentication',
        error: e,
        stackTrace: stackTrace,
        name: _logTag,
      );

      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.authenticationError;
        });
      }
    }
  }

  Future<void> _uploadMedia(
      {bool useCamera = false, bool isVideo = false}) async {
    if (!_isAuthenticated) {
      _showAuthRequiredDialog();
      return;
    }

    // If it's for a profile photo and eye blink detection is enabled, use that instead
    if (widget.useEyeBlinkDetection && useCamera && !isVideo) {
      await _openEyeBlinkDetector();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      developer.log(
          'Initiating media upload - useCamera: $useCamera, isVideo: $isVideo',
          name: _logTag);
      final String? url = await _mediaService.pickUploadAndGetUrl(
        context,
        kind: widget.kind,
        useCamera: useCamera,
        isVideo: isVideo,
      );

      if (url != null) {
        developer.log('Media uploaded successfully: $url', name: _logTag);

        if (mounted) {
          setState(() {
            if (widget.multipleFiles) {
              _mediaUrls.add(url);
              widget.onMultipleMediaUploaded?.call(_mediaUrls);
            } else {
              _mediaUrl = url;
              widget.onMediaUploaded(url);
            }
            _errorMessage = null;
          });
        }
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error uploading media',
        error: e,
        stackTrace: stackTrace,
        name: _logTag,
      );

      if (mounted) {
        setState(() {
          _errorMessage = '${AppLocalizations.of(context)!.retry}: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removeMedia(int index) {
    if (widget.multipleFiles && index < _mediaUrls.length) {
      setState(() {
        _mediaUrls.removeAt(index);
      });
      // Notify parent about the updated list
      widget.onMultipleMediaUploaded?.call(_mediaUrls);
    }
  }

  void _showMediaSourceDialog() {
    if (!widget.useGallery) {
      if (widget.useEyeBlinkDetection) {
        _openEyeBlinkDetector();
      } else {
        if (widget.allowVideo && !widget.allowImage) {
          _uploadMedia(useCamera: true, isVideo: true);
        } else {
          _uploadMedia(useCamera: true, isVideo: false);
        }
      }
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final localization = AppLocalizations.of(context)!;

        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          ),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2D2D2D)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              widget.allowVideo && widget.allowImage
                                  ? Icons.perm_media_rounded
                                  : widget.allowVideo
                                      ? Icons.videocam_rounded
                                      : Icons.add_photo_alternate_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            localization.select_media_source,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF2D2D2D),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.allowVideo && widget.allowImage
                                ? 'Choose photo or video from camera or gallery'
                                : widget.allowVideo
                                    ? 'Choose video from camera or gallery'
                                    : localization.howItWorks,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Options
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: _buildMediaOptions(localization),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMediaOptions(AppLocalizations localization) {
    List<Widget> options = [];

    // Camera options
    if (widget.allowImage) {
      options.add(_buildMediaOption(
        context: context,
        icon: Icons.camera_alt_rounded,
        title: widget.useEyeBlinkDetection
            ? localization.cameraTitleBlink
            : 'Camera (Photo)',
        subtitle: widget.useEyeBlinkDetection
            ? localization.cameraSubtitleBlink
            : 'Take a photo with camera',
        gradient: const LinearGradient(
          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {
          Navigator.pop(context);
          if (widget.useEyeBlinkDetection) {
            _openEyeBlinkDetector();
          } else {
            _uploadMedia(useCamera: true, isVideo: false);
          }
        },
      ));

      if (widget.allowVideo) {
        options.add(const SizedBox(height: 12));
      }
    }

    if (widget.allowVideo) {
      options.add(_buildMediaOption(
        context: context,
        icon: Icons.videocam_rounded,
        title: 'Camera (Video)',
        subtitle: 'Record a video with camera',
        gradient: const LinearGradient(
          colors: [Color(0xFFff6b6b), Color(0xFFffa500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {
          Navigator.pop(context);
          _uploadMedia(useCamera: true, isVideo: true);
        },
      ));

      if (widget.allowImage) {
        options.add(const SizedBox(height: 12));
      }
    }

    // Gallery options
    if (widget.allowImage && widget.allowVideo) {
      options.add(_buildMediaOption(
        context: context,
        icon: Icons.perm_media_rounded,
        title: 'Gallery (Photo/Video)',
        subtitle: 'Choose photo or video from gallery',
        gradient: const LinearGradient(
          colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {
          Navigator.pop(context);
          _showGalleryTypeDialog();
        },
      ));
    } else if (widget.allowImage) {
      options.add(_buildMediaOption(
        context: context,
        icon: Icons.photo_library_rounded,
        title: localization.gallery,
        subtitle: localization.choose_from_existing,
        gradient: const LinearGradient(
          colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {
          Navigator.pop(context);
          _uploadMedia(useCamera: false, isVideo: false);
        },
      ));
    } else if (widget.allowVideo) {
      options.add(_buildMediaOption(
        context: context,
        icon: Icons.video_library_rounded,
        title: 'Video Gallery',
        subtitle: 'Choose video from gallery',
        gradient: const LinearGradient(
          colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {
          Navigator.pop(context);
          _uploadMedia(useCamera: false, isVideo: true);
        },
      ));
    }

    return options;
  }

  void _showGalleryTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Media Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_rounded,
                    color: Theme.of(context).primaryColor),
                title: Text('Photo'),
                subtitle: Text('Choose a photo from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadMedia(useCamera: false, isVideo: false);
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam_rounded,
                    color: Theme.of(context).primaryColor),
                title: Text('Video'),
                subtitle: Text('Choose a video from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadMedia(useCamera: false, isVideo: true);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMediaOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF3D3D3D)
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]!
                  : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withAlpha(75),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF2D2D2D),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[500],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI Helper Methods
  void _showAuthRequiredDialog() {
    final loclization = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loclization.authentication_required),
          content: Text(loclization.login_to_upload_media
              // 'You need to be logged in to upload media. Please log in and try again.',
              ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loclization.ok),
            ),
          ],
        );
      },
    );
  }

  void _showMediaPreviewDialog(String url) {
    developer.log('Showing preview for: $url', name: _logTag);

    showDialog(
      context: context,
      builder: (BuildContext context) => _buildPreviewDialog(url),
    );
  }

  Widget _buildPreviewDialog(String url) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPreviewHeader(),
            const SizedBox(height: 16),
            Flexible(
              child: _buildMediaContent(url),
            ),
            _buildReuploadContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(String url) {
    if (_isMediaImage(url)) {
      return _buildImagePreview(url);
    } else if (_isMediaVideo(url)) {
      return _buildVideoPreview(url);
    } else if (_isMediaPdf(url)) {
      return _buildPdfPreview(url);
    } else {
      return _buildFilePreview(url);
    }
  }

  Widget _buildVideoPreview(String url) {
    return VideoPlayerWidget(videoUrl: url);
  }

  Widget _buildPdfPreview(String url) {
    return PdfPreviewWidget(pdfUrl: url);
  }

  Widget _buildPreviewHeader() {
    final loclization = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          loclization.media_preview,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildImagePreview(String url) {
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: _handleImageLoading,
      errorBuilder: _handleImageError,
    );
  }

  Widget _buildFilePreview(String url) {
    final loclization = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, size: 48),
          const SizedBox(height: 16),
          Text(_getFileNameFromUrl(url)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _handleFileOpen(url),
            child: Text(loclization.open),
          ),
        ],
      ),
    );
  }

  // Helper methods
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)
      _handleImageLoading = (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  };

  Widget Function(BuildContext, Object, StackTrace?) _handleImageError =
      (context, error, stackTrace) {
    final loclization = AppLocalizations.of(context)!;

    developer.log(
      'Error loading image in preview',
      error: error,
      stackTrace: stackTrace,
      name: _logTag,
    );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            loclization.failed_to_load_image,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  };

  void _handleFileOpen(String url) {
    // Implement file opening logic here
    Navigator.of(context).pop();
  }

  bool _isMediaImage(String url) {
    final lowerCaseUrl = url.toLowerCase();
    return lowerCaseUrl.endsWith('.jpg') ||
        lowerCaseUrl.endsWith('.jpeg') ||
        lowerCaseUrl.endsWith('.png') ||
        lowerCaseUrl.endsWith('.gif') ||
        lowerCaseUrl.endsWith('.webp');
  }

  bool _isMediaVideo(String url) {
    final lowerCaseUrl = url.toLowerCase();
    return lowerCaseUrl.endsWith('.mp4') ||
        lowerCaseUrl.endsWith('.mov') ||
        lowerCaseUrl.endsWith('.avi') ||
        lowerCaseUrl.endsWith('.mkv') ||
        lowerCaseUrl.endsWith('.webm') ||
        lowerCaseUrl.endsWith('.3gp') ||
        lowerCaseUrl.endsWith('.wmv');
  }

  bool _isMediaPdf(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      return pathSegments.isEmpty ? 'No Profile Photo' : pathSegments.last;
    } catch (e) {
      return url.split('/').last;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.color ?? Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _buildLabel(primaryColor),
          // const SizedBox(height: 8),
          // // Show upload container for single mode or if no files yet in multiple mode
          // if (widget.showDottedBorder && !widget.multipleFiles ||
          //     (_mediaUrl == null && _mediaUrls.isEmpty))
          //   _buildUploadContainer(primaryColor),
          // // Show reupload container if allowReupload is true and media exists
          // if (!widget.showDottedBorder &&
          //     (!widget.multipleFiles ||
          //         (_mediaUrl == null && _mediaUrls.isEmpty)))
          //   _buildUploadContainer(primaryColor),
          // if (widget.allowReupload &&
          //     ((widget.multipleFiles && _mediaUrls.isNotEmpty) ||
          //         (!widget.multipleFiles && _mediaUrl != null)))
          //   if (_errorMessage != null &&
          //       ((widget.multipleFiles && _mediaUrls.isEmpty) ||
          //           (!widget.multipleFiles && _mediaUrl == null)))
          //     _buildErrorMessage(),
          // // Show previews based on mode
          // if (widget.multipleFiles)
          //   _buildMultipleFilesPreview(primaryColor)
          // else if (widget.showPreview && _mediaUrl != null)
          //   _buildPreview(primaryColor),
          _buildLabel(primaryColor),
          const SizedBox(height: 8),
          // Show upload container only if showDottedBorder is true OR if there are no files yet
          if (widget.showDottedBorder &&
              (!widget.multipleFiles ||
                  (_mediaUrl == null && _mediaUrls.isEmpty)))
            _buildUploadContainer(primaryColor),
          // Handle the case when showDottedBorder is false - show dialog directly
          if (!widget.showDottedBorder &&
              (!widget.multipleFiles ||
                  (_mediaUrl == null && _mediaUrls.isEmpty)))
            _buildUploadContainer(primaryColor),
          // Show reupload container if allowReupload is true and media exists
          if (widget.allowReupload &&
              ((widget.multipleFiles && _mediaUrls.isNotEmpty) ||
                  (!widget.multipleFiles && _mediaUrl != null)))
            if (_errorMessage != null &&
                ((widget.multipleFiles && _mediaUrls.isEmpty) ||
                    (!widget.multipleFiles && _mediaUrl == null)))
              _buildErrorMessage(),
          // Show previews based on mode
          if (widget.multipleFiles)
            _buildMultipleFilesPreview(primaryColor)
          else if (widget.showPreview && _mediaUrl != null)
            _buildPreview(primaryColor),
        ],
      ),
    );
  }

  Widget _buildLabel(Color primaryColor) {
    return Row(
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorConstants.black.withAlpha(100),
          ),
        ),
        if (widget.required)
          Text(
            ' *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.red[700],
            ),
          ),
      ],
    );
  }

  Widget _buildUploadContainer(Color primaryColor) {
    // Check if we should show the upload container
    bool shouldShowUpload =
        widget.multipleFiles ? _mediaUrls.isEmpty : _mediaUrl == null;

    if (!shouldShowUpload) {
      return SizedBox.shrink();
    }
    if (!widget.showDottedBorder) {
      // Trigger the dialog after the widget is built, but only once
      if (!_hasShownDialog && !_isLoading && shouldShowUpload) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_hasShownDialog) {
            _hasShownDialog = true;
            _showMediaSourceDialog();
          }
        });
      }
      return SizedBox.shrink(); // Return empty widget - no container shown
    }

    return InkWell(
      onTap: _isLoading ? null : _showMediaSourceDialog,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: _getBorder(primaryColor),
        ),
        child: _isLoading
            ? _buildLoadingIndicator(primaryColor)
            : _buildUploadContent(primaryColor, false),
      ),
    );
  }

  Widget _buildReuploadContainer() {
    final localization = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: InkWell(
        onTap: _isLoading ? null : _showReuploadConfirmDialog,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.edit,
              color: ColorConstants.primaryColor,
              size: 20,
            ),
            SizedBox(
              width: 10,
            ),
            Text(localization.upload_media),
          ],
        ),
      ),
    );
  }

  Border? _getBorder(Color primaryColor) {
    if ((!widget.multipleFiles && _mediaUrl != null) ||
        (widget.multipleFiles && _mediaUrls.isNotEmpty)) {
      return Border.all(color: primaryColor, width: 1);
    } else if (_errorMessage != null) {
      return Border.all(color: Colors.red, width: 1);
    }
    return null;
  }

  Widget _buildLoadingIndicator(Color primaryColor) {
    final localization = AppLocalizations.of(context)!;

    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
        const SizedBox(width: 12),
        Text(localization.uploading),
      ],
    );
  }

  Widget _buildUploadContent(Color primaryColor, bool hasMedia) {
    final localization = AppLocalizations.of(context)!;

    String promptText;
    IconData uploadIcon;

    if (widget.allowVideo && widget.allowImage) {
      promptText = 'Upload photo or video';
      uploadIcon = Icons.perm_media_outlined;
    } else if (widget.allowVideo) {
      promptText = 'Upload video';
      uploadIcon = Icons.videocam_outlined;
    } else {
      promptText = localization.uploadPromptButton;
      uploadIcon = CupertinoIcons.cloud_upload;
    }

    return CustomPaint(
      isComplex: true,
      painter: DottedBorderPainter(),
      child: Container(
        height: 110.0,
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: ColorConstants.greyLight.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  uploadIcon,
                  color: ColorConstants.primaryColor,
                  size: 24.0,
                ),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(letterSpacing: 1, wordSpacing: 1),
                  children: [
                    TextSpan(
                      text: _errorMessage ?? promptText,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' ${widget.label}',
                      style: const TextStyle(
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              FittedBox(
                child: Text(
                  localization.max_file_size,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    fontSize: 10.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 8.0),
      child: Text(
        _errorMessage!,
        style: TextStyle(
          color: Colors.red[700],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPreview(Color primaryColor) {
    if (widget.showDirectImage &&
        _mediaUrl != null &&
        _isMediaImage(_mediaUrl!)) {
      return _buildImagePreviewThumbnail(_mediaUrl!, null);
    }
    final localization = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: () => _showMediaPreviewDialog(_mediaUrl!),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              _getMediaTypeIcon(_mediaUrl!, primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getFileNameFromUrl(_mediaUrl!),
                  style: TextStyle(color: Colors.grey[700]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_red_eye, color: primaryColor),
                onPressed: () => _showMediaPreviewDialog(_mediaUrl!),
                tooltip: localization.media_preview,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleFilesPreview(Color primaryColor) {
    final localization = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 5.0,
      runSpacing: 5.0,
      children: [
        // Display all uploaded files
        ..._mediaUrls.asMap().entries.map((entry) {
          int index = entry.key;
          String url = entry.value;
          return _buildSingleFilePreviewWithRemove(url, index, primaryColor);
        }).toList(),

        if (widget.multipleFiles && _mediaUrls.isNotEmpty)
          InkWell(
            onTap: _isLoading ? null : _showMediaSourceDialog,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Container(
                height: 95,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primaryColor.withAlpha(75)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: primaryColor, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      localization.add_more,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Individual file preview with remove button for multiple files mode
  Widget _buildSingleFilePreviewWithRemove(
      String url, int index, Color primaryColor) {
    if (widget.showDirectImage && _isMediaImage(url)) {
      return _buildImagePreviewThumbnail(url, index);
    }
    final localization = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            _getMediaTypeIcon(url, primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getFileNameFromUrl(url),
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(Icons.remove_red_eye, color: primaryColor),
              onPressed: () => _showMediaPreviewDialog(url),
              tooltip: localization.media_preview,
              constraints: BoxConstraints.tight(Size(36, 36)),
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () => _removeMedia(index),
              tooltip: localization.remove,
              constraints: BoxConstraints.tight(Size(36, 36)),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getMediaTypeIcon(String url, Color primaryColor) {
    if (url.isEmpty) return Icon(Icons.error, color: Colors.red);

    if (_isMediaImage(url)) {
      return Icon(Icons.image, color: primaryColor);
    } else if (_isMediaVideo(url)) {
      return Icon(Icons.videocam, color: primaryColor);
    } else if (_isMediaPdf(url)) {
      return Icon(Icons.picture_as_pdf, color: primaryColor);
    } else {
      return Icon(Icons.insert_drive_file, color: primaryColor);
    }
  }

  Widget _buildImagePreviewThumbnail(String url, int? index) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: () => _showMediaPreviewDialog(url),
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: _handleImageLoading,
                  errorBuilder: _handleImageError,
                ),
                // Preview icon
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(125),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                // Remove button for multiple files mode
                if (index != null)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () => _removeMedia(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(125),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.network(widget.videoUrl);

    await _controller.initialize();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        VideoProgressIndicator(
          _controller,
          allowScrubbing: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}

class PdfPreviewWidget extends StatefulWidget {
  final String pdfUrl;

  const PdfPreviewWidget({
    super.key,
    required this.pdfUrl,
  });

  @override
  State<PdfPreviewWidget> createState() => _PdfPreviewWidgetState();
}

class _PdfPreviewWidgetState extends State<PdfPreviewWidget> {
  String? _localPdfPath;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));

      if (response.statusCode != 200) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load PDF: Status ${response.statusCode}';
        });
        return;
      }

      final dir = await getTemporaryDirectory();
      final file =
          File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(response.bodyBytes);

      if (mounted) {
        setState(() {
          _localPdfPath = file.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load PDF: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_localPdfPath == null) {
      final localization = AppLocalizations.of(context)!;

      return Center(
        child: Text(localization.unable_to_load_pdf),
      );
    }

    return PDFView(
      filePath: _localPdfPath!,
      enableSwipe: true,
      swipeHorizontal: true,
      autoSpacing: false,
      pageFling: false,
      pageSnap: false,
      fitEachPage: false,
      fitPolicy: FitPolicy.WIDTH,
      defaultPage: 0,
      preventLinkNavigation: false,
      onError: (error) {
        setState(() {
          _errorMessage = error.toString();
        });
      },
    );
  }
}
