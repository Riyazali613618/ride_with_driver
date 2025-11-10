import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/color_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/photo_editing_utils.dart';

class PhotoEditingScreen extends StatefulWidget {
  final File? initialImage;
  final String title;
  final bool isProfilePhoto;
  final Function(File) onImageEdited;

  const PhotoEditingScreen({
    Key? key,
    this.initialImage,
    this.title = 'Edit Photo',
    this.isProfilePhoto = false,
    required this.onImageEdited,
  }) : super(key: key);

  @override
  State<PhotoEditingScreen> createState() => _PhotoEditingScreenState();
}

class _PhotoEditingScreenState extends State<PhotoEditingScreen>
    with TickerProviderStateMixin {
  File? _currentImage;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.initialImage;
    _setupAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);

    try {
      final pickedImage = widget.isProfilePhoto
          ? await PhotoEditingUtils.pickAndCropProfileImage(
              context: context,
              source: source,
            )
          : await PhotoEditingUtils.pickAndCropImage(
              context: context,
              source: source,
              cropAfterPick: true,
              cropStyle: CropStyle.rectangle,
            );

      if (pickedImage != null) {
        setState(() {
          _currentImage = pickedImage;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cropCurrentImage() async {
    if (_currentImage == null) return;

    setState(() => _isLoading = true);

    try {
      final croppedImage = widget.isProfilePhoto
          ? await PhotoEditingUtils.cropProfileImage(
              imageFile: _currentImage!,
              context: context,
            )
          : await PhotoEditingUtils.cropImage(
              imageFile: _currentImage!,
              context: context,
              cropStyle: CropStyle.rectangle,
            );

      if (croppedImage != null) {
        setState(() {
          _currentImage = croppedImage;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cropping image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _saveImage() {
    if (_currentImage != null) {
      widget.onImageEdited(_currentImage!);
      Navigator.of(context).pop(_currentImage);
    }
  }

  void _showImageSourceDialog() {
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                       'Select Image Source',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      title:  'Camera',
                      subtitle: 'Take a new photo',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      title: localizations.gallery ?? 'Gallery',
                      subtitle: 'Choose from existing photos',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: ColorConstants.primaryColor,
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return Expanded(
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isEnabled
                ? ColorConstants.primaryColor.withOpacity(0.1)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEnabled
                  ? ColorConstants.primaryColor.withOpacity(0.3)
                  : Colors.grey[300]!,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isEnabled ? ColorConstants.primaryColor : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isEnabled ? ColorConstants.primaryColor : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (_currentImage != null)
            TextButton(
              onPressed: _isLoading ? null : _saveImage,
              child: Text(
                localizations.done ?? 'Done',
                style: TextStyle(
                  color: ColorConstants.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Processing image...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Image preview area
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: _currentImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _currentImage!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                    child: Icon(
                                      Icons.add_photo_alternate,
                                      color: Colors.grey[400],
                                      size: 48,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'No image selected',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap the camera or gallery button to add a photo',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),

                // Tools section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // File info (if image exists)
                        if (_currentImage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'File Info',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Size: ${PhotoEditingUtils.getFileSize(_currentImage!)}',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Tool buttons
                        Row(
                          children: [
                            _buildToolButton(
                              icon: Icons.camera_alt,
                              label: 'Camera',
                              onTap: () => _pickImage(ImageSource.camera),
                            ),
                            const SizedBox(width: 12),
                            _buildToolButton(
                              icon: Icons.photo_library,
                              label: localizations.gallery ?? 'Gallery',
                              onTap: () => _pickImage(ImageSource.gallery),
                            ),
                            const SizedBox(width: 12),
                            _buildToolButton(
                              icon: Icons.crop,
                              label:  'Crop',
                              onTap: _cropCurrentImage,
                              isEnabled: _currentImage != null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
