import 'dart:developer' as developer;
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../api/api_service/media_service.dart';
import '../../components/dotted_border.dart';
import '../../components/eye_blink.dart';
import '../../constants/color_constants.dart';
import '../../constants/token_manager.dart';
import '../../l10n/app_localizations.dart';

class ProfileImageCapture extends StatefulWidget {
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

  const ProfileImageCapture({
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
  State<ProfileImageCapture> createState() => _ProfileImageCaptureState();
}

class _ProfileImageCaptureState extends State<ProfileImageCapture> {
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
        if (mounted) {
          setState(() {
            _mediaUrl =(imagePath);
            _errorMessage = null;
            widget.onMediaUploaded(_mediaUrl??"");
          });
        }
        return;
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
    return options;
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
              child: _buildImagePreview(url),
            ),
            _buildReuploadContainer(),
          ],
        ),
      ),
    );
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
          if (widget.showPreview && _mediaUrl != null)
            _buildPreview(primaryColor),
          _buildLabel(primaryColor),
        ],
      ),
    );
  }

  Widget _buildLabel(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
            '*',
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.white,
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
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: _mediaUrl != null && _mediaUrl!.isNotEmpty
          ? ClipOval(
              child: Image.file(
                File(_mediaUrl ?? ""),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            )
          : Icon(
              Icons.camera_alt,
              size: 32,
              color: Colors.grey[600],
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

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: _isLoading ? null : _showMediaSourceDialog,

        child: Container(
          alignment: Alignment.center,
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: _mediaUrl != null && _mediaUrl!.isNotEmpty
              ? ClipOval(
            child: Image.file(
              File(_mediaUrl ?? ""),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          )
              : Icon(
            Icons.camera_alt,
            size: 32,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviewThumbnail(String url, int? index) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: () => _showMediaPreviewDialog(url),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: _mediaUrl != null && _mediaUrl!.isNotEmpty
              ? ClipOval(
            child: Image.file(
              File(_mediaUrl ?? ""),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          )
              : Icon(
            Icons.camera_alt,
            size: 32,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
