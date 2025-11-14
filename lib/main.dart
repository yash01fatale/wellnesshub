import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Firebase config
import 'firebase_options.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/fitness_screen.dart';
import 'screens/sleep_screen.dart';
import 'screens/mental_screen.dart';
import 'screens/spirituality_screen.dart';
import 'screens/habits_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const WellnessHubApp());
}

class WellnessHubApp extends StatelessWidget {
  const WellnessHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WellnessHub',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      home: const AuthWrapper(),
    );
  }
}

// ------------------- AUTH WRAPPER -------------------
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const MainNavigation(); // If logged in
        } else {
          return const LoginScreen(); // If not logged in
        }
      },
    );
  }
}
// ------------------- MAIN NAVIGATION -------------------
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    NutritionScreen(),
    FitnessScreen(),
    SleepScreen(),
    MentalScreen(),
    SpiritualityScreen(),
    HabitsScreen(),
  ];

  final List<BottomNavigationBarItem> _items = const [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
    BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Nutrition"),
    BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Fitness"),
    BottomNavigationBarItem(icon: Icon(Icons.bedtime), label: "Sleep"),
    BottomNavigationBarItem(icon: Icon(Icons.psychology), label: "Mental"),
    BottomNavigationBarItem(icon: Icon(Icons.spa), label: "Spirituality"),
    BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: "Habits"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _items,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
