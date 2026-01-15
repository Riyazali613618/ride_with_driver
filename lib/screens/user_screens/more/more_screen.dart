import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/color_constants.dart';
import 'package:r_w_r/screens/profileScreens/carOwnerProfile/views/edit_car_owner_profile.dart';
import 'package:r_w_r/screens/profileScreens/eRickshawProfile/e_rickshaw_owner_profile.dart';
import 'package:r_w_r/utils/common_utils.dart';

import '../../../api/api_service/user_service/user_profile_service.dart';
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
  final bool showPlan;

  const MoreScreen(
      {super.key, this.showPlan = false, required this.showDriverSubscription});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> with WidgetsBindingObserver {
  bool _visiblePlan = false;

  @override
  void initState() {
    _visiblePlan = widget.showPlan;
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    await context.read<ProfileProvider>().loadProfile(context);
    final data = await UserProfileService().getUserProfile();
    _visiblePlan = data.subscriptions != null && data.subscriptions.isNotEmpty;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: CommonParentContainer(
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
                  Expanded(
                    child: Consumer<ProfileProvider>(
                      builder: (context, profileProvider, child) {
                        return _buildProfileSection(profileProvider);
                      },
                    ),
                  )
                ],
              ),
              Expanded(
                child: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
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
      ),
    );
  }

  Widget _buildProfileSection(ProfileProvider profileProvider) {
    final localizations = AppLocalizations.of(context)!;
    String displayName = profileProvider.fullName ?? "User";
    String userId = profileProvider.profileData?.id?.toString() ?? "";

    return InkWell(
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
          }
         else if (userType == 'INDEPENDENT_CAR_OWNER') {
            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => EditCarOwnerProfile(),
              ),
            );
          }
          else if (['E_RICKSHAW', 'RICKSHAW'].contains(userType)) {
            print(
                'User type is $userType, navigating to TransporterDriverProfileScreen');
            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    ERickshawOwnerProfile(userType: userType!),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
                image: profileProvider.profileData?.profilePhoto != null &&
                        profileProvider.profileData!.profilePhoto
                            .toString()
                            .isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(
                          profileProvider.profileData!.profilePhoto ?? '',
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
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
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: SvgPicture.asset(
                "assets/svg/share-profile.svg",
                width: 20,
                height: 20,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            CommonUtils.loadNextButton(isBlack: false),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
              visible: _visiblePlan,
              child: _buildMenuItem(
                icon: "assets/svg/plans.svg",
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
              visible: _visiblePlan,
              child: _buildMenuItem(
                icon: "assets/svg/ratings_review.svg",
                title: "Rating and Reviews",
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => MyRatingsScreen()),
                  );
                },
              ),
            ),
            _buildMenuItem(
              icon: "assets/svg/faqs.svg",
              title: localizations.faq,
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => FAQScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: "assets/svg/supports.svg",
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
              icon: "assets/svg/rate_app.svg",
              title: localizations.rate_our_app,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Coming Soon!')),
                );
              },
            ),
            _buildMenuItem(
              icon: "assets/svg/privacy_policy.svg",
              title: localizations.privacy_policy,
              onTap: () => showUserTerms("PRIVACY_POLICY"),
            ),
            _buildMenuItem(
              icon: "assets/svg/t_n_c.svg",
              title: localizations.terms_conditions,
              onTap: () => showUserTerms("TERMS_AND_CONDITIONS"),
            ),
            _buildMenuItem(
              icon: "assets/svg/about.svg",
              title: localizations.about_us,
              onTap: () => showUserTerms("ABOUT_US"),
            ),
            _buildMenuItem(
              icon: "assets/svg/settings.svg",
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
    required String icon,
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
                SvgPicture.asset(icon,width: 24,height: 24,),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style:  TextStyle(
                      fontFamily: AppConstants.ptSansFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                CommonUtils.loadNextButton(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 44),
          child: Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }
}
