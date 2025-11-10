import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:r_w_r/screens/auth_screens/select_language_screen.dart';
import 'package:r_w_r/screens/layout.dart';
import 'package:r_w_r/screens/user_screens/user_home_new.dart';

import '../../constants/assets_constant.dart';
import '../../constants/color_constants.dart';
import '../../constants/token_manager.dart';
import '../../utils/color.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isCheckingAuth = true;
  bool _hasNavigated = false; // Prevent multiple navigations

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Show splash for at least 2 seconds
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)),
        _checkAuthenticationStatus(),
      ]);

      if (!mounted || _hasNavigated) return;
      final isLoggedIn = await TokenManager.isLoggedIn();
      if (kDebugMode) {
        print("User authentication status: $isLoggedIn");
        final token = await TokenManager.getToken();
        final userData = await TokenManager.getUserData();
        print("Auth token: $token");
        print("User data: $userData");
      }
      print("isLoggedIn:${isLoggedIn}");
      final isFirstTime=await TokenManager.isFirstTimeUser();

      _hasNavigated = true;

      // Navigate based on authentication status
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Layout()),
        );
      } else {
        if(isFirstTime){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        }else{
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LanguageSelectionScreen()),
          );
        }

      }
    } catch (e) {
      if (kDebugMode) {
        print("Error during app initialization: $e");
      }

      if (mounted && !_hasNavigated) {
        _hasNavigated = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    // Additional auth validation logic can go here
    // For example, verify token with server if needed
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:[
              gradientFirst,
              gradientSecond,
              gradientThird,
              Colors.white
            ],
            stops: [0.0, 0.15, 0.30, .90],
          ),
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/logo1.svg',
                        height: 120,
                      ),
                      SvgPicture.asset(
                        'assets/svg/logo2.svg',
                        height: 120,
                      ),
                    ],
                  )

                ),
              ),
              if (_isCheckingAuth)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
