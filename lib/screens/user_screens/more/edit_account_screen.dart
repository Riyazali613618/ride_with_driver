import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rwd/api/api_model/user_model/my_profile_model.dart';
import 'package:rwd/api/api_service/user_service/user_profile_service.dart';
import 'package:rwd/components/common_parent_container.dart';
import 'package:rwd/constants/api_constants.dart';
import 'package:rwd/constants/color_constants.dart';
import 'package:rwd/screens/commonWidgets/state_dropdown_widget.dart';
import 'package:rwd/utils/common_utils.dart';

import 'package:rwd/api/api_model/cityModel.dart' as cm;
import 'package:rwd/api/api_model/stateModel.dart' as sm;

import '../../../api/api_service/countryStateProviderService.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;
import '../../block/provider/profile_provider.dart';
import '../../../api/api_service/media_service.dart';
import '../../commonWidgets/city_dropdown_widget.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({Key? key}) : super(key: key);

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();

  String? _profileImageUrl;
  bool _hasChanges = false;
  bool _isEditing = false; // Added editing state
  Map<String, dynamic>? _originalData; // Store original data
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  String? _selectedCity;
  String? _selectedState;
  List<cm.Data> _cityList = [];
  List<sm.Data> _stateList = [];
  String? currentCountry;

  MyProfileData? myProfile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadProfileData();
      _initializeLocation();
    });
    _setupControllerListeners();
    _setupAnimations();
  }

  void _initializeLocation() {
    final langProvider = Provider.of<LocationProvider>(context, listen: false);
    currentCountry =
        langProvider.selectedCountry ?? ApiConstants.defaultCountryCodeInd;
    print("StateID===${myProfile?.state?.id}");
    String stateId = "";
    langProvider.fetchStates(currentCountry!).then((_) {
      if (mounted) {
        _stateList = langProvider.states;
        for (final state in _stateList) {
          if ((myProfile?.state?.id ?? "") == state.sId) {
            stateId = state.sId ?? "";
            _selectedState = stateId;
            break;
          }
        }
        if (_selectedState != null && _selectedState!.isNotEmpty) {
          langProvider.fetchCity(stateId ?? "").then((_) {
            setState(() {
              _cityList = langProvider.cities;
              for (final city in _cityList) {
                if ((myProfile?.city?.id ?? "") == city.sId) {
                  _selectedCity = city.sId;
                  break;
                }
              }
            });
          });
        }

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _languageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
  }

  void _setupControllerListeners() {
    void checkChanges() {
      if (!_isEditing) return; // Only check changes when editing

      final hasChanges = _originalData != null &&
          (_firstNameController.text.trim() !=
                  (_originalData!['firstName'] ?? '') ||
              _lastNameController.text.trim() !=
                  (_originalData!['lastName'] ?? '') ||
              _emailController.text.trim() != (_originalData!['email'] ?? '') ||
              _phoneController.text.trim() !=
                  (_originalData!['phoneNumber'] ?? '') ||
              // _languageController.text.trim() != (_originalData!['language'] ?? '') ||
              _profileImageUrl != _originalData!['profilePhoto']);

      if (hasChanges != _hasChanges) {
        setState(() => _hasChanges = hasChanges);
        if (_hasChanges) {
          _fabAnimationController.forward();
        } else {
          _fabAnimationController.reverse();
        }
      }
    }

    _firstNameController.addListener(checkChanges);
    _lastNameController.addListener(checkChanges);
    _emailController.addListener(checkChanges);
    _phoneController.addListener(checkChanges);
    // _languageController.addListener(checkChanges);
  }

  Future<void> _loadProfileData() async {
    final provider = context.read<ProfileProvider>();
    await provider.loadProfile(context);
    myProfile = await UserProfileService().getUserProfile();

    if (provider.profileData != null) {
      final data = provider.profileData!;

      final firstName = provider.firstName ?? '';
      final lastName = provider.lastName ?? '';

      setState(() {
        _firstNameController.text = firstName;
        _lastNameController.text = lastName;
        _emailController.text = provider.email ?? '';
        _phoneController.text = provider.phoneNumber ?? '';
        _languageController.text = provider.language?.isNotEmpty == true
            ? provider.language!['name']
            : '';
        _profileImageUrl = provider.profilePhoto;
        _originalData = data.toJson();
        _hasChanges = false;
        _isEditing = false;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // If canceling edit, restore original data
        _restoreOriginalData();
        _hasChanges = false;
        _fabAnimationController.reverse();
      }
    });
  }

  void _restoreOriginalData() {
    if (_originalData != null) {
      setState(() {
        _firstNameController.text = _originalData!['firstName'] ?? '';
        _lastNameController.text = _originalData!['lastName'] ?? '';
        _emailController.text = _originalData!['email'] ?? '';
        _phoneController.text = _originalData!['number'] ?? '';
        _languageController.text = _originalData!['language']['name'] ?? '';
        _profileImageUrl = _originalData!['image'];
      });
    }
  }

  Future<void> _updateProfile() async {
    final provider = context.read<ProfileProvider>();
    if (!_formKey.currentState!.validate()) return;

    // Ensure we're in a loading state while updating
    if (mounted) {
      setState(() {
        // Optional: You can add a local loading state if needed
      });
    }

    final profileData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'number': _phoneController.text.trim(),
      // 'language': _languageController.text.trim(),
      'profilePhoto': _profileImageUrl ?? '',
      "state":_selectedState,
      "city":_selectedCity,
    };
    jsonEncode(profileData);

    try {
      final success =
          await context.read<ProfileProvider>().updateProfile(profileData);

      if (mounted) {
        if (success) {
          final localizations = AppLocalizations.of(context)!;

          // Update original data and exit edit mode FIRST
          setState(() {
            _originalData = Map<String, dynamic>.from(profileData);
            _hasChanges = false;
            _isEditing = false;
          });
          _fabAnimationController.reverse();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(localizations.profile_updated_success),
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
    } catch (e) {
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

  String? _validateRequired(String? value, String fieldName) {
    final localizations = AppLocalizations.of(context)!;

    if (value == null || value.trim().isEmpty) {
      return localizations.fieldRequired(fieldName);
    }
    return null;
  }

  Widget _buildFormSection() {
    final profileProvider = context.watch<ProfileProvider>();
    final initialImage = profileProvider.profileData?.profilePhoto;
    final localizations = AppLocalizations.of(context)!;

    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image section with enhanced photo editing
            Center(
              child: _isEditing
                  ? _buildEditableProfileImage(initialImage)
                  : Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 10,
                        ),
                      ),
                      child: ClipOval(
                        child: ((_profileImageUrl != null &&
                                    _profileImageUrl!.isNotEmpty) ||
                                (initialImage != null &&
                                    initialImage.isNotEmpty))
                            ? Image.network(
                                _profileImageUrl ?? initialImage!,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ColorConstants.primaryColor,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildDefaultAvatar(),
                              )
                            : _buildDefaultAvatar(),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                _buildAnimatedTextField(
                  label: localizations.firstName,
                  controller: _firstNameController,
                  icon: Icons.person,
                  validator: (value) =>
                      _validateRequired(value, localizations.firstName),
                  enabled: _isEditing,
                ),
                const SizedBox(height: 16),
                _buildAnimatedTextField(
                  label: localizations.last_name,
                  controller: _lastNameController,
                  icon: Icons.person_outline,
                  enabled: _isEditing,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              label: localizations.emailAddress,
              controller: _emailController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              label: localizations.phoneNumber,
              controller: _phoneController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              enabled: false, // Phone is always disabled
            ),
            SizedBox(height: 16),
            StateDropdownWidget(
              isReadonly: !_isEditing,
              stateList: _stateList,
              selectedState: _selectedState,
              onChanged: (newValue) {
                final locProvider =
                    Provider.of<LocationProvider>(context, listen: false);

                setState(() {
                  _selectedState = newValue;
                  _selectedCity = null;
                  _cityList = [];
                });

                if (newValue != null) {
                  locProvider.fetchCity(newValue).then((_) {
                    setState(() {
                      _cityList = locProvider.cities;
                    });
                  });
                }
              },
            ),
            SizedBox(height: 16),
            CityDropdownWidget(
              isReadonly: !_isEditing,
              cityList: _cityList,
              selectedCity: _selectedCity,
              onChanged: (newValue) {
                setState(() {
                  _selectedCity = newValue;
                });
              },
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(
              label: "Language",
              controller: _languageController,
              icon: Icons.language_outlined,
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced profile image editor with photo editing capabilities
  Widget _buildEditableProfileImage(String? initialImage) {
    final localizations = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 10,
            ),
          ),
          child: ClipOval(
            child:
                ((_profileImageUrl != null && _profileImageUrl!.isNotEmpty) ||
                        (initialImage != null && initialImage.isNotEmpty))
                    ? Image.network(
                        _profileImageUrl ?? initialImage!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorConstants.primaryColor,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultAvatar(),
                      )
                    : _buildDefaultAvatar(),
          ),
        ),
        // Edit button overlay
        Positioned(
          bottom: 6,
          right: 6,
          child: InkWell(
            onTap: _showPhotoEditingOptions,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Show photo editing options with modern UI
  void _showPhotoEditingOptions() {
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
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
                      'Edit Profile Photo',
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
                        _editProfilePhoto(useCamera: true);
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
                        _editProfilePhoto(useCamera: false);
                      },
                    ),

                    if (_profileImageUrl != null &&
                        _profileImageUrl!.isNotEmpty) ...[
                      const SizedBox(height: 12),

                      // Remove photo option
                      _buildPhotoOption(
                        icon: Icons.delete_outline,
                        title: 'Remove Photo',
                        subtitle: 'Remove current profile photo',
                        onTap: () {
                          Navigator.pop(context);
                          _removeProfilePhoto();
                        },
                        isDestructive: true,
                      ),
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
  Future<void> _editProfilePhoto({required bool useCamera}) async {
    try {
      final mediaService = MediaService();
      final url = await mediaService.pickEditAndUploadUrl(
        context,
        kind: 'user',
        type: 'profilePhoto',
        useCamera: useCamera,
        enablePhotoEditing: true,
        isProfilePhoto: true,
      );

      if (url != null) {
        print('Uploaded profile photo URL: $url');
        setState(() {
          _profileImageUrl = url;
          _hasChanges = true;
        });
        _fabAnimationController.forward();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile photo updated successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
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

  // Remove profile photo
  void _removeProfilePhoto() {
    setState(() {
      _profileImageUrl = '';
      _hasChanges = true;
    });
    _fabAnimationController.forward();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 8),
            Text('Profile photo removed'),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final profileProvider = context.watch<ProfileProvider>();
    String name = profileProvider.fullName.toString();
    return Container(
      color: ColorConstants.primaryColor.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 40,
              color: ColorConstants.primaryColor,
            ),
            SizedBox(height: 4),
            Text(
              name.toString(),
              style: TextStyle(
                fontSize: 12,
                color: ColorConstants.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: CommonUtils.commonTextLabelsStyle(),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color(0xFF641BB4), width: 1),
                  ),
                  child: TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    validator: validator,
                    enabled: enabled,
                    style: TextStyle(
                      fontFamily: AppConstants.ptSansFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Add Photo",
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => context.read<ProfileProvider>().clearError(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final profileProvider = context.watch<ProfileProvider>();
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: _isEditing
          ? Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        !profileProvider.isLoading ? _toggleEditMode : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      localizations.cancel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _hasChanges && !profileProvider.isLoading
                        ? _updateProfile
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: profileProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            localizations.save_changes,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            )
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !profileProvider.isLoading ? _toggleEditMode : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  localizations.edit_profile,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final localizations = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async {
        if (!_hasChanges) return true;

        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text(localizations.unsaved_changes),
              ],
            ),
            content: Text(
              localizations.confirm_leave_without_saving,
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  localizations.cancel,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  localizations.leave,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );

        return shouldLeave ?? false;
      },
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: ColorConstants.primaryColor,
        //   elevation: 0,
        //   title: Text(
        //     localizations.edit_profile,
        //     style: const TextStyle(
        //       color: Colors.white,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        //   centerTitle: true,
        //   leading: IconButton(
        //     icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        //     onPressed: () => Navigator.of(context).pop(),
        //   ),
        // ),
        body: CommonParentContainer(
          child: profileProvider.isLoading &&
                  profileProvider.profileData == null
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
                        localizations.loading_profile,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 20),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back_ios,
                                        color: ColorConstants.white,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localizations.edit_profile,
                                            style: CommonUtils.commonTitleStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildFormSection(),
                              // if (profileProvider.error != null)
                              //   _buildErrorCard(profileProvider.error!),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      _buildActionButtons(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
