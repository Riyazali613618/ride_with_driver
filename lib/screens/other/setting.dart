import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/screens/auth_screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/color_constants.dart';
import '../../constants/token_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/color.dart';
import '../auth_screens/logout_button.dart';
import '../block/home/home_provider.dart';
import 'package:path_provider/path_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool whatsappEnabled = false;
  bool phoneEnabled = false;
  bool isLoading = false;

  static const String baseUrl = ApiConstants.baseUrl;
  static const String _whatsappKey = 'whatsapp_enabled';
  static const String _phoneKey = 'phone_enabled';

  @override
  void initState() {
    super.initState();
    //_loadContactPreferences();
  }
  // API Logger helper
  void _logApiCall(String method, String endpoint,
      {Map<String, dynamic>? requestBody, int? statusCode, String? response}) {
    dev.log('=== API CALL ===', name: 'API');
    dev.log('Endpoint: $endpoint', name: 'API');
    if (requestBody != null) {
      dev.log('Request Body: ${jsonEncode(requestBody)}', name: 'API');
    }
    if (statusCode != null) {
      dev.log('Status Code: $statusCode', name: 'API');
    }
    if (response != null) {
      dev.log('Response: $response', name: 'API');
    }
    dev.log('===============', name: 'API');
  }

  Future<void> _loadContactPreferences() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load from local storage first for immediate display
      final localWhatsapp = prefs.getBool(_whatsappKey);
      final localPhone = prefs.getBool(_phoneKey);

      if (localWhatsapp != null && localPhone != null) {
        if (mounted) {
          setState(() {
            whatsappEnabled = localWhatsapp;
            phoneEnabled = localPhone;
          });
        }
      }

      // Then try to load from server and sync
      final token = await TokenManager.getToken();
      if (token == null) {
        if (mounted) {
          _showSnackBar(
            AppLocalizations.of(context)!.authenticationError,
            isError: true,
          );
        }
        return;
      }

      final endpoint = '$baseUrl/user/pref-account';
      _logApiCall('GET', endpoint);

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logApiCall('GET', endpoint,
          statusCode: response.statusCode, response: response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['data'] != null) {
          final preferences = responseData['data'];
          final serverWhatsapp = preferences['whatsapp'] ?? false;
          final serverPhone = preferences['phone'] ?? false;

          setState(() {
            whatsappEnabled = serverWhatsapp;
            phoneEnabled = serverPhone;
          });

          // Save to local storage for offline access
          await prefs.setBool(_whatsappKey, whatsappEnabled);
          await prefs.setBool(_phoneKey, phoneEnabled);
        }
      } else {
        // If server request fails, show error but keep local values
        final errorData = jsonDecode(response.body);
        _showSnackBar(
          errorData['message'] ?? 'Failed to load preferences from server',
          isError: true,
        );
      }
    } catch (e) {
      // If there's an error, show error message but keep local values
      dev.log('Error loading preferences: $e', name: 'ERROR');
      if (mounted) {
        _showSnackBar(
          AppLocalizations.of(context)!.networkError,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _savePreferencesLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_whatsappKey, whatsappEnabled);
      await prefs.setBool(_phoneKey, phoneEnabled);
    } catch (e) {
      dev.log('Error saving preferences locally: $e', name: 'ERROR');
    }
  }

  Future<void> _updateContactPreferences() async {
    if (isLoading || !mounted) return;

    // Save locally first for immediate persistence
    await _savePreferencesLocally();

    setState(() {
      isLoading = true;
    });

    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        if (mounted) {
          _showSnackBar(
            AppLocalizations.of(context)!.authenticationError,
            isError: true,
          );
        }
        return;
      }

      final endpoint = '$baseUrl/user/pref-account';
      final requestBody = {
        'whatsapp': whatsappEnabled,
        'phone': phoneEnabled,
      };

      _logApiCall('POST', endpoint, requestBody: requestBody);

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      _logApiCall('POST', endpoint,
          statusCode: response.statusCode, response: response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          _showSnackBar(
            responseData['message'] ??
                AppLocalizations.of(context)!.preferencesUpdated,
          );
        } else {
          _showSnackBar(
            responseData['message'] ??
                AppLocalizations.of(context)!.failedUpdatePreferences,
            isError: true,
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar(
          errorData['message'] ??
              AppLocalizations.of(context)!.failedUpdatePreferences,
          isError: true,
        );
      }
    } catch (e) {
      dev.log('Error updating preferences: $e', name: 'ERROR');
      if (mounted) {
        _showSnackBar(
          AppLocalizations.of(context)!.networkError,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAccount() async {
    if (isLoading || !mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        if (mounted) {
          _showSnackBar(
            AppLocalizations.of(context)!.authenticationError,
            isError: true,
          );
        }
        return;
      }

      final endpoint = '$baseUrl/user/delete-account';
      _logApiCall('DELETE', endpoint);

      final response = await http.delete(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logApiCall('DELETE', endpoint,
          statusCode: response.statusCode, response: response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          _showSnackBar(
            responseData['message'] ??
                AppLocalizations.of(context)!.accountDeleted,
          );

          // Clear preferences when account is deleted
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(_whatsappKey);
          await prefs.remove(_phoneKey);
          await prefs.clear();

           final tempDir = await getTemporaryDirectory();
                    if (tempDir.existsSync()) {
                      tempDir.deleteSync(recursive: true);
                    }

          await TokenManager.clearAllData();

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
            );
          }
        } else {
          _showSnackBar(
            responseData['message'] ??
                AppLocalizations.of(context)!.failedDeleteAccount,
            isError: true,
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar(
          errorData['message'] ??
              AppLocalizations.of(context)!.failedDeleteAccount,
          isError: true,
        );
      }
    } catch (e) {
      dev.log('Error deleting account: $e', name: 'ERROR');
      if (mounted) {
        _showSnackBar(
          AppLocalizations.of(context)!.networkError,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      // backgroundColor: Colors.grey[50],
      // appBar: CustomAppBar(
      //   title: loc.settings,
      //   centerTitle: true,
      // ),
      body: Consumer<HomeDataProvider>(
        builder: (context,provider,child){
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  gradientFirst,
                  gradientSecond,
                  gradientThird,
                  Colors.white
                ],
                stops: [0.01, 0.20, 0.31, .34],
              ),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: ColorConstants.white,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.settings,
                                    style: TextStyle(
                                      color: ColorConstants.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if(provider.showDashboard == true) ...[
                        _buildSectionHeader(loc.contactPreferences),
                        const SizedBox(height: 12),

                      Container(
                        decoration: _buildCardDecoration(),
                        child: Column(
                          children: [
                            _buildToggleTile(
                              icon: Icons.chat_outlined,
                              iconColor: Colors.green,
                              title: loc.whatsappNotifications,
                              subtitle: loc.whatsappSubtitle,
                              value: whatsappEnabled,
                              onChanged: (value) {
                                setState(() {
                                  whatsappEnabled = value;
                                });
                                _updateContactPreferences();
                              },
                            ),
                            const Divider(height: 1, indent: 72),
                            _buildToggleTile(
                              icon: Icons.phone_outlined,
                              iconColor: Colors.blue,
                              title: loc.phoneNotifications,
                              subtitle: loc.phoneSubtitle,
                              value: phoneEnabled,
                              onChanged: (value) {
                                setState(() {
                                  phoneEnabled = value;
                                });
                                _updateContactPreferences();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ],
                      _buildSectionHeader(loc.accountManagement),
                      const SizedBox(height: 12),
                      Container(
                        decoration: _buildCardDecoration(),
                        child: Column(
                          children: [
                            const LogoutButton(),
                            const Divider(height: 1, indent: 72),
                            _buildSettingTile(
                              icon: Icons.delete_forever,
                              iconColor: Colors.red,
                              title: loc.deleteAccount,
                              subtitle: loc.deleteAccountSubtitle,
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                              onTap: _showDeleteAccountDialog,
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 24),
                      // _buildSectionHeader(loc.otherSettings),
                      // const SizedBox(height: 12),
                      // Container(
                      //   decoration: _buildCardDecoration(),
                      //   child: Column(
                      //     children: [
                      //       _buildSettingTile(
                      //         icon: Icons.language,
                      //         iconColor: Colors.orange,
                      //         title: loc.language,
                      //         subtitle: loc.changeLanguage,
                      //         trailing: const Icon(
                      //           Icons.arrow_forward_ios,
                      //           size: 16,
                      //           color: Colors.grey,
                      //         ),
                      //         onTap: () async {
                      //           final selectedLanguage = await showModalBottomSheet<String>(
                      //             context: context,
                      //             isScrollControlled: true,
                      //             backgroundColor: Colors.transparent,
                      //             builder: (context) => DraggableScrollableSheet(
                      //               initialChildSize: 0.95,
                      //               minChildSize: 0.5,
                      //               maxChildSize: 0.95,
                      //               builder: (_, controller) => const LanguageSelectionScreen(),
                      //             ),
                      //           );
                      //           if (selectedLanguage != null) {
                      //             // Handle language change if needed
                      //           }
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withAlpha(75),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(15),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: iconColor,
        activeTrackColor: iconColor.withAlpha(75),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showDeleteAccountDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                loc.deleteAccount,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            loc.deleteAccountDialogContent,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                loc.cancel,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                loc.deleteAccount,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }
}
