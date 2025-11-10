import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../constants/color_constants.dart';
import '../l10n/app_localizations.dart';

class PhotoEditingUtils {
  static const String _logTag = 'PhotoEditingUtils';

  /// Crop image with user-friendly interface
  static Future<File?> cropImage({
    required File imageFile,
    required BuildContext context,
    CropStyle cropStyle = CropStyle.rectangle,
    List<CropAspectRatioPreset>? aspectRatioPresets,
  }) async {
    try {
      final localizations = AppLocalizations.of(context)!;

      // Add a small delay to ensure proper initialization
      await Future.delayed(const Duration(milliseconds: 100));

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        maxWidth: 1080,
        maxHeight: 1080,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Photo',
            toolbarColor: ColorConstants.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            statusBarColor: ColorConstants.primaryColor,
            activeControlsWidgetColor: ColorConstants.primaryColor,
            backgroundColor: Colors.black,
            dimmedLayerColor: Colors.black.withOpacity(0.8),
            cropFrameColor: ColorConstants.primaryColor,
            cropGridColor: Colors.white.withOpacity(0.5),
            cropFrameStrokeWidth: 2,
            cropGridStrokeWidth: 1,
            showCropGrid: true,
            hideBottomControls: false,
            cropStyle: cropStyle,
            aspectRatioPresets: aspectRatioPresets ??
                [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ],
          ),
          IOSUiSettings(
            title: 'Edit Photo',
            doneButtonTitle: localizations.done ?? 'Done',
            cancelButtonTitle: localizations.cancel ?? 'Cancel',
            resetButtonHidden: false,
            aspectRatioPickerButtonHidden: false,
            aspectRatioLockEnabled: false,
            minimumAspectRatio: 0.2,
            resetAspectRatioEnabled: true,
            cropStyle: cropStyle,
            aspectRatioPresets: aspectRatioPresets ??
                [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ],
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      // If image cropping fails, return the original file instead of null
      // This prevents the app from crashing and provides a fallback
      return imageFile;
    }
  }

  /// Crop image specifically for profile pictures (square aspect ratio)
  static Future<File?> cropProfileImage({
    required File imageFile,
    required BuildContext context,
  }) async {
    return cropImage(
      imageFile: imageFile,
      context: context,
      cropStyle: CropStyle.circle,
      aspectRatioPresets: [CropAspectRatioPreset.square],
    );
  }

  /// Pick image from gallery or camera with cropping option
  static Future<File?> pickAndCropImage({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
    bool cropAfterPick = true,
    CropStyle cropStyle = CropStyle.rectangle,
    List<CropAspectRatioPreset>? aspectRatioPresets,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 90, // Good quality for editing
        maxWidth: 2048, // Reasonable max size
        maxHeight: 2048,
      );

      if (pickedFile == null) return null;

      File imageFile = File(pickedFile.path);

      if (cropAfterPick) {
        final croppedFile = await cropImage(
          imageFile: imageFile,
          context: context,
          cropStyle: cropStyle,
          aspectRatioPresets: aspectRatioPresets,
        );

        return croppedFile;
      }

      return imageFile;
    } catch (e) {
      debugPrint('Error picking and cropping image: $e');
      return null;
    }
  }

  /// Pick and crop image specifically for profile pictures
  static Future<File?> pickAndCropProfileImage({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
  }) async {
    return pickAndCropImage(
      context: context,
      source: source,
      cropAfterPick: true,
      cropStyle: CropStyle.circle,
      aspectRatioPresets: [CropAspectRatioPreset.square],
    );
  }

  /// Show image source selection dialog with crop option
  static Future<File?> showImageSourceDialog({
    required BuildContext context,
    bool enableCropping = true,
    CropStyle cropStyle = CropStyle.rectangle,
    List<CropAspectRatioPreset>? aspectRatioPresets,
  }) async {
    final localizations = AppLocalizations.of(context)!;

    return showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                Icon(Icons.camera_alt, color: ColorConstants.primaryColor),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickAndCropImage(
                    context: context,
                    source: ImageSource.camera,
                    cropAfterPick: enableCropping,
                    cropStyle: cropStyle,
                    aspectRatioPresets: aspectRatioPresets,
                  );
                  Navigator.of(context).pop(file);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library,
                    color: ColorConstants.primaryColor),
                title: Text(localizations.gallery ?? 'Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickAndCropImage(
                    context: context,
                    source: ImageSource.gallery,
                    cropAfterPick: enableCropping,
                    cropStyle: cropStyle,
                    aspectRatioPresets: aspectRatioPresets,
                  );
                  Navigator.of(context).pop(file);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel ?? 'Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Show profile image source selection dialog
  static Future<File?> showProfileImageSourceDialog({
    required BuildContext context,
  }) async {
    return showImageSourceDialog(
      context: context,
      enableCropping: true,
      cropStyle: CropStyle.circle,
      aspectRatioPresets: [CropAspectRatioPreset.square],
    );
  }

  /// Get file size in a human-readable format
  static String getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Validate image file
  static bool isValidImageFile(File file) {
    final extension = path.extension(file.path).toLowerCase();
    const validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return validExtensions.contains(extension);
  }

  /// Check if file size is within limits (default 10MB)
  static bool isFileSizeValid(File file, {int maxSizeInMB = 10}) {
    try {
      final bytes = file.lengthSync();
      final maxBytes = maxSizeInMB * 1024 * 1024;
      return bytes <= maxBytes;
    } catch (e) {
      return false;
    }
  }

  /// Create a temporary file from bytes
  static Future<File?> createTempFileFromBytes(
      Uint8List bytes,
      String fileName,
      ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);
      return tempFile;
    } catch (e) {
      debugPrint('Error creating temp file: $e');
      return null;
    }
  }

  /// Copy file to a new location with new name
  static Future<File?> copyFileToNewLocation(
      File originalFile,
      String newFileName,
      ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final extension = path.extension(originalFile.path);
      final newFile = File('${tempDir.path}/$newFileName$extension');
      await originalFile.copy(newFile.path);
      return newFile;
    } catch (e) {
      debugPrint('Error copying file: $e');
      return null;
    }
  }
}