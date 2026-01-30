import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// API and BLoC imports
import 'package:rwd/api/api_service/api_repository.dart';
import 'package:rwd/api/api_service/countryStateProviderService.dart';
// Screen and service imports
import 'package:rwd/api/api_service/user_service/user_profile_service.dart';
import 'package:rwd/bloc/auth/auth_bloc.dart';
import 'package:rwd/bloc/chat/chat_bloc.dart';
import 'package:rwd/bloc/driver/driver_bloc.dart';
import 'package:rwd/bloc/home/home_bloc.dart';
import 'package:rwd/bloc/payment/payment_bloc.dart';
import 'package:rwd/bloc/user_profile/user_profile_bloc.dart';
import 'package:rwd/bloc/vehicle/vehicle_bloc.dart';
import 'package:rwd/features/upgradeablePlans/upgradeable_plans_bloc.dart';
import 'package:rwd/features/vehicles/presentation/pages/add_new_vehicle_screen.dart';
import 'package:rwd/firebase_options.dart';
import 'package:rwd/plan/data/repositories/plan_repository.dart';
import 'package:rwd/plan/presentation/bloc/plan_bloc.dart';
import 'package:rwd/screens/Eligibility/bloc/eligibility_bloc.dart';
import 'package:rwd/screens/Eligibility/bloc/eligibility_event.dart';
import 'package:rwd/screens/Eligibility/eligibility_remote_source.dart';
import 'package:rwd/screens/Eligibility/eligibility_repository.dart';
import 'package:rwd/screens/auth_screens/splash_screen.dart';
import 'package:rwd/screens/block/home/home_provider.dart';
import 'package:rwd/screens/block/language/language_provider.dart';
import 'package:rwd/screens/block/provider/profile_provider.dart';
import 'package:rwd/screens/dashboard/dashboard_bloc.dart';
import 'package:rwd/viewModel/profileViewModel.dart';

import 'api/api_service/notification_globle_service.dart';
import 'booking/data/repository/mock_repository.dart';
import 'booking/presentation/bloc/make_booking_bloc.dart';
import 'booking/presentation/bloc/manage_booking_bloc.dart';
import 'features/newDashboard/dashboard_api_service.dart';
import 'features/newDashboard/dashboard_repository.dart';
import 'features/vehicles/data/datasources/vehicle_remote_datasource.dart';
import 'features/vehicles/data/repositories/vehicle_repository_impl.dart';
import 'features/vehicles/domain/usecases/get_vehicles_usecase.dart';
import 'features/vehicles/presentation/bloc/vehicle_list_bloc.dart';
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

/*class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}*/

Future<void> main() async {
  try {
    print("Starting app initialization...");

    WidgetsFlutterBinding.ensureInitialized();
    print("Flutter binding initialized");
    // HttpOverrides.global = MyHttpOverrides();

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

    final vehicleRemoteDatasource = VehicleRemoteDatasourceImpl();

    final vehicleRepository = VehicleRepositoryImpl(vehicleRemoteDatasource);

    final getVehiclesUseCase = GetVehiclesUseCase(vehicleRepository);
    final eligibilityRepository = EligibilityRepository(
      EligibilityRemoteSource(http.Client()),
    );
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (_) => PlanRepository()),
          BlocProvider<EligibilityBloc>(
            create: (_) => EligibilityBloc(eligibilityRepository)
              ..add(FetchEligibilityEvent()),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<VehicleListBloc>(
              create: (_) => VehicleListBloc(getVehiclesUseCase),
            ),
            BlocProvider(
                create: (_) =>
                    ManageBookingBloc(MockRepository())..add(LoadBookings())),
            BlocProvider(create: (_) => MakeBookingBloc(MockRepository())),
            // Provider dependencies first
            BlocProvider(
              create: (context) => PlanBloc(context.read<PlanRepository>()),
            ),
            BlocProvider(
              create: (_) => DashboardBloc(
                DashboardRepository(
                  DashboardApiService(http.Client()),
                ),
              ),
            ),
            BlocProvider(
              create: (_) => UpgradeablePlansBloc(
                UpgradeablePlansRepository(
                  DashboardApiService(http.Client()),
                ),
              ),
            ),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            Provider<UserProfileService>(create: (_) => UserProfileService()),
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
            ChangeNotifierProvider(create: (_) => HomeDataProvider()),
            ChangeNotifierProvider(create: (_) => ProfileViewModel()),

            ChangeNotifierProvider(create: (_) => AddVehicleProvider()),
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
