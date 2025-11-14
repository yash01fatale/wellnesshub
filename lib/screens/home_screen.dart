import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';
import 'fitness_screen.dart';
import 'sleep_screen.dart';
import 'habits_screen.dart';
import 'mental_screen.dart';
import 'spirituality_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    DashboardScreen(),
    FitnessScreen(),
    SleepScreen(),
    MentalScreen(),
    SpiritualityScreen(),
    HabitsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Fitness"),
          BottomNavigationBarItem(icon: Icon(Icons.bedtime), label: "Sleep"),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: "Mental"),
          BottomNavigationBarItem(icon: Icon(Icons.self_improvement), label: "Spiritual"),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: "Habits"),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(decoration: BoxDecoration(color: Colors.teal), child: Text("WellnessHub", style: TextStyle(fontSize: 24, color: Colors.white))),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
