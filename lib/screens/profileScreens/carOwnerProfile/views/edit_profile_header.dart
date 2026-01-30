import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:r_w_r/api/api_model/user_model/my_profile_model.dart';
import 'package:r_w_r/utils/common_utils.dart';

import '../../../../api/api_service/media_service.dart';
import '../../../../components/app_loader.dart';
import '../../../../constants/api_constants.dart';
import '../../../../constants/color_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../block/provider/profile_provider.dart';

class EditProfileHeader extends StatefulWidget {
  final MyProfileModel profile;
  final void Function(String) coverImage;
  final void Function(String) profileImage;

  const EditProfileHeader({super.key,
    required this.profile,
    required this.coverImage,
    required this.profileImage});

  @override
  State<EditProfileHeader> createState() => _EditProfileHeaderState();
}

class _EditProfileHeaderState extends State<EditProfileHeader> {
  String? _profileImageUrl;
  String? _coverImageUrl;

  @override
  Widget build(BuildContext context) {
    if (_coverImageUrl == null || _coverImageUrl!.isEmpty) {
      _coverImageUrl = widget.profile.data?.coverImage ?? "";
    }
    return SizedBox(
      height: 190, // cover(140) + avatar overflow
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (_coverImageUrl != null && _coverImageUrl!.isNotEmpty)
            Image.network(
              _coverImageUrl!,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 140,
              color: Colors.grey.shade300,
              child: Icon(Icons.perm_media_outlined),
            ),
          Positioned(
            left: 20,
            bottom: 0, // ✅ no negative offset
            child: Stack(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _showPhotoEditingOptions("profile");
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        widget.profile.data?.profilePhoto ?? "",
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _showPhotoEditingOptions("profile");
                    },
                    child: SvgPicture.asset(
                      "assets/svg/camera_edit_profile.svg",
                      width: 22,
                      height: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 60, // ✅ no negative offset
            child: GestureDetector(
              onTap: () {
                _showPhotoEditingOptions("cover");
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Change Cover Picture",
                  style: TextStyle(
                    fontFamily: AppConstants.ptSansFont,
                    fontSize: 11,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _submitting = false;

  Future<void> _updateProfile(String type) async {
    final provider = context.read<ProfileProvider>();

    // Ensure we're in a loading state while updating
    if (mounted) {
      setState(() {
        _submitting = true;
      });
    }

    var profileData = {};
    if (type == "profile") {
      profileData = {
        'profilePhoto': _profileImageUrl ?? '',
      };
    } else {
      profileData = {
        'coverImage': _coverImageUrl ?? '',
      };
    }
    try {
      final success =
      await context.read<ProfileProvider>().updateProfile(profileData);

      if (mounted) {
        if (success) {
          final localizations = AppLocalizations.of(context)!;

          // Update original data and exit edit mode FIRST
          setState(() {
            _hasChanges = false;
            _isEditing = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text("$type photo updated successfully"),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: Duration(seconds: 2),
            ),
          );

          // Optional: Navigate back after a short delay
          // Uncomment the lines below if you want to automatically go back
          /*
          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
          */
        } else {
          // Handle error case
          final provider = context.read<ProfileProvider>();
          final errorMessage = provider.error ?? 'Failed to update profile';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text(errorMessage)),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('An error occurred: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showPhotoEditingOptions(String type) {
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
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
                          'Edit $type Photo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Camera option
                        _buildPhotoOption(
                          icon: Icons.camera_alt,
                          title: 'Camera',
                          subtitle: 'Take a new photo with editing',
                          onTap: () {
                            Navigator.pop(context);
                            _editProfilePhoto(type: type, useCamera: true);
                          },
                        ),

                        const SizedBox(height: 12),

                        // Gallery option
                        _buildPhotoOption(
                          icon: Icons.photo_library,
                          title: localizations.gallery ?? 'Gallery',
                          subtitle: 'Choose from existing photos',
                          onTap: () {
                            Navigator.pop(context);
                            _editProfilePhoto(type: type, useCamera: false);
                          },
                        ),

                        if (_profileImageUrl != null &&
                            _profileImageUrl!.isNotEmpty) ...[
                          const SizedBox(height: 12),

                          /*  // Remove photo option
                      _buildPhotoOption(
                        icon: Icons.delete_outline,
                        title: 'Remove Photo',
                        subtitle: 'Remove current profile photo',
                        onTap: () {
                          Navigator.pop(context);
                          _removeProfilePhoto();
                        },
                        isDestructive: true,
                      ),*/
                        ],

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  bool _hasChanges = false;
  bool _isEditing = false; // Added editing state
  Map<String, dynamic>? _originalData; // Store original data
  // Build photo option widget
  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDestructive ? Colors.red[200]! : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : ColorConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : ColorConstants.primaryColor,
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
                      color: isDestructive ? Colors.red[700] : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
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

  // Handle profile photo editing with cropping
  Future<void> _editProfilePhoto(
      {required String type, required bool useCamera}) async {
    try {
      final mediaService = MediaService();
      final url = await mediaService.pickEditAndUploadUrl(
        context,
        kind: 'user',
        type: type == "profile" ? 'profilePhoto' : "coverImage",
        isCoverImage: type == "profile" ? false : true,
        useCamera: useCamera,
        enablePhotoEditing: true,
        isProfilePhoto: true,
      );

      if (url != null) {
        print('Uploaded profile photo URL: $url');
        setState(() {
          type == "profile" ? _profileImageUrl = url : _coverImageUrl = url;
          _hasChanges = true;
          widget.profileImage(_profileImageUrl ?? "");
          widget.coverImage(_coverImageUrl ?? "");
          widget.profile.data?.profilePhoto=_profileImageUrl;
          _updateProfile(type);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
