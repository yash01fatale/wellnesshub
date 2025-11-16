// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/fitness_screen.dart';
import 'screens/sleep_screen.dart';
import 'screens/mental_screen.dart';
import 'screens/spirituality_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/habit_tracker_screen.dart';
import 'screens/daily_stats_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/focus_screen.dart'; 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WellnessHubApp());
}

class WellnessHubApp extends StatelessWidget {
  const WellnessHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WellnessHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: false,
      ),
      // Use named routes for clarity
      initialRoute: '/',
      routes: {
  '/': (_) => const AuthWrapper(),
  '/home': (_) => const HomeScreen(),
  '/focus': (_) => const FocusScreen(),
  '/nutrition': (_) => const NutritionScreen(),
  '/fitness': (_) => const FitnessScreen(),
  '/sleep': (_) => const SleepScreen(),
  '/mental': (_) => const MentalScreen(),
  '/spirituality': (_) => const SpiritualityScreen(),
  '/habits': (_) => const HabitsScreen(),
  '/dashboard': (_) => const DashboardScreen(),
  '/daily-stats': (_) => const DailyStatsScreen(),
  '/assistant': (_) => const AIChatScreen(),
  '/profile': (_) => const ProfileScreen(),
},

    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder ensures correct state after hot-reload and avoids instant navigation issues.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still connecting to Firebase auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // If user is logged in show HomeScreen (primary hub)
          return const HomeScreen();
        } else {
          // Not logged in -> LoginScreen
          return const LoginScreen();
        }
      },
    );
  }
}
