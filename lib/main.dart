// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// THEME FILES
import 'screens/theme/theme.dart';
import 'screens/theme/theme_notifier.dart';

// SCREENS
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/fitness_screen.dart';
import 'screens/sleep_screen.dart';
import 'screens/mental_screen.dart';
import 'screens/spirituality_screen.dart';
import 'screens/habits_screen.dart' hide HomeScreen;
import 'screens/profile_screen.dart';
import 'screens/habit_tracker_screen.dart';
import 'screens/daily_stats_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/disease_prediction_screen.dart';
import 'screens/addiction_recovery_screen.dart';
import 'screens/women_wellness_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const WellnessHubApp(),
    ),
  );
}

class WellnessHubApp extends StatelessWidget {
  const WellnessHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WellnessHub',

      // THEME SUPPORT
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.currentMode, // AUTO SWITCH

      // ROUTES
      routes: {
        '/home': (_) => const HomeScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/nutrition': (_) => const NutritionScreen(),
        '/fitness': (_) => const FitnessScreen(),
        '/sleep': (_) => const SleepScreen(),
        '/mental': (_) => const MentalScreen(),
        '/spirituality': (_) => const SpiritualityScreen(),
        '/habits': (_) => const HabitsScreen(),
        '/habit-tracker': (_) => const HabitTrackerScreen(),
        '/daily-stats': (_) => const DailyStatsScreen(),
        '/assistant': (_) => const AIChatScreen(),
        '/focus': (_) => const FocusScreen(),
        '/prediction': (_) => const DiseasePredictionScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/login': (_) => const LoginScreen(),

        // NEW
        '/addiction': (_) => const AddictionRecoveryScreen(),
        '/women-wellness': (_) => const WomenWellnessScreen(),
      },

      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
