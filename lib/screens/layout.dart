import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/api/api_service/verify_otp_service.dart';
import 'package:r_w_r/constants/token_manager.dart';
import 'package:r_w_r/screens/favoriteScreen.dart';
import 'package:r_w_r/screens/user_screens/PartnerRegistrationWidget.dart';
import 'package:r_w_r/screens/user_screens/more/more_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:r_w_r/screens/user_screens/user_home_new.dart';

import '../constants/api_constants.dart';
import '../constants/color_constants.dart';
import '../l10n/app_localizations.dart';
import 'block/home/home_provider.dart';
import 'driver_screens/active_plans.dart';
import 'driver_screens/dashbord.dart';
import 'user_screens/chat/chat_history_list.dart';

class Layout extends StatefulWidget {
  final int initialIndex;
  final bool isFirstTime;

   const Layout({
    super.key,
    this.initialIndex = 0, this.isFirstTime=false,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  late int _index;
  bool _isLoading = true;
  bool _isDisposed = false;
  bool _hasError = false;
  String _errorMessage = '';
  ErrorType _errorType = ErrorType.unknown;
  DateTime? _lastPressed;

  final ChatListController _chatListController = ChatListController();
  VerifyOtpService _verifyOtpService = VerifyOtpService();

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    refreshToken();
  }

  String? accessToken;

  Future<void> refreshToken() async {
    String? refershToken = await TokenManager.getRefreshToken();
    if (refershToken != null) {
      accessToken = await _verifyOtpService.refershTokenApi(refershToken);
      await TokenManager.saveToken(accessToken!);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _initializeData();
    }
  }

  Future<bool> _checkInternetConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Double check with actual internet connection
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _initializeData() async {
    if (!_isLoading || !mounted) return;

    try {
      // Check internet connectivity first
      final hasInternet = await _checkInternetConnectivity();
      if (!hasInternet) {
        if (!_isDisposed && mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorType = ErrorType.noInternet;
            _errorMessage = 'No internet connection available';
          });
        }
        return;
      }

      final provider = Provider.of<HomeDataProvider>(context, listen: false);
      await provider.fetchHomeData();

      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();

          // Determine error type based on the error
          if (e.toString().contains('502') ||
              e.toString().contains('Bad Gateway')) {
            _errorType = ErrorType.serverError;
          } else if (e.toString().contains('SocketException') ||
              e.toString().contains('NetworkError') ||
              e.toString().contains('Connection failed')) {
            _errorType = ErrorType.networkError;
          } else if (e.toString().contains('TimeoutException') ||
              e.toString().contains('timeout')) {
            _errorType = ErrorType.timeout;
          } else {
            _errorType = ErrorType.apiError;
          }
        });
      }
      debugPrint('Error initializing data: $e');
    }
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    await _initializeData();
  }

  List<Widget> _getPages(bool showDashboard) {
    if (showDashboard) {
      return [
        // const TransportApp(showDriverSubscription: false),
        UserHomeNewScreen(
          showDriverSubscription: false,
          isFirstTime: widget.isFirstTime,
        ),
        const DashboardScreen(),
        // PartnerRegistrationWidget(),
        ChatListScreen(controller: _chatListController),
        const MoreScreen(showDriverSubscription: false),
      ];
    }
    return [
      UserHomeNewScreen(
        showDriverSubscription: true,
      ),
      // const TransportApp(showDriverSubscription: true),
      //  PartnerRegistrationWidget(),
      FavoriteScreen(),
      /*SubscriptionsScreen(
        baseUrl: ApiConstants.baseUrl,
      ),*/
      ChatListScreen(controller: _chatListController),
      const MoreScreen(showDriverSubscription: true),
    ];
  }

  List<BottomNavigationBarItem> _getNavigationItems(bool showDashboard) {
    final localizations = AppLocalizations.of(context)!;

    if (showDashboard) {
      return [
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.home, color: Colors.black),
          label: localizations.explore,
          activeIcon: Icon(CupertinoIcons.house_fill,
              color: ColorConstants.primaryColor),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite_border, color: Colors.black),
          label: 'Favorite',
          activeIcon:
              Icon(Icons.favorite_border, color: ColorConstants.primaryColor),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_outlined, color: Colors.black),
          label: localizations.dashboard,
          activeIcon: Icon(Icons.dashboard, color: ColorConstants.primaryColor),
        ),
        // BottomNavigationBarItem(
        //   icon: const Icon(Icons.handshake_outlined, color: Colors.black),
        //   label: localizations.partner,
        //   activeIcon: Icon(Icons.handshake, color: ColorConstants.primaryColor),
        // ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.message_outlined, color: Colors.black),
          label: localizations.message,
          activeIcon: Icon(Icons.message, color: ColorConstants.primaryColor),
        ),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.profile_circled, color: Colors.black),
          label: localizations.profile,
          activeIcon: Icon(CupertinoIcons.profile_circled,
              color: ColorConstants.primaryColor),
        ),
      ];
    }
    return [
      BottomNavigationBarItem(
        icon: const Icon(CupertinoIcons.home, color: Colors.black),
        label: localizations.home,
        activeIcon:
            Icon(CupertinoIcons.house_fill, color: ColorConstants.primaryColor),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.favorite_border, color: Colors.black),
        label: 'Favorite',
        activeIcon:
            Icon(Icons.favorite_border, color: ColorConstants.primaryColor),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.message_outlined, color: Colors.black),
        label: localizations.message,
        activeIcon: Icon(Icons.message, color: ColorConstants.primaryColor),
      ),
      BottomNavigationBarItem(
        icon: const Icon(CupertinoIcons.profile_circled, color: Colors.black),
        label: localizations.profile,
        activeIcon: Icon(CupertinoIcons.profile_circled,
            color: ColorConstants.primaryColor),
      ),
    ];
  }

  void _onItemTapped(int index, List<Widget> pages) {
    if (!mounted) return;

    final chatTabIndex = pages.length == 5 ? 3 : 2;
    if (index == chatTabIndex && _index != chatTabIndex) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _chatListController.refresh();
      });
    }

    setState(() {
      _index = index;
    });
  }

  Future<bool> _handleBackPress() async {
    final localizations = AppLocalizations.of(context)!;

    if (_index != 0) {
      setState(() {
        _index = 0;
      });
      return false;
    }

    final now = DateTime.now();
    const exitTimeGap = Duration(seconds: 2);

    if (_lastPressed == null || now.difference(_lastPressed!) > exitTimeGap) {
      _lastPressed = now;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.press_back_again_to_exit),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    } else {
      SystemNavigator.pop();
      return true;
    }
  }

  Widget _buildErrorScreen() {
    final localizations = AppLocalizations.of(context)!;

    String title;
    String message;
    IconData icon;
    Color iconColor;

    switch (_errorType) {
      case ErrorType.noInternet:
        title = localizations.no_internet_connection;
        message = localizations.check_internet_connection;
        icon = Icons.wifi_off;
        iconColor = Colors.orange;
        break;
      case ErrorType.serverError:
        title = localizations.server_error;
        message = localizations.server_unavailable_message;
        icon = Icons.error_outline;
        iconColor = Colors.red;
        break;
      case ErrorType.networkError:
        title = localizations.networkError;
        message = localizations.unable_to_connect_server;
        icon = Icons.signal_wifi_connected_no_internet_4;
        iconColor = Colors.orange;
        break;
      case ErrorType.timeout:
        title = localizations.request_timeout;
        message = localizations.request_timeout_message;
        icon = Icons.timer_off;
        iconColor = Colors.amber;
        break;
      case ErrorType.apiError:
        title = localizations.api_error;
        message = localizations.api_error_message;
        icon = Icons.api;
        iconColor = Colors.red;
        break;
      default:
        title = localizations.something_went_wrong;
        message = localizations.unexpected_error_message;
        icon = Icons.error;
        iconColor = Colors.red;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: iconColor,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _retryInitialization,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ColorConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_hasError) {
      return _buildErrorScreen();
    }

    return Consumer<HomeDataProvider>(
      builder: (context, provider, child) {
        final pages = _getPages(provider.showDashboard);
        final navigationItems = _getNavigationItems(provider.showDashboard);

        if (_index >= pages.length) {
          _index = 0;
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _handleBackPress();
          },
          child: Scaffold(
            body: IndexedStack(
              index: _index,
              children: pages,
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: ColorConstants.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorConstants.black.withOpacity(0.3),
                    spreadRadius: 6,
                    blurRadius: 8,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
                child: BottomNavigationBar(
                  items: navigationItems,
                  currentIndex: _index,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: ColorConstants.primaryColor,
                  unselectedItemColor: Colors.black,
                  onTap: (index) => _onItemTapped(index, pages),
                  elevation: 0,
                  showUnselectedLabels: true,
                  selectedFontSize: 14,
                  selectedIconTheme: const IconThemeData(size: 28),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum ErrorType {
  noInternet,
  serverError,
  networkError,
  timeout,
  apiError,
  unknown,
}
