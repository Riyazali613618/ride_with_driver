import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../utils/photo_editing_utils.dart';

import '../../components/app_snackbar.dart';
import '../../constants/api_constants.dart';
import '../../constants/token_manager.dart';

class MediaUploadResponse {
  final bool success;
  final String? url;
  final String? errorMessage;
  final String? errorCode;

  const MediaUploadResponse({
    required this.success,
    this.url,
    this.errorMessage,
    this.errorCode,
  });
}

class MediaService {
  static const String _logTag = 'MediaService';
  static final MediaService _instance = MediaService._internal();
  final ImagePicker _picker = ImagePicker();

  factory MediaService() {
    return _instance;
  }

  MediaService._internal();

  // Pick image with enhanced error handling and logging
  Future<XFile?> pickImage({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
    int imageQuality = 80,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      developer.log('Initiating image pick from ${source.name}', name: _logTag);

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (pickedFile != null) {
        // Log file details for debugging
        final File file = File(pickedFile.path);
        final int fileSize = await file.length();
        developer.log(
          'Image picked successfully:\n'
          'Path: ${pickedFile.path}\n'
          'Size: ${(fileSize / 1024).toStringAsFixed(2)} KB\n'
          'Name: ${path.basename(pickedFile.path)}',
          name: _logTag,
        );
      } else {
        developer.log('User cancelled image picking', name: _logTag);
      }

      return pickedFile;
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Error picking image',
        error: e,
        stackTrace: stackTrace,
        name: _logTag,
      );

      if (context.mounted) {
        String errorMessage = 'Could not pick image';
        if (e is PlatformException) {
          errorMessage = e.message ?? errorMessage;
        }
        CustomSnackBar.showCustomSnackBar(
          context: context,
          message: errorMessage,
          success: false,
        );
      }
      return null;
    }
  }

  // Add this method to your MediaService class
  Future<String?> uploadFileAndGetUrl(
    File file, {
    required String kind,
  }) async {
    try {
      developer.log('Starting direct file upload for kind: $kind',
          name: _logTag);

      // Create XFile from File for compatibility with existing upload method
      final XFile xFile = XFile(file.path);

      // Use the existing upload mechanism
      final result = await uploadMedia(xFile, kind: kind);

      if (result.success) {
        developer.log('Direct file upload completed successfully',
            name: _logTag);
        return result.url;
      } else {
        developer.log(
          'Direct file upload failed: ${result.errorMessage}',
          name: _logTag,
          error: result.errorCode,
        );
        return null;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Exception during direct file upload',
        error: e,
        stackTrace: stackTrace,
        name: _logTag,
      );
      return null;
    }
  }

  // Helper methods - MOVED BEFORE uploadMedia method
  String _parseErrorMessage(String responseBody) {
    try {
      final Map<String, dynamic> data = jsonDecode(responseBody);
      return data['message'] ?? data['error'] ?? 'Unknown server error';
    } catch (e) {
      return 'try again ';
    }
  }

  String _getContentType(String fileExt) {
    final Map<String, String> contentTypes = {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.gif': 'image/gif',
      '.webp': 'image/webp',
      '.mp4': 'video/mp4',
      '.mov': 'video/quicktime',
      '.pdf': 'application/pdf',
      '.doc': 'application/msword',
      '.docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    };

    return contentTypes[fileExt] ?? '';
  }

  String _getFileType(String fileExt) {
    final imageExts = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final videoExts = ['.mp4', '.mov', '.avi', '.wmv'];

    if (imageExts.contains(fileExt)) return 'IMAGE';
    if (videoExts.contains(fileExt)) return 'VIDEO';
    return 'DOCUMENT';
  }

  // Enhanced upload media method with better error handling and progress tracking
  Future<MediaUploadResponse> uploadMedia(XFile file,
      {required String kind, String? type}) async {
    try {
      developer.log(
          'Starting media upload process for: ${file.path}, kind: $kind',
          name: _logTag);

      // Token validation
      final String? token = await TokenManager.getToken();
      if (token == null) {
        const String errorMsg = 'Authentication required. Please login again.';
        developer.log(errorMsg, name: _logTag, error: 'Missing token');
        return const MediaUploadResponse(
          success: false,
          errorMessage: errorMsg,
          errorCode: 'AUTH_REQUIRED',
        );
      }

      // File validation
      final int fileSize = await file.length();
      const int maxSize = 10 * 1024 * 1024; // 10MB limit
      if (fileSize > maxSize) {
        const String errorMsg = 'File size exceeds 10MB limit';
        developer.log(errorMsg,
            name: _logTag, error: 'File too large: $fileSize bytes');
        return const MediaUploadResponse(
          success: false,
          errorMessage: errorMsg,
          errorCode: 'FILE_TOO_LARGE',
        );
      }

      // Create upload request
      String baseUrl = '${ApiConstants.baseUrl}/user/upload?type=$kind';

      final Uri url = Uri.parse(baseUrl);
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      final String fileExt = path.extension(file.path).toLowerCase();
      final String contentType = _getContentType(fileExt);
      if (contentType.isEmpty) {
        return const MediaUploadResponse(
          success: false,
          errorMessage: 'Unsupported file type',
          errorCode: 'INVALID_FILE_TYPE',
        );
      }

      // Add file to request with progress tracking
      final fileStream = http.ByteStream(file.openRead());
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileSize,
        filename: path.basename(file.path),
        contentType: MediaType.parse(contentType),
      );

      request.files.add(multipartFile);
      request.fields['type'] = type?? (kind=="transporter"?"document":_getFileType(fileExt));
      request.fields['kind'] = type??kind;

      developer.log(
          'Sending upload request:\n'
          'URL: $url\n'
          'Content-Type: $contentType\n'
          'File size: ${(fileSize / 1024).toStringAsFixed(2)} KB\n'
          'Kind: $kind',
          name: _logTag);

      // Send request with timeout
      print(request.fields);
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          developer.log('Upload request timed out',
              name: _logTag, error: 'Timeout');
          throw TimeoutException('Upload timed out. Please try again.');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      developer.log(
        'Upload response received:\n'
        'Status: ${response.statusCode}\n'
        'Body: ${response.body}',
        name: _logTag,
      );

      // Handle response
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null && responseData['data']['url']!=null) {
          developer.log('Upload successful: ${responseData['url']}',
              name: _logTag);
          return MediaUploadResponse(
            success: true,
            url: responseData['data']['url'],
          );
        } else {
          // FIXED: Handle status: false case with backend message
          final String backendMessage =
              responseData['message'] ?? 'Upload failed';
          developer.log('Upload rejected by backend: $backendMessage',
              name: _logTag);
          return MediaUploadResponse(
            success: false,
            errorMessage: backendMessage,
            errorCode: 'UPLOAD_REJECTED',
          );
        }
      }

      // Handle authentication error
      if (response.statusCode == 401) {
        developer.log('Authentication failed', name: _logTag);
        final String? newToken = await TokenManager.getToken();
        if (newToken != null) {
          developer.log('Token refreshed, retrying upload', name: _logTag);
          return uploadMedia(file, kind: kind);
        }
        return const MediaUploadResponse(
          success: false,
          errorMessage: 'Authentication failed. Please login again.',
          errorCode: 'AUTH_FAILED',
        );
      }

      // Handle other HTTP errors with backend message
      final String backendErrorMessage = _parseErrorMessage(response.body);
      developer.log('Server error: $backendErrorMessage', name: _logTag);
      return MediaUploadResponse(
        success: false,
        errorMessage: backendErrorMessage,
        errorCode: 'SERVER_ERROR_${response.statusCode}',
      );
    } on TimeoutException {
      return const MediaUploadResponse(
        success: false,
        errorMessage: 'Upload timed out. Please try again.',
        errorCode: 'TIMEOUT',
      );
    } on SocketException catch (e) {
      return MediaUploadResponse(
        success: false,
        errorMessage: 'Network error: ${e.message}',
        errorCode: 'NETWORK_ERROR',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error during upload',
        error: e,
        stackTrace: stackTrace,
        name: _logTag,
      );
      return MediaUploadResponse(
        success: false,
        errorMessage: 'Unexpected error: $e',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  // Enhanced method with photo editing capabilities
  Future<String?> pickEditAndUploadUrl(
    BuildContext context, {
    required String kind,
    required String type,
    bool useCamera = false,
    bool enablePhotoEditing = false,
    bool isProfilePhoto = false,
  }) async {
    developer.log(
        'Starting pick, edit and upload process with kind: $kind, useCamera: $useCamera, enablePhotoEditing: $enablePhotoEditing',
        name: _logTag);

    File? imageFile;
    bool progressDialogShown = false;

    try {
      if (enablePhotoEditing) {
        // Use PhotoEditingUtils for enhanced editing
        if (isProfilePhoto) {
          imageFile = await PhotoEditingUtils.pickAndCropProfileImage(
            context: context,
            source: useCamera ? ImageSource.camera : ImageSource.gallery,
          );
        } else {
          imageFile = await PhotoEditingUtils.pickAndCropImage(
            context: context,
            source: useCamera ? ImageSource.camera : ImageSource.gallery,
            cropAfterPick: true,
          );
        }
      } else {
        // Use standard image picking
        final pickedFile = await pickImage(
          context: context,
          source: useCamera ? ImageSource.camera : ImageSource.gallery,
        );

        if (pickedFile != null) {
          imageFile = File(pickedFile.path);
        }
      }

      if (imageFile == null) {
        developer.log('No file selected or editing cancelled', name: _logTag);
        return null;
      }

      // Validate file
      if (!PhotoEditingUtils.isValidImageFile(imageFile)) {
        if (context.mounted) {
          CustomSnackBar.showCustomSnackBar(
            context: context,
            message: 'Invalid file type. Please select a valid image.',
            success: false,
          );
        }
        return null;
      }

      if (!PhotoEditingUtils.isFileSizeValid(imageFile)) {
        if (context.mounted) {
          CustomSnackBar.showCustomSnackBar(
            context: context,
            message:
                'File size too large. Please select a smaller image (max 10MB).',
            success: false,
          );
        }
        return null;
      }

      // Show upload progress dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildUploadProgressDialog(),
        );
        progressDialogShown = true;
      }

      // Convert File to XFile for upload compatibility
      final XFile xFile = XFile(imageFile.path);
      final result = await uploadMedia(xFile, kind: type, type: type);

      // Dismiss progress dialog if shown
      if (progressDialogShown && context.mounted) {
        Navigator.of(context).pop();
        progressDialogShown = false;
      }

      if (result.success) {
        developer.log('Upload completed successfully', name: _logTag);
        return result.url;
      } else {
        if (context.mounted) {
          CustomSnackBar.showCustomSnackBar(
            topOffset: 100,
            showCloseButton: true,
            dismissOnTap: true,
            autoDismiss: false,
            context: context,
            message: result.errorMessage ?? 'Upload failed',
            success: false,
          );
        }
        return null;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error in pickEditAndUploadUrl',
        error: e,
        stackTrace: stackTrace,
        name: _logTag,
      );

      // Ensure progress dialog is dismissed even if there's an error
      if (progressDialogShown && context.mounted) {
        try {
          Navigator.of(context).pop();
        } catch (navError) {
          developer.log('Error dismissing progress dialog',
              error: navError, name: _logTag);
        }
      }

      if (context.mounted) {
        CustomSnackBar.showCustomSnackBar(
          context: context,
          message: 'Upload failed: ${e.toString()}',
          success: false,
        );
      }
      return null;
    }
  }

  Future<XFile?> pickVideo({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
    Duration? maxDuration,
  }) async {
    try {
      developer.log('Initiating video pick from ${source.name}', name: _logTag);

      final XFile? pickedFile = await _picker.pickVideo(
        source: source,
        maxDuration: maxDuration ?? const Duration(minutes: 5),
      );

      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        final int fileSize = await file.length();
        developer.log(
          'Video picked successfully:\n'
          'Path: ${pickedFile.path}\n'
          'Size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB\n'
          'Name: ${path.basename(pickedFile.path)}',
          name: _logTag,
        );
      } else {
        developer.log('User cancelled video picking', name: _logTag);
      }

      return pickedFile;
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Error picking video',
        error: e,
        stackTrace: stackTrace,
        name: _logTag,
      );

      if (context.mounted) {
        String errorMessage = 'Could not pick video';
        if (e is PlatformException) {
          errorMessage = e.message ?? errorMessage;
        }
        CustomSnackBar.showCustomSnackBar(
          context: context,
          message: errorMessage,
          success: false,
        );
      }
      return null;
    }
  }

  // MODIFIED: Updated picker and upload method to properly handle useCamera parameter
  Future<String?> pickUploadAndGetUrl(
    BuildContext context, {
    required String kind,
    bool useCamera = false, // if true → skip dialog, go directly to camera
    bool isVideo = false,
  }) async {
    developer.log(
      'Starting pick and upload process with kind: $kind, useCamera: $useCamera, isVideo: $isVideo',
      name: _logTag,
    );

    XFile? pickedFile;

    if (useCamera) {
      pickedFile = isVideo
          ? await pickVideo(context: context, source: ImageSource.camera)
          : await pickImage(context: context, source: ImageSource.camera);
    } else {
      pickedFile = isVideo
          ? await pickVideo(context: context, source: ImageSource.gallery)
          : await pickImage(context: context, source: ImageSource.gallery);
    }

    if (pickedFile == null) {
      developer.log('No file selected', name: _logTag);
      return null;
    }

    // Show upload progress dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildUploadProgressDialog(),
      );
    }

    try {
      final result = await uploadMedia(pickedFile, kind: kind);

      // Dismiss progress dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (result.success) {
        developer.log('Upload completed successfully', name: _logTag);
        return result.url;
      } else {
        if (context.mounted) {
          CustomSnackBar.showCustomSnackBar(
            topOffset: 100,
            showCloseButton: true,
            dismissOnTap: true,
            autoDismiss: false,
            context: context,
            message: result.errorMessage ?? 'Upload failed',
            success: false,
          );
        }
        return null;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error in pickUploadAndGetUrl',
        error: e,
        stackTrace: stackTrace,
        name: _logTag,
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss dialog
        CustomSnackBar.showCustomSnackBar(
          context: context,
          message: 'Upload failed: $e',
          success: false,
        );
      }
      return null;
    }
  }

  // UI Helper widget for progress dialog
  Widget _buildUploadProgressDialog() {
    return WillPopScope(
      onWillPop: () async => false,
      child: const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Uploading media...'),
          ],
        ),
      ),
    );
  }
}
// CustomSnackBar.showCustomSnackBar(
// context: context,
// message: 'Please Enter Correct Phone or Password',
// success: false,
// );
