// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/constants/app_theme.dart';
import 'views/auth/login_screen.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/splash/splash_screen.dart';
import 'views/profile/profile_completion_screen.dart';
import 'services/firestore_service.dart';
import 'models/user_model.dart';
import 'services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LocalNotificationService.instance.initialize();

  runApp(const SmartTravelPlannerApp());
}

class SmartTravelPlannerApp extends StatelessWidget {
  const SmartTravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Travel Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _AppStartGate(),
    );
  }
}

class _AppStartGate extends StatefulWidget {
  const _AppStartGate();

  @override
  State<_AppStartGate> createState() => _AppStartGateState();
}

class _AppStartGateState extends State<_AppStartGate> {
  bool? _onboardingComplete;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _primeStartup();
  }

  Future<void> _primeStartup() async {
    final prefs = await SharedPreferences.getInstance();
    final complete = prefs.getBool('onboardingComplete') ?? false;
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _onboardingComplete = complete;
        _showSplash = false;
      });
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    if (mounted) setState(() => _onboardingComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }
    if (_onboardingComplete == false) {
      return OnboardingScreen(onFinished: _finishOnboarding);
    }
    return const _AuthGate();
  }
}

/// Decides whether to show Login or Dashboard based on Firebase auth state.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return const _ProfileGate();
          }
          return const LoginScreen();
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const _ProfileGate();
        }
        return const LoginScreen();
      },
    );
  }
}

class _ProfileGate extends StatelessWidget {
  const _ProfileGate();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const LoginScreen();

    return StreamBuilder<UserModel?>(
      stream: FirestoreService().streamUser(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        if (!user.profileComplete) {
          return ProfileCompletionScreen(user: user);
        }

        return const DashboardScreen();
      },
    );
  }
}
