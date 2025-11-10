// screens/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/components/app_button.dart';
import 'package:r_w_r/screens/user_screens/user_profile_event.dart';

import '../../api/api_model/user_model/user_profile_model.dart';
import '../../components/app_loader.dart';
import '../../components/custom_text_field.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();

  // Phone number is displayed but not editable
  final TextEditingController _phoneController = TextEditingController();

  late UserProfileBloc _userProfileBloc;
  bool _isEditing = false;
  UserData? _currentUserData;

  @override
  void initState() {
    super.initState();
    _userProfileBloc = BlocProvider.of<UserProfileBloc>(context);
    _userProfileBloc.add(FetchUserProfile());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _languageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateFormFields(UserData userData) {
    _firstNameController.text = userData.firstName;
    _lastNameController.text = userData.lastName;
    _emailController.text = userData.email;
    _languageController.text = userData.language;
    _phoneController.text = userData.number ?? '';
    _currentUserData = userData;
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate() && _currentUserData != null) {
      // Update the user data and send it
      final updatedUserData = _currentUserData!.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        language: _languageController.text.trim(),
      );

      _userProfileBloc.add(UpdateUserProfile(updatedUserData));
      _toggleEditMode();
    }
  }

  void _cancelEdit() {
    if (_currentUserData != null) {
      _populateFormFields(_currentUserData!);
    }
    _toggleEditMode();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Simple email validation regex
    if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // BlocBuilder<UserProfileBloc, UserProfileState>(
          //   builder: (context, state) {
          //     if (state is UserProfileLoaded) {
          //       return _isEditing
          //           ? IconButton(
          //               icon: const Icon(Icons.close),
          //               onPressed: _cancelEdit,
          //             )
          //           : IconButton(
          //               icon: const Icon(Icons.edit),
          //               onPressed: _toggleEditMode,
          //             );
          //     }
          //     return const SizedBox();
          //   },
          // ),
        ],
      ),
      body: BlocConsumer<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is UserProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is UserProfileLoaded) {
            if (_currentUserData == null) {
              _populateFormFields(state.userData);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          _getInitials(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      enabled: _isEditing,
                      validator: _validateName,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      enabled: _isEditing,
                      validator: _validateName,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      enabled: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    // CustomTextField(
                    //   controller: _languageController,
                    //   label: 'Language',
                    //   enabled: _isEditing,
                    // ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      enabled: false,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 40),
                    if (_isEditing)
                      CustomButton(text: "Save", onPressed: _saveChanges)
                    else
                      CustomButton(
                          text: "Edit Profile", onPressed: _toggleEditMode)
                  ],
                ),
              ),
            );
          } else if (state is UserProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _userProfileBloc.add(FetchUserProfile()),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: LoadingIndicator());
        },
      ),
    );
  }

  String _getInitials() {
    if (_currentUserData == null) return '';

    final firstName = _currentUserData!.firstName;
    final lastName = _currentUserData!.lastName;

    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }

    return initials;
  }
}
