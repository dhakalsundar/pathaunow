import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pathau_now/core/services/locale_service.dart';
import 'package:pathau_now/core/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/splash/presentation/pages/splash_screen.dart';
import 'features/onboarding/presentation/pages/onboarding_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/signup_screen.dart';
import 'features/dashboard/presentation/pages/dashboard_screen.dart';
import 'features/media/presentation/pages/media_page.dart';
import 'features/tracking/presentation/pages/track_parcel_pade.dart';
import 'features/tracking/presentation/pages/create_parcel_page.dart';
import 'features/support/presentation/pages/support_page.dart';
import 'features/notifications/presentation/pages/notifications_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/map/presentation/pages/map_screen.dart';
import 'features/tracking/presentation/viewmodels/parcel_viewmodel.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/auth/presentation/viewmodels/address_viewmodel.dart';
import 'features/auth/presentation/pages/addresses_screen.dart';
import 'features/auth/presentation/pages/account_details_screen.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/tracking/data/repositories/parcel_repository_impl.dart';
import 'features/tracking/data/datasources/parcel_remote_datasource.dart';

class PathauNowApp extends StatelessWidget {
  const PathauNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepositoryImpl();
    final parcelRepository = ParcelRepositoryImpl(ParcelRemoteDataSourceImpl());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepository)),
        ChangeNotifierProvider(
          create: (_) => ParcelViewModel(parcelRepository),
        ),
        ChangeNotifierProvider(create: (_) => AddressViewModel(authRepository)),
        // Provide locale service for simple runtime localization
        ChangeNotifierProvider(create: (_) => LocaleService()),
      ],
      child: Consumer<LocaleService>(
        builder: (context, localeSvc, _) {
          return MaterialApp(
            title: 'Pathau Now',
            debugShowCheckedModeBanner: false,
            initialRoute: SplashScreen.routeName,
            locale: Provider.of<LocaleService>(context).locale,
            supportedLocales: const [Locale('en'), Locale('ne')],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routes: <String, WidgetBuilder>{
              SplashScreen.routeName: (_) => const SplashScreen(),
              OnboardingScreen.routeName: (_) => const OnboardingScreen(),
              LoginScreen.routeName: (_) => const LoginScreen(),
              SignupScreen.routeName: (_) => const SignupScreen(),
              DashboardScreen.routeName: (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                int initialIndex = 0;
                if (args is Map && args['initialIndex'] is int) {
                  initialIndex = args['initialIndex'] as int;
                }
                return DashboardScreen(initialIndex: initialIndex);
              },
              // Addresses screen
              '/addresses': (_) => const AddressesScreen(),
              // Account details
              AccountDetailsScreen.routeName: (_) =>
                  const AccountDetailsScreen(),
              MediaPage.routeName: (_) => const MediaPage(),
              '/create-parcel': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                final pickupNow = args is Map && args['pickupNow'] == true;
                return CreateParcelPage(pickupNow: pickupNow);
              },
              '/support': (_) => const SupportPage(),
              '/notifications': (_) => const NotificationsPage(),
              '/track': (_) => const TrackParcelPage(),
              '/settings': (_) => const SettingsPage(),
              MapScreen.routeName: (_) => const MapScreen(),
            },
            builder: (context, child) {
              // Ensure responsive design for all screen sizes
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  // Enable proper text scaling for tablet/desktop
                  textScaler: TextScaler.linear(
                    MediaQuery.of(context).textScaleFactor > 1.1
                        ? 1.1
                        : MediaQuery.of(context).textScaleFactor,
                  ),
                ),
                child: child ?? const SizedBox(),
              );
            },
          );
        },
      ),
    );
  }
}
