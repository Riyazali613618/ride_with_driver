import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// API and BLoC imports
import 'package:r_w_r/api/api_service/api_repository.dart';
import 'package:r_w_r/api/api_service/countryStateProviderService.dart';
import 'package:r_w_r/bloc/auth/auth_bloc.dart';
import 'package:r_w_r/bloc/home/home_bloc.dart';
import 'package:r_w_r/bloc/user_profile/user_profile_bloc.dart';
import 'package:r_w_r/bloc/vehicle/vehicle_bloc.dart';
import 'package:r_w_r/bloc/chat/chat_bloc.dart';
import 'package:r_w_r/bloc/driver/driver_bloc.dart';
import 'package:r_w_r/bloc/payment/payment_bloc.dart';

// Screen and service imports
import 'package:r_w_r/api/api_service/user_service/user_profile_service.dart';
import 'package:r_w_r/firebase_options.dart';
import 'package:r_w_r/plan/data/repositories/plan_repository.dart';
import 'package:r_w_r/plan/presentation/bloc/plan_bloc.dart';
import 'package:r_w_r/screens/auth_screens/first_time_user.dart';
import 'package:r_w_r/screens/auth_screens/login_screen.dart';
import 'package:r_w_r/screens/auth_screens/otp_screen.dart';
import 'package:r_w_r/screens/auth_screens/splash_screen.dart';
import 'package:r_w_r/screens/autoRikshawDriverRegistration.dart';
import 'package:r_w_r/screens/block/home/home_provider.dart';
import 'package:r_w_r/screens/block/language/language_provider.dart';
import 'package:r_w_r/screens/block/provider/profile_provider.dart';
import 'package:r_w_r/screens/driverRegistrationScreen.dart';
import 'package:r_w_r/screens/driver_screens/dashbord.dart';
import 'package:r_w_r/screens/eRickshawRegistration.dart';
import 'package:r_w_r/screens/independentCarOwnerRegistration.dart';
import 'package:r_w_r/screens/registration_screens/indipendent_car_owner_registration_screen.dart';
import 'package:r_w_r/screens/transporterRegistration.dart';
import 'package:r_w_r/screens/vehicle/vehicleRegistrationScreen.dart';
import 'package:r_w_r/viewModel/profileViewModel.dart';

import 'api/api_service/notification_globle_service.dart';
import 'firebase_config.dart';
import 'l10n/app_localizations.dart'; // Generated file

// Global key for navigator (used for notifications)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (message.notification != null) {
    PushNotificationHandler.showNotification(message);
    print("Background message received: ${message.notification!.title}");
  }
}

Future<void> main() async {
  try {
    print("Starting app initialization...");

    WidgetsFlutterBinding.ensureInitialized();
    print("Flutter binding initialized");

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    print("Portrait mode orientation set");

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized");

    // Initialize push notifications
    try {
      await PushNotificationHandler.init();
      print("Push notifications initialized");
    } catch (e) {
      print("Push notifications initialization error: $e");
    }

    // Initialize notification service
    try {
      await NotificationService.initialize();
      print("Notification service initialized");
    } catch (e) {
      print("Notification service initialization error: $e");
    }

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
    print("Background message handler set");

    print("Running app...");
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print("Error during app initialization: $e");
    print("Stack trace: $stackTrace");
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('App Initialization Failed'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(error, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("Building MyApp...");

    // Create a single instance of ApiRepository to be shared across all BLoCs
    final apiRepository = ApiRepository();

    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (_) => PlanRepository()),
        ],
        child: MultiBlocProvider(
          providers: [
            // Provider dependencies first
            BlocProvider(
              create: (context) => PlanBloc(context.read<PlanRepository>()),
            ),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            Provider<UserProfileService>(create: (_) => UserProfileService()),
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
            ChangeNotifierProvider(create: (_) => HomeDataProvider()),
            ChangeNotifierProvider(create: (_) => ProfileViewModel()),
            ChangeNotifierProvider(
                create: (_) => VehicleRegistrationProvider()),
            ChangeNotifierProvider(create: (_) => LocationProvider()),

            // BLoC Providers that depend on providers
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(apiRepository: apiRepository),
            ),
            BlocProvider<HomeBloc>(
              create: (context) => HomeBloc(apiRepository: apiRepository),
            ),
            BlocProvider<UserProfileBloc>(
              create: (context) =>
                  UserProfileBloc(apiRepository: apiRepository),
            ),
            BlocProvider<VehicleBloc>(
              create: (context) => VehicleBloc(apiRepository: apiRepository),
            ),
            BlocProvider<ChatBloc>(
              create: (context) => ChatBloc(apiRepository: apiRepository),
            ),
            BlocProvider<DriverBloc>(
              create: (context) => DriverBloc(apiRepository: apiRepository),
            ),
            BlocProvider<PaymentBloc>(
              create: (context) => PaymentBloc(
                profileProvider:
                    Provider.of<ProfileProvider>(context, listen: false),
              ),
            ),
          ],
          child: Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              print(
                  "Rebuilding MaterialApp with locale: ${languageProvider.currentLocale}");

              return MaterialApp(
                scaffoldMessengerKey: rootScaffoldMessengerKey,

                title: 'Ride with Driver',
                debugShowCheckedModeBanner: false,
                navigatorKey: NotificationService.navigatorKey,

                locale: languageProvider.currentLocale,

                // Use the generated localization delegates
                localizationsDelegates: const [
                  AppLocalizations.delegate, // Generated delegate
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],

                // Make sure all your supported locales are listed here
                supportedLocales: AppLocalizations.supportedLocales,

                // Fallback locale
                localeResolutionCallback: (locale, supportedLocales) {
                  print("Resolving locale: $locale");
                  // Check if the current locale is supported
                  for (var supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == locale?.languageCode) {
                      return supportedLocale;
                    }
                  }
                  // Return English as fallback
                  return const Locale('en', '');
                },
                theme: ThemeData(
                  textTheme: GoogleFonts.notoSansTextTheme(),
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                    brightness: Brightness.light,
                  ),
                  useMaterial3: true,
                ),
                home: SplashScreen(),
              );
            },
          ),
        ));
  }
}
