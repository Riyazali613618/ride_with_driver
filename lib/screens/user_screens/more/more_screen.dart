import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/color_constants.dart';

import '../../../components/app_appbar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/color.dart';
import '../../block/provider/profile_provider.dart';
import '../../common_screens/language_screen.dart';
import '../../common_screens/my_ratings_and_reviews_screen.dart';
import '../../driver_screens/active_plans.dart';
import '../../driver_screens/driver_profile_info.dart';
import '../../driver_screens/erikshaw_rikshaw_profile_screen.dart';
import '../../other/faq_screen.dart';
import '../../other/launch_url.dart';
import '../../other/setting.dart';
import '../../other/support_screen.dart';
import '../../other/terms_and_coditions_bottom_sheet.dart';
import 'edit_account_screen.dart';

class MoreScreen extends StatefulWidget {
  final bool showDriverSubscription;

  const MoreScreen({Key? key, required this.showDriverSubscription})
      : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> with WidgetsBindingObserver {
  bool _visiblePlan = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _visiblePlan = widget.showDriverSubscription;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  @override
  void didUpdateWidget(MoreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showDriverSubscription != widget.showDriverSubscription) {
      setState(() {
        _visiblePlan = widget.showDriverSubscription;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _visiblePlan = widget.showDriverSubscription;
      });
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    await context.read<ProfileProvider>().loadProfile(context);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _visiblePlan = widget.showDriverSubscription;
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CommonParentContainer(
        showLargeGradient: false,
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  "Profile",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )
              ],
            ),
            Expanded(
              child: Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      SizedBox(height: 10),
                      _buildProfileSection(profileProvider),
                      SizedBox(height: 20),
                      _buildMenuItems(context),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(ProfileProvider profileProvider) {
    final localizations = AppLocalizations.of(context)!;
    String displayName = profileProvider.fullName ?? "User";
    String userId = profileProvider.profileData?.id?.toString() ?? "";

    return GestureDetector(
      onTap: () async {
        if (profileProvider.isLoading) return;

        print("profileProvider.profileData!:${profileProvider.profileData}");

        try {
          final userType = profileProvider.profileData!.usertype;
          print('User Type ✅✅✅✅✅: $userType');

          if (userType == 'USER') {
            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ProfileUpdateScreen(),
              ),
            );
          } else if (['E_RICKSHAW', 'RICKSHAW'].contains(userType)) {
            print(
                'User type is $userType, navigating to TransporterDriverProfileScreen');
            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    RickshawProfileScreen(userType: userType!),
              ),
            );
          } else if (['DRIVER', 'TRANSPORTER'].contains(userType)) {
            print(
                'User type is $userType, navigating to TransporterDriverProfileScreen');
            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    TransporterDriverProfileScreen(userType: userType!),
              ),
            );
          } else {
            print(
                'Unknown user type: $userType, navigating to ProfileUpdateScreen');
            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ProfileUpdateScreen(),
              ),
            );
          }

          await profileProvider.loadProfile(context);
        } catch (e) {
          if (!mounted) return;
          print('Error in navigation: ${e.toString()}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  profileProvider.profileData?.profilePhoto != null &&
                          profileProvider.profileData!.profilePhoto
                              .toString()
                              .isNotEmpty
                      ? NetworkImage(
                          profileProvider.profileData!.profilePhoto ?? '')
                      : null,
              child: profileProvider.profileData?.profilePhoto == null ||
                      profileProvider.profileData!.profilePhoto
                          .toString()
                          .isEmpty
                  ? Icon(
                      CupertinoIcons.person_fill,
                      color: Colors.grey[600],
                      size: 28,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (userId.isNotEmpty)
                    Text(
                      'ID: $userId',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    _visiblePlan = widget.showDriverSubscription;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Visibility(
              visible: !_visiblePlan,
              child: _buildMenuItem(
                icon: Icons.map_outlined,
                title: localizations.plans,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionsScreen(
                        baseUrl: ApiConstants.baseUrl,
                      ),
                    ),
                  );
                },
              ),
            ),
            Visibility(
              visible: !_visiblePlan,
              child: _buildMenuItem(
                icon: Icons.star_border,
                title: localizations.my_ratings,
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => MyRatingsScreen()),
                  );
                },
              ),
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: localizations.faq,
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => FAQScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.build_outlined,
              title: localizations.support,
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) =>
                        SupportPage(baseUrl: ApiConstants.baseUrl),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.star_outline,
              title: localizations.rate_our_app,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Coming Soon!')),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.shield_outlined,
              title: localizations.privacy_policy,
              onTap: () => showUserTerms("PRIVACY_POLICY"),
            ),
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: localizations.terms_conditions,
              onTap: () => showUserTerms("TERMS_AND_CONDITIONS"),
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: localizations.about_us,
              onTap: () => showUserTerms("ABOUT_US"),
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: localizations.settings,
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void showUserTerms(String type) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => TermsConditionsBottomSheet(
              type: type,
              buttonHide: true,
            ));
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.black87,
                  size: 24,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black54,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 44),
          child: Divider(
            height: 1,
            thickness: 0.8,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
