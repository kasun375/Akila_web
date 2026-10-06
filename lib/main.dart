import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/payhere_service.dart';
import 'providers/auth_provider.dart';
import 'providers/class_provider.dart';
import 'providers/content_provider.dart';
import 'providers/payment_provider.dart';
import 'views/auth/auth_screen.dart';
import 'views/navigation/responsive_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization warning: $e");
  }

  // Instantiate core backend services
  final authService = AuthService();
  final dbService = DatabaseService();
  final payHereService = PayHereService(dbService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => ClassProvider(dbService)),
        ChangeNotifierProvider(create: (_) => ContentProvider(dbService)),
        ChangeNotifierProvider(create: (_) => PaymentProvider(dbService, payHereService)),
      ],
      child: const AkilaMathsLmsApp(),
    ),
  );
}

class AkilaMathsLmsApp extends StatelessWidget {
  const AkilaMathsLmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akila Jayaweera Combined Maths LMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.bgLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isAuthenticated) {
            return const AuthScreen();
          }
          return const ResponsiveNavigation();
        },
      ),
    );
  }
}
