// import 'dart:async';
// import 'dart:convert';
// import 'dart:math' as math;
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:r_w_r/constants/api_constants.dart';
// import 'package:r_w_r/screens/user_screens/user_profile_event.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:video_player/video_player.dart';
// import 'package:visibility_detector/visibility_detector.dart';
//
// import '../constants/color_constants.dart';
//
// class Language {
//   final String languageName;
//   final String image;
//   final String video;
//
//   Language({
//     required this.languageName,
//     required this.image,
//     required this.video,
//   });
//
//   factory Language.fromJson(Map<String, dynamic> json) {
//     return Language(
//       languageName: json['languageName'],
//       image: json['image'],
//       video: json['video'],
//     );
//   }
// }
//
// class PromotionalContent {
//   final String type; // 'video' or 'image'
//   final String url;
//   final String title;
//
//   PromotionalContent({
//     required this.type,
//     required this.url,
//     required this.title,
//   });
// }
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//   // Animation controllers
//   late AnimationController _pulseController;
//   late AnimationController _rotateController;
//   late AnimationController _fadeController;
//
//   // Animations
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _rotateAnimation;
//   late Animation<double> _fadeAnimation;
//
//   // Target date for countdown
//   final DateTime _targetDate = DateTime(2025, 5, 18);
//   late Timer _countdownTimer;
//
//   int _days = 0;
//   int _hours = 0;
//   int _minutes = 0;
//   int _seconds = 0;
//
//   // Language related variables
//   List<Language> _languages = [];
//   Language? _selectedLanguage;
//   bool _isLoading = true;
//   bool _hasError = false;
//   VideoPlayerController? _videoController;
//   bool _isDialogShown = false;
//   bool _isVideoInitialized = false;
//   bool _isVideoBuffering = false;
//
//   // Promotional content variables
//   final List<PromotionalContent> _promotionalContent = [
//     PromotionalContent(
//       type: 'video',
//       url:
//           'https://s3.ap-south-1.amazonaws.com/ride.with.driver/videos/Jayada-Kamai.mp4',
//       title: 'Earn More',
//     ),
//     PromotionalContent(
//       type: 'video',
//       url:
//           'https://s3.ap-south-1.amazonaws.com/ride.with.driver/videos/Kamai-Shuru.mp4',
//       title: 'Start Earning',
//     ),
//     PromotionalContent(
//       type: 'video',
//       url:
//           'https://s3.ap-south-1.amazonaws.com/ride.with.driver/videos/no-broker.mp4',
//       title: 'No Brokers',
//     ),
//     PromotionalContent(
//       type: 'video',
//       url:
//           'https://s3.ap-south-1.amazonaws.com/ride.with.driver/videos/Turist.mp4',
//       title: 'Tourist Services',
//     ),
//   ];
//
//   // Promotional video controllers
//   final Map<String, VideoPlayerController> _promoVideoControllers = {};
//   final Map<String, bool> _promoVideoInitialized = {};
//   final Map<String, bool> _promoVideoBuffering = {};
//   final Map<String, bool> _promoVideoVisible = {};
//
//   // Page controller for promotional content carousel
//   late PageController _promoPageController;
//   int _currentPromoIndex = 0;
//   Timer? _autoPlayTimer;
//
//   // Base URL for API
//   final String _baseUrl = ApiConstants.baseUrl;
//
//   // Cache for the video controllers
//   final Map<String, VideoPlayerController> _videoControllerCache = {};
//
//   // Currently playing video tracker
//   String? _currentlyPlayingVideo;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _setupAnimations();
//     _calculateTimeRemaining();
//
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       _calculateTimeRemaining();
//     });
//
//     // Initialize page controller for promotional content
//     _promoPageController = PageController(
//       initialPage: 0,
//       viewportFraction: 0.85,
//     );
//
//     // Fetch languages and check if a language has been previously selected
//     _fetchLanguages();
//
//     // Initialize promotional content
//     _initializePromotionalContent();
//
//     // Start auto-play timer for promotional content
//     _startAutoPlay();
//
//     // Fetch user profile data
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       BlocProvider.of<UserProfileBloc>(context).add(FetchUserProfile());
//     });
//   }
//
//   void _startAutoPlay() {
//     _autoPlayTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
//       if (_promoPageController.hasClients) {
//         final nextPage = (_currentPromoIndex + 1) % _promotionalContent.length;
//         _promoPageController.animateToPage(
//           nextPage,
//           duration: const Duration(milliseconds: 800),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }
//
//   void _initializePromotionalContent() {
//     // Pre-initialize all promotional video controllers
//     for (int i = 0; i < _promotionalContent.length; i++) {
//       final content = _promotionalContent[i];
//       if (content.type == 'video') {
//         _promoVideoInitialized[content.url] = false;
//         _promoVideoBuffering[content.url] = true;
//         _promoVideoVisible[content.url] = false;
//
//         // Create and initialize controller
//         final controller = VideoPlayerController.network(
//           content.url,
//           videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
//         );
//
//         _promoVideoControllers[content.url] = controller;
//
//         // Add listeners and initialize
//         controller.addListener(() {
//           _updatePromoVideoStatus(content.url);
//         });
//
//         controller.initialize().then((_) {
//           setState(() {
//             _promoVideoInitialized[content.url] = true;
//             _promoVideoBuffering[content.url] = false;
//           });
//         }).catchError((error) {
//           print('Error initializing promo video ${content.url}: $error');
//           setState(() {
//             _promoVideoBuffering[content.url] = false;
//           });
//         });
//       }
//     }
//   }
//
//   void _updatePromoVideoStatus(String url) {
//     if (_promoVideoControllers.containsKey(url) && mounted) {
//       final controller = _promoVideoControllers[url]!;
//       final isBuffering = controller.value.isBuffering;
//
//       if (_promoVideoBuffering[url] != isBuffering) {
//         setState(() {
//           _promoVideoBuffering[url] = isBuffering;
//         });
//       }
//
//       // Auto-restart video when it ends
//       if (controller.value.position >= controller.value.duration) {
//         controller.seekTo(Duration.zero);
//         controller.play();
//       }
//     }
//   }
//
//   Future<void> _fetchLanguages() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });
//
//     try {
//       // Add English language manually first
//       final english = Language(
//           languageName: "English",
//           image:
//               "https://s3.ap-south-1.amazonaws.com/ride.with.driver/images/English.jpg",
//           video:
//               "https://s3.ap-south-1.amazonaws.com/ride.with.driver/video/English.mp4");
//
//       // Fetch other languages from API
//       final response = await http.get(Uri.parse('$_baseUrl/info/temp'));
//
//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         if (jsonData['status'] == true) {
//           final List<dynamic> data = jsonData['data'];
//           _languages = data.map((item) => Language.fromJson(item)).toList();
//
//           // Add English at the beginning of the list
//           _languages.insert(0, english);
//
//           // Check for previously selected language
//           final prefs = await SharedPreferences.getInstance();
//           final savedLanguage = prefs.getString('selectedLanguage');
//
//           if (savedLanguage != null) {
//             final lang = _languages.firstWhere(
//               (lang) => lang.languageName == savedLanguage,
//               orElse: () => english,
//             );
//             _selectedLanguage = lang;
//             await _initializeVideoPlayer();
//           } else {
//             // If no saved language, show dialog after a short delay
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               if (!_isDialogShown && mounted) {
//                 _showLanguageSelectionDialog();
//                 _isDialogShown = true;
//               }
//             });
//             _selectedLanguage = english; // Default to English
//             await _initializeVideoPlayer();
//           }
//
//           // Pre-cache other language videos in the background
//           _precacheOtherLanguageVideos();
//         } else {
//           throw Exception('Failed to load languages: ${jsonData['message']}');
//         }
//       } else {
//         throw Exception('Failed to load languages');
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//         });
//       }
//       print('Error fetching languages: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   void _precacheOtherLanguageVideos() {
//     // Pre-cache videos for all languages (limit to first 3 to avoid too much network usage)
//     final languagesToCache = _languages.take(3).toList();
//     for (final language in languagesToCache) {
//       if (_selectedLanguage?.languageName != language.languageName) {
//         final controller = VideoPlayerController.network(
//           language.video,
//           videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
//         );
//         _videoControllerCache[language.languageName] = controller;
//         controller.initialize();
//       }
//     }
//   }
//
//   void _selectLanguage(Language language) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selectedLanguage', language.languageName);
//
//     setState(() {
//       _selectedLanguage = language;
//       _isVideoInitialized = false;
//       _isVideoBuffering = true;
//     });
//
//     await _initializeVideoPlayer();
//   }
//
//   // Stop all videos except the one with the given URL
//   void _pauseAllVideosExcept(String videoUrl) {
//     // If the current video is already playing, don't do anything
//     if (_currentlyPlayingVideo == videoUrl) return;
//
//     // Otherwise, pause all videos and set this as the current one
//     _currentlyPlayingVideo = videoUrl;
//
//     // Pause main language video if it's not the one being played
//     if (_videoController != null &&
//         _videoController!.value.isInitialized &&
//         _selectedLanguage?.video != videoUrl) {
//       _videoController!.pause();
//     }
//
//     // Pause all promotional videos except the one being played
//     for (final entry in _promoVideoControllers.entries) {
//       if (entry.key != videoUrl && entry.value.value.isInitialized) {
//         entry.value.pause();
//       }
//     }
//   }
//
//   Future<void> _initializeVideoPlayer() async {
//     // Check if we already have this video cached
//     if (_videoControllerCache.containsKey(_selectedLanguage?.languageName)) {
//       if (_videoController != null && _videoController!.value.isInitialized) {
//         await _videoController!.pause();
//       }
//
//       _videoController = _videoControllerCache[_selectedLanguage!.languageName];
//
//       if (mounted) {
//         setState(() {
//           _isVideoInitialized = _videoController!.value.isInitialized;
//           _isVideoBuffering = !_isVideoInitialized;
//         });
//
//         if (!_isVideoInitialized) {
//           await _videoController!.initialize();
//           if (mounted) {
//             setState(() {
//               _isVideoInitialized = true;
//               _isVideoBuffering = false;
//             });
//           }
//         }
//
//         // Setup buffering listener
//         _videoController!.addListener(_videoListener);
//       }
//       return;
//     }
//
//     if (_videoController != null) {
//       _videoController!.removeListener(_videoListener);
//       await _videoController!.pause();
//     }
//
//     if (_selectedLanguage != null) {
//       setState(() {
//         _isVideoBuffering = true;
//       });
//
//       // Create new controller with optimized settings
//       _videoController = VideoPlayerController.network(
//         _selectedLanguage!.video,
//         videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
//       );
//
//       // Add buffering listener
//       _videoController!.addListener(_videoListener);
//
//       try {
//         await _videoController!.initialize();
//         _videoController!.setLooping(true);
//
//         // Cache the controller
//         _videoControllerCache[_selectedLanguage!.languageName] =
//             _videoController!;
//
//         if (mounted) {
//           setState(() {
//             _isVideoInitialized = true;
//             _isVideoBuffering = false;
//           });
//         }
//       } catch (e) {
//         print('Error initializing video: $e');
//         if (mounted) {
//           setState(() {
//             _hasError = true;
//             _isVideoBuffering = false;
//           });
//         }
//       }
//     }
//   }
//
//   void _videoListener() {
//     if (_videoController != null && mounted) {
//       final bool isBuffering = _videoController!.value.isBuffering;
//       if (_isVideoBuffering != isBuffering) {
//         setState(() {
//           _isVideoBuffering = isBuffering;
//         });
//       }
//     }
//   }
//
//   void _showLanguageSelectionDialog() {
//     if (!mounted) return;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false, // User must pick a language
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   spreadRadius: 5,
//                   blurRadius: 15,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Select Your Language',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: ColorConstants.black,
//                     letterSpacing: 1.5,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Container(
//                   constraints: BoxConstraints(
//                     maxHeight: MediaQuery.of(context).size.height * 0.6,
//                   ),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       childAspectRatio: 1.0,
//                       crossAxisSpacing: 15,
//                       mainAxisSpacing: 15,
//                     ),
//                     itemCount: _languages.length,
//                     itemBuilder: (context, index) {
//                       final language = _languages[index];
//                       return GestureDetector(
//                         onTap: () {
//                           _selectLanguage(language);
//                           Navigator.of(context).pop();
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(15),
//                             border: Border.all(
//                               color: ColorConstants.black.withOpacity(0.3),
//                               width: 2,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.2),
//                                 blurRadius: 10,
//                               ),
//                             ],
//                           ),
//                           clipBehavior: Clip.antiAlias,
//                           child: Stack(
//                             fit: StackFit.expand,
//                             children: [
//                               CachedNetworkImage(
//                                 imageUrl: language.image,
//                                 fit: BoxFit.cover,
//                                 placeholder: (context, url) => Container(
//                                   color: Colors.grey[800],
//                                   child: const Center(
//                                     child: CircularProgressIndicator(
//                                       color: ColorConstants.black,
//                                     ),
//                                   ),
//                                 ),
//                                 errorWidget: (context, url, error) => Container(
//                                   color: Colors.grey[800],
//                                   child: const Icon(
//                                     Icons.image_not_supported,
//                                     color: ColorConstants.black,
//                                     size: 40,
//                                   ),
//                                 ),
//                               ),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     begin: Alignment.topCenter,
//                                     end: Alignment.bottomCenter,
//                                     colors: [
//                                       Colors.transparent,
//                                       Colors.black.withOpacity(0.7),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 10,
//                                 left: 10,
//                                 right: 10,
//                                 child: Text(
//                                   language.languageName,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _setupAnimations() {
//     // Pulse animation for the main circle
//     _pulseController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//
//     // Rotation animation for decorative elements
//     _rotateController = AnimationController(
//       duration: const Duration(seconds: 20),
//       vsync: this,
//     )..repeat();
//
//     _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
//       CurvedAnimation(parent: _rotateController, curve: Curves.linear),
//     );
//
//     // Fade animation for text
//     _fadeController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _fadeAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );
//   }
//
//   void _calculateTimeRemaining() {
//     final now = DateTime.now();
//     final difference = _targetDate.difference(now);
//
//     if (!mounted) return;
//
//     setState(() {
//       _days = difference.inDays;
//       _hours = difference.inHours % 24;
//       _minutes = difference.inMinutes % 60;
//       _seconds = difference.inSeconds % 60;
//     });
//   }
//
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _rotateController.dispose();
//     _fadeController.dispose();
//     _countdownTimer.cancel();
//     _autoPlayTimer?.cancel();
//     _promoPageController.dispose();
//
//     // Remove listeners and dispose all video controllers
//     if (_videoController != null) {
//       _videoController!.removeListener(_videoListener);
//       _videoController!.dispose();
//     }
//
//     for (final controller in _videoControllerCache.values) {
//       controller.dispose();
//     }
//     _videoControllerCache.clear();
//
//     // Dispose all promotional video controllers
//     for (final controller in _promoVideoControllers.values) {
//       controller.dispose();
//     }
//     _promoVideoControllers.clear();
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorConstants.white,
//       body: Container(
//         decoration: BoxDecoration(color: ColorConstants.white),
//         child: Stack(
//           children: [
//             // Main content
//             SafeArea(
//               child: Center(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const SizedBox(height: 10),
//                       _buildCountdownTimer(),
//                       const SizedBox(height: 20),
//                       _buildComingSoonText(),
//                       const SizedBox(height: 10),
//                       _buildLanguageSelector(),
//                       const SizedBox(height: 10),
//                       _buildVideoPlayer(),
//                       const SizedBox(height: 20),
//                       CachedNetworkImage(
//                         imageUrl:
//                             "https://s3.ap-south-1.amazonaws.com/ride.with.driver/images/BantiBhai.png",
//                         fit: BoxFit.contain,
//                         placeholder: (context, url) => Container(
//                           color: Colors.grey[300],
//                           child: const Center(
//                             child: CircularProgressIndicator(
//                               color: ColorConstants.primaryColor,
//                             ),
//                           ),
//                         ),
//                         errorWidget: (context, url, error) => Container(
//                           color: Colors.grey[300],
//                           child: const Icon(
//                             Icons.error_outline,
//                             color: Colors.red,
//                             size: 40,
//                           ),
//                         ),
//                       ),
//                       _buildPromotionalCarousel(),
//                       const SizedBox(height: 30),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPromotionalCarousel() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           child: Text(
//             'More Information',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.black.withOpacity(0.9),
//               letterSpacing: 1.2,
//             ),
//           ),
//         ),
//         // Replace ListView.builder with Column + List.generate to avoid nested scrolling issues
//         Column(
//           children: List.generate(
//             _promotionalContent.length,
//             (index) {
//               final content = _promotionalContent[index];
//               return Container(
//                 height: 220, // Set fixed height for each content item
//                 margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(1),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 10,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(1),
//                   child: _buildPromotionalContentItem(content, index),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPromotionalContentItem(PromotionalContent content, int index) {
//     if (content.type == 'image') {
//       return Stack(
//         fit: StackFit.expand,
//         children: [
//           CachedNetworkImage(
//             imageUrl: content.url,
//             fit: BoxFit.contain,
//             height: 500,
//             placeholder: (context, url) => Container(
//               color: Colors.grey[300],
//               child: const Center(
//                 child: CircularProgressIndicator(
//                   color: ColorConstants.primaryColor,
//                 ),
//               ),
//             ),
//             errorWidget: (context, url, error) => Container(
//               color: Colors.grey[300],
//               child: const Icon(
//                 Icons.error_outline,
//                 color: Colors.red,
//                 size: 40,
//               ),
//             ),
//           ),
//           // Text overlay at the bottom
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter,
//                   colors: [
//                     Colors.black.withOpacity(0.8),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//               child: Text(
//                 content.title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         ],
//       );
//     } else if (content.type == 'video') {
//       return VisibilityDetector(
//         key: Key('promo-video-${content.url}'),
//         onVisibilityChanged: (info) {
//           final isVisible = info.visibleFraction > 0.7;
//           _promoVideoVisible[content.url] = isVisible;
//
//           if (_promoVideoControllers.containsKey(content.url) &&
//               _promoVideoInitialized[content.url] == true) {
//             final controller = _promoVideoControllers[content.url]!;
//
//             // Don't autoplay - only update the visibility status
//             if (!isVisible && controller.value.isPlaying) {
//               controller.pause();
//             }
//           }
//         },
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             // Show thumbnail or video
//             if (!_promoVideoInitialized[content.url]!)
//               Container(
//                 color: Colors.black87,
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     color: ColorConstants.primaryColor,
//                   ),
//                 ),
//               )
//             else
//               AspectRatio(
//                 aspectRatio:
//                     _promoVideoControllers[content.url]!.value.aspectRatio,
//                 child: VideoPlayer(_promoVideoControllers[content.url]!),
//               ),
//
//             // Buffering indicator
//             if (_promoVideoBuffering[content.url] == true)
//               Center(
//                 child: Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.5),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const CircularProgressIndicator(
//                     color: ColorConstants.primaryColor,
//                     strokeWidth: 3,
//                   ),
//                 ),
//               ),
//
//             // Play/Pause button
//             Positioned.fill(
//               child: GestureDetector(
//                 onTap: () {
//                   if (_promoVideoControllers.containsKey(content.url) &&
//                       _promoVideoInitialized[content.url] == true) {
//                     final controller = _promoVideoControllers[content.url]!;
//
//                     if (controller.value.isPlaying) {
//                       controller.pause();
//                       _currentlyPlayingVideo = null;
//                     } else {
//                       // Pause all other videos first
//                       _pauseAllVideosExcept(content.url);
//                       // Then play this one
//                       controller.play();
//                     }
//
//                     setState(() {});
//                   }
//                 },
//                 child: _promoVideoInitialized[content.url] == true
//                     ? AnimatedOpacity(
//                         opacity: _promoVideoControllers[content.url]!
//                                     .value
//                                     .isPlaying &&
//                                 !_promoVideoBuffering[content.url]!
//                             ? 0.0
//                             : 1.0,
//                         duration: const Duration(milliseconds: 300),
//                         child: Container(
//                           color: Colors.transparent,
//                           child: Center(
//                             child: Container(
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 color: ColorConstants.primaryColor
//                                     .withOpacity(0.7),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Icon(
//                                 _promoVideoControllers[content.url]!
//                                         .value
//                                         .isPlaying
//                                     ? Icons.pause
//                                     : Icons.play_arrow,
//                                 color: Colors.white,
//                                 size: 30,
//                               ),
//                             ),
//                           ),
//                         ),
//                       )
//                     : Container(),
//               ),
//             ),
//
//             // Video progress indicator
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                     colors: [
//                       Colors.black.withOpacity(0.8),
//                       Colors.transparent,
//                     ],
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (_promoVideoInitialized[content.url] == true)
//                       VideoProgressIndicator(
//                         _promoVideoControllers[content.url]!,
//                         allowScrubbing: true,
//                         colors: const VideoProgressColors(
//                           playedColor: ColorConstants.primaryColor,
//                           bufferedColor: Colors.white54,
//                           backgroundColor: Colors.grey,
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 0),
//                       ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 5),
//                       child: Text(
//                         content.title,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     } else {
//       return Container(
//         color: Colors.grey[300],
//         child: const Center(
//           child: Text('Unsupported content type'),
//         ),
//       );
//     }
//   }
//
//   Widget _buildLanguageSelector() {
//     return GestureDetector(
//       onTap: _showLanguageSelectionDialog,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
//         decoration: BoxDecoration(
//           color: ColorConstants.black.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(30),
//           border: Border.all(
//             color: ColorConstants.black.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.language,
//               color: ColorConstants.black.withOpacity(0.9),
//               size: 20,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               _selectedLanguage?.languageName ?? 'Select Language',
//               style: TextStyle(
//                 color: ColorConstants.black.withOpacity(0.9),
//                 fontWeight: FontWeight.w500,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Icon(
//               Icons.arrow_drop_down,
//               color: ColorConstants.black.withOpacity(0.9),
//               size: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildVideoPlayer() {
//     if (_isLoading) {
//       return Container(
//         width: double.infinity,
//         height: 250,
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(1),
//         ),
//         child: const Center(
//           child: CircularProgressIndicator(
//             color: ColorConstants.black,
//           ),
//         ),
//       );
//     }
//
//     if (_hasError) {
//       return Container(
//         width: double.infinity,
//         height: 250,
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(1),
//         ),
//         child: const Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.error_outline,
//                 color: ColorConstants.black,
//                 size: 40,
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Failed to load video',
//                 style: TextStyle(
//                   color: ColorConstants.black,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     if (_videoController == null || !_isVideoInitialized) {
//       return Container(
//         width: double.infinity,
//         height: 200,
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(1),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const CircularProgressIndicator(
//                 color: ColorConstants.black,
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "Loading video...",
//                 style: TextStyle(
//                   color: ColorConstants.black.withOpacity(0.9),
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return Card(
//       elevation: 10,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(1),
//       ),
//       clipBehavior: Clip.antiAlias,
//       margin: const EdgeInsets.symmetric(horizontal: 1),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               AspectRatio(
//                 aspectRatio: _videoController!.value.aspectRatio,
//                 child: VideoPlayer(_videoController!),
//               ),
//               if (_isVideoBuffering)
//                 Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.5),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const CircularProgressIndicator(
//                     color: ColorConstants.black,
//                     strokeWidth: 3,
//                   ),
//                 ),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     if (_videoController!.value.isPlaying) {
//                       _videoController!.pause();
//                     } else {
//                       // Pause all other videos first
//                       _pauseAllVideosExcept(_selectedLanguage!.video);
//                       // Then play this one
//                       _videoController!.play();
//                     }
//                   });
//                 },
//                 child: AnimatedOpacity(
//                   opacity:
//                       _videoController!.value.isPlaying && !_isVideoBuffering
//                           ? 0.0
//                           : 1.0,
//                   duration: const Duration(milliseconds: 300),
//                   child: Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.purple.withOpacity(0.7),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       _videoController!.value.isPlaying
//                           ? Icons.pause
//                           : Icons.play_arrow,
//                       color: ColorConstants.black,
//                       size: 30,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Container(
//             padding: const EdgeInsets.all(12),
//             color: Colors.black.withOpacity(0.7),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 VideoProgressIndicator(
//                   _videoController!,
//                   allowScrubbing: true,
//                   colors: const VideoProgressColors(
//                     playedColor: Colors.purple,
//                     bufferedColor: Colors.purple,
//                     backgroundColor: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildComingSoonText() {
//     return BlocBuilder<UserProfileBloc, UserProfileState>(
//       builder: (context, state) {
//         return FadeTransition(
//           opacity: _fadeAnimation,
//           child: Column(
//             children: [
//               const Text(
//                 'Congratulation',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: ColorConstants.primaryColor,
//                   letterSpacing: 4,
//                 ),
//               ),
//               if (state is UserProfileLoaded)
//                 Text(
//                   '${state.userData.firstName} ${state.userData.lastName}',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: ColorConstants.primaryColor,
//                   ),
//                 ),
//               const Text(
//                 'You have Successfully Registered',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: ColorConstants.primaryColorLight,
//                   letterSpacing: 1,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildCountdownTimer() {
//     return Column(
//       children: [
//         const Text(
//           'LAUNCHING ON MAY 18, 2025',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: ColorConstants.black,
//             letterSpacing: 2,
//           ),
//         ),
//         SizedBox(height: 20),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 0),
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               // Adjust the countdown UI based on available width
//               final isSmallScreen = constraints.maxWidth < 400;
//               final countdownSeparatorWidth = isSmallScreen ? 0.0 : 10.0;
//
//               return Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 spacing: 1,
//                 children: [
//                   _buildCountdownUnit(_days.toString().padLeft(3, ' '), 'DAYS'),
//                   SizedBox(width: countdownSeparatorWidth),
//                   _buildCountdownSeparator(),
//                   SizedBox(width: countdownSeparatorWidth),
//                   _buildCountdownUnit(
//                       _hours.toString().padLeft(2, '0'), 'HOURS'),
//                   SizedBox(width: countdownSeparatorWidth),
//                   _buildCountdownSeparator(),
//                   SizedBox(width: countdownSeparatorWidth),
//                   _buildCountdownUnit(
//                       _minutes.toString().padLeft(2, '0'), 'MINUTES'),
//                   SizedBox(width: countdownSeparatorWidth),
//                   _buildCountdownSeparator(),
//                   SizedBox(width: countdownSeparatorWidth),
//                   _buildCountdownUnit(
//                       _seconds.toString().padLeft(2, '0'), 'SECONDS'),
//                 ],
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCountdownUnit(String value, String label) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Adjust the font size based on available width
//         final fontSize = constraints.maxWidth < 400 ? 20.0 : 24.0;
//         final padding = constraints.maxWidth < 400 ? 10.0 : 15.0;
//
//         return Column(
//           children: [
//             Container(
//               padding:
//                   EdgeInsets.symmetric(horizontal: padding, vertical: padding),
//               decoration: BoxDecoration(
//                 color: ColorConstants.primaryColor,
//                 borderRadius: BorderRadius.circular(5),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     spreadRadius: 1,
//                     blurRadius: 3,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: fontSize,
//                   fontWeight: FontWeight.bold,
//                   color: ColorConstants.white,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 10,
//                 color: ColorConstants.black.withOpacity(0.7),
//                 letterSpacing: 1,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildCountdownSeparator() {
//     return const Text(
//       ' ',
//       style: TextStyle(
//         fontSize: 24,
//         fontWeight: FontWeight.bold,
//         color: ColorConstants.primaryColor,
//       ),
//     );
//   }
//
//   Widget _buildPulsatingCircle() {
//     return AnimatedBuilder(
//       animation: _pulseAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _pulseAnimation.value,
//           child: SizedBox(
//             width: 100,
//             height: 100,
//             child: Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.transparent,
//                 border: Border.all(
//                   color: ColorConstants.black.withOpacity(0.5),
//                   width: 2,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.purple.withOpacity(0.3),
//                     spreadRadius: 5,
//                     blurRadius: 20,
//                   ),
//                 ],
//               ),
//               child: Center(
//                 child: AnimatedBuilder(
//                   animation: _rotateAnimation,
//                   builder: (context, child) {
//                     return Transform.rotate(
//                       angle: _rotateAnimation.value,
//                       child: Container(
//                         width: 150,
//                         height: 150,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           gradient: RadialGradient(
//                             colors: [
//                               ColorConstants.black.withOpacity(0.2),
//                               Colors.purple.withOpacity(0.6),
//                             ],
//                           ),
//                         ),
//                         child: Center(
//                           child: Icon(
//                             Icons.access_time_filled_rounded,
//                             size: 70,
//                             color: ColorConstants.black.withOpacity(0.9),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
