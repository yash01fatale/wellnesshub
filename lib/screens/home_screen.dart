// lib/screens/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellnesshub/screens/theme/theme_notifier.dart';


// Core sections
import 'dashboard_screen.dart';
import 'nutrition_screen.dart';
import 'fitness_screen.dart';
import 'sleep_screen.dart';
import 'mental_screen.dart';
import 'spirituality_screen.dart';
import 'habits_screen.dart';
import 'daily_stats_screen.dart';
import 'ai_chat_screen.dart';
import 'focus_screen.dart';
import 'profile_screen.dart';
import 'addiction_recovery_screen.dart';
import 'women_wellness_screen.dart';
import 'habit_tracker_screen.dart';
import 'disease_prediction_screen.dart';
import 'digital_detox_screen.dart';
import 'community_screen.dart';
import 'ai_personal_plan_screen.dart';
import 'voice_command_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String displayName = "User";
  bool loading = true;

  // Mock vitals (can later be fetched from Firestore / API)
  int steps = 6500;
  int calories = 1850;
  String heartRate = "78";
  String sleep = "7h 05m";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          displayName = (doc.data()?['name'] ?? displayName).toString();
        });
      }
    } catch (_) {
      // ignore
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context)
        .pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
  }

  // -------------------- SMALL HELPERS --------------------

  void _openPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _showInfoDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  // Category chip row item
  Widget _categoryChip(String label, VoidCallback onTap,
      {bool selected = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: selected
              ? Colors.deepPurple
              : Theme.of(context).cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.25),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Quick tile for sections
  Widget _quickTile(String title, IconData icon, Widget page) {
    return InkWell(
      onTap: () => _openPage(page),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.25),
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vitalCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      TextStyle(color: Colors.grey[400], fontSize: 12)),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _toolCard(
      {required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.3),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.deepPurple.withOpacity(0.1),
              child: Icon(icon, color: Colors.deepPurple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 13,
                          color:
                              Theme.of(context).textTheme.bodySmall?.color)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _articleCard(
      {required String title,
      required String subtitle,
      required String imageUrl,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.3),
              blurRadius: 8,
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  // -------------------- BUILD --------------------

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // =================== TOP NAV BAR (FULL) ===================
      appBar: AppBar(
        toolbarHeight: 70,
        titleSpacing: 24,
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.deepPurple),
            const SizedBox(width: 8),
            const Text(
              "WellnessHub",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // Top nav links (only wide screens show all nicely)
            TextButton(
              onPressed: () {},
              child: const Text("Home"),
            ),
            TextButton(
              onPressed: () => _openPage(const FitnessScreen()),
              child: const Text("Fitness"),
            ),
            TextButton(
              onPressed: () => _openPage(const NutritionScreen()),
              child: const Text("Nutrition"),
            ),
            TextButton(
              onPressed: () => _openPage(const SleepScreen()),
              child: const Text("Sleep"),
            ),
            TextButton(
              onPressed: () => _openPage(const MentalScreen()),
              child: const Text("Mental"),
            ),
            TextButton(
              onPressed: () => _openPage(const AIChatScreen()),
              child: const Text("AI Assistant"),
            ),
            const SizedBox(width: 12),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => themeNotifier.toggleTheme(),
            icon: Icon(
              themeNotifier.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
          if (user != null)
            TextButton.icon(
              onPressed: () => _openPage(const ProfileScreen()),
              icon: const Icon(Icons.person),
              label: const Text("Profile"),
            )
          else
            TextButton(
              onPressed: () =>
                  _openPage(const LoginScreen()),
              child: const Text("Login"),
            ),
          const SizedBox(width: 8),
          if (user != null)
            TextButton(
              onPressed: _logout,
              child: const Text("Logout"),
            ),
          const SizedBox(width: 16),
        ],
      ),

      // =================== BODY ===================
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUser,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // =============== HERO SECTION ===============
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height: isWide ? 260 : 200,
                                      width: double.infinity,
                                      child: Image.network(
                                        "https://cdn.pixabay.com/video/2023/11/11/188742-883619742_tiny.jpg",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      height: isWide ? 260 : 200,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.75),
                                            Colors.transparent
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 20,
                                      bottom: 20,
                                      right: isWide ? 260 : 20,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Hello, $displayName 👋",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            "One place for your fitness, nutrition, sleep, mind and soul.",
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.deepPurple,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 18,
                                                    vertical: 10,
                                                  ),
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                                onPressed: () => _openPage(
                                                    const AIPersonalPlanScreen()),
                                                child: const Text(
                                                    "Start Personal Plan"),
                                              ),
                                              const SizedBox(width: 10),
                                              OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(
                                                      color: Colors.white),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 18,
                                                    vertical: 10,
                                                  ),
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    _openPage(const DashboardScreen()),
                                                child: const Text(
                                                  "Open Dashboard",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 22),

                              // =============== CATEGORY TABS ===============
                              SizedBox(
                                height: 50,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    _categoryChip("All",
                                        () {}, selected: true),
                                    _categoryChip("Fitness",
                                        () => _openPage(const FitnessScreen())),
                                    _categoryChip("Nutrition",
                                        () => _openPage(const NutritionScreen())),
                                    _categoryChip("Sleep",
                                        () => _openPage(const SleepScreen())),
                                    _categoryChip("Mental Health",
                                        () => _openPage(const MentalScreen())),
                                    _categoryChip("Women Wellness",
                                        () => _openPage(const WomenWellnessScreen())),
                                    _categoryChip("Addiction Recovery",
                                        () => _openPage(const AddictionRecoveryScreen())),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 22),

                              // =============== TODAY'S SNAPSHOT ===============
                              const Text(
                                "Today's Snapshot",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: _vitalCard(
                                        "Heart Rate",
                                        "$heartRate bpm",
                                        Icons.favorite,
                                        Colors.red),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _vitalCard(
                                        "Steps",
                                        "$steps",
                                        Icons.directions_walk,
                                        Colors.orange),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _vitalCard(
                                        "Calories",
                                        "$calories kcal",
                                        Icons.local_fire_department,
                                        Colors.teal),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _vitalCard(
                                        "Sleep",
                                        sleep,
                                        Icons.bedtime,
                                        Colors.blue),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 30),

                              // =============== EXPLORE WELLNESS AREAS ===============
                              const Text(
                                "Explore Wellness Areas",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              const SizedBox(height: 14),

                              Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                children: [
                                  _quickTile("Fitness", Icons.fitness_center,
                                      const FitnessScreen()),
                                  _quickTile("Nutrition", Icons.restaurant,
                                      const NutritionScreen()),
                                  _quickTile("Sleep", Icons.bedtime,
                                      const SleepScreen()),
                                  _quickTile("Mental Health",
                                      Icons.psychology, const MentalScreen()),
                                  _quickTile("Spirituality", Icons.self_improvement,
                                      const SpiritualityScreen()),
                                  _quickTile("Habits", Icons.track_changes,
                                      const HabitsScreen()),
                                  _quickTile("Women Wellness", Icons.female,
                                      const WomenWellnessScreen()),
                                  _quickTile("Addiction Recovery",
                                      Icons.smoke_free,
                                      const AddictionRecoveryScreen()),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // =============== TOOLS & SMART FEATURES ===============
                              const Text(
                                "Smart Tools & AI Features",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              const SizedBox(height: 14),

                              _toolCard(
                                title: "AI Personal Plan",
                                subtitle:
                                    "Get an adaptive fitness, nutrition and sleep plan designed just for you.",
                                icon: Icons.auto_awesome,
                                onTap: () =>
                                    _openPage(const AIPersonalPlanScreen()),
                              ),
                              const SizedBox(height: 12),
                              _toolCard(
                                title: "Disease Risk Prediction",
                                subtitle:
                                    "Predict early risk based on your lifestyle and health inputs.",
                                icon: Icons.biotech,
                                onTap: () =>
                                    _openPage(const DiseasePredictionScreen()),
                              ),
                              const SizedBox(height: 12),
                              _toolCard(
                                title: "Digital Detox & Focus",
                                subtitle:
                                    "Limit distractions, use focus mode, and schedule digital detox sessions.",
                                icon: Icons.timelapse,
                                onTap: () =>
                                    _openPage(const DigitalDetoxScreen()),
                              ),
                              const SizedBox(height: 12),
                              _toolCard(
                                title: "AI Wellness Assistant",
                                subtitle:
                                    "Chat with AI about your goals, doubts and daily check-ins.",
                                icon: Icons.smart_toy,
                                onTap: () => _openPage(const AIChatScreen()),
                              ),
                              const SizedBox(height: 12),
                              _toolCard(
                                title: "Habit Tracker & Daily Stats",
                                subtitle:
                                    "Track habits, view daily stats and celebrate your streaks.",
                                icon: Icons.bar_chart,
                                onTap: () =>
                                    _openPage(const DailyStatsScreen()),
                              ),
                              const SizedBox(height: 12),
                              _toolCard(
                                title: "Voice Commands & Community",
                                subtitle:
                                    "Control the app with your voice and join a supportive community.",
                                icon: Icons.mic,
                                onTap: () =>
                                    _openPage(const VoiceCommandScreen()),
                              ),
                              const SizedBox(height: 12),
                              _toolCard(
                                title: "Community Space",
                                subtitle:
                                    "Share progress, ask questions and motivate each other.",
                                icon: Icons.forum,
                                onTap: () =>
                                    _openPage(const CommunityScreen()),
                              ),

                              const SizedBox(height: 32),

                              // =============== FEATURED ARTICLES ===============
                              const Text(
                                "Featured Wellness Reads",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              const SizedBox(height: 14),

                              _articleCard(
                                title:
                                    "10 Exercises to Tone Every Inch of Your Body",
                                subtitle:
                                    "Full body moves you can do at home with minimal equipment.",
                                imageUrl:
                                    "https://images.pexels.com/photos/4754141/pexels-photo-4754141.jpeg",
                                onTap: () =>
                                    _openPage(const FitnessScreen()),
                              ),
                              const SizedBox(height: 12),

                              _articleCard(
                                title:
                                    "The Best Core Exercises for All Fitness Levels",
                                subtitle:
                                    "Strengthen your core safely with these science-backed moves.",
                                imageUrl:
                                    "https://images.pexels.com/photos/6453396/pexels-photo-6453396.jpeg",
                                onTap: () =>
                                    _openPage(const FitnessScreen()),
                              ),
                              const SizedBox(height: 12),

                              _articleCard(
                                title:
                                    "Beginner Guide to Better Sleep Hygiene",
                                subtitle:
                                    "Small changes that dramatically improve your sleep quality.",
                                imageUrl:
                                    "https://images.pexels.com/photos/935777/pexels-photo-935777.jpeg",
                                onTap: () =>
                                    _openPage(const SleepScreen()),
                              ),
                              const SizedBox(height: 12),

                              _articleCard(
                                title:
                                    "Balanced Eating: What a Healthy Plate Looks Like",
                                subtitle:
                                    "Simple visual tricks to keep your daily meals balanced and satisfying.",
                                imageUrl:
                                    "https://images.pexels.com/photos/406152/pexels-photo-406152.jpeg",
                                onTap: () =>
                                    _openPage(const NutritionScreen()),
                              ),

                              const SizedBox(height: 40),

                              // =============== FOOTER ===============
                              Divider(
                                color: Colors.grey.withOpacity(0.3),
                                thickness: 1,
                              ),
                              const SizedBox(height: 24),

                              LayoutBuilder(
                                builder: (context, c) {
                                  final footerWide = c.maxWidth > 700;
                                  if (footerWide) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _footerColumn(
                                          title: "About",
                                          children: [
                                            _footerLink(
                                              "About WellnessHub",
                                              () => _showInfoDialog(
                                                "About WellnessHub",
                                                "WellnessHub is a holistic wellness platform that brings fitness, nutrition, sleep, mental health and spiritual balance into a single experience.",
                                              ),
                                            ),
                                            _footerLink(
                                              "Our Mission",
                                              () => _showInfoDialog(
                                                "Our Mission",
                                                "We want to make everyday wellbeing simple, data-driven and accessible for everyone.",
                                              ),
                                            ),
                                            _footerLink(
                                              "Team",
                                              () => _showInfoDialog(
                                                "Team",
                                                "Built with ❤️ by a passionate team of developers, designers and health enthusiasts.",
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 40),
                                        _footerColumn(
                                          title: "Support",
                                          children: [
                                            _footerLink(
                                              "Contact Us",
                                              () => _showInfoDialog(
                                                "Contact",
                                                "For feedback, suggestions or issues, write to: support@wellnesshub.app",
                                              ),
                                            ),
                                            _footerLink(
                                              "Help Center",
                                              () => _showInfoDialog(
                                                "Help Center",
                                                "Check FAQs, guides and troubleshooting tips inside the Help section (coming soon).",
                                              ),
                                            ),
                                            _footerLink(
                                              "Report an Issue",
                                              () => _showInfoDialog(
                                                "Report Issue",
                                                "To report a bug or security issue, please mail us at: security@wellnesshub.app",
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 40),
                                        _footerColumn(
                                          title: "Features",
                                          children: [
                                            _footerLink(
                                              "Dashboard",
                                              () => _openPage(
                                                  const DashboardScreen()),
                                            ),
                                            _footerLink(
                                              "AI Personal Plan",
                                              () => _openPage(
                                                  const AIPersonalPlanScreen()),
                                            ),
                                            _footerLink(
                                              "Disease Prediction",
                                              () => _openPage(
                                                  const DiseasePredictionScreen()),
                                            ),
                                            _footerLink(
                                              "Digital Detox",
                                              () => _openPage(
                                                  const DigitalDetoxScreen()),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 40),
                                        _footerColumn(
                                          title: "Legal",
                                          children: [
                                            _footerLink(
                                              "Privacy Policy",
                                              () => _showInfoDialog(
                                                "Privacy Policy",
                                                "We respect your privacy. Health data shown here is for informational & educational purposes and should not replace professional medical advice.",
                                              ),
                                            ),
                                            _footerLink(
                                              "Terms of Service",
                                              () => _showInfoDialog(
                                                "Terms of Service",
                                                "By using WellnessHub you agree to use it responsibly and not treat it as a replacement for medical diagnosis or emergency services.",
                                              ),
                                            ),
                                            _footerLink(
                                              "Content Integrity",
                                              () => _showInfoDialog(
                                                "Content Integrity",
                                                "We aim to surface evidence-based information and clearly mark AI-generated suggestions.",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  } else {
                                    // stacked footer on small screens
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _footerColumn(
                                          title: "About",
                                          children: [
                                            _footerLink(
                                              "About WellnessHub",
                                              () => _showInfoDialog(
                                                "About WellnessHub",
                                                "WellnessHub is a holistic wellness platform that brings fitness, nutrition, sleep, mental health and spiritual balance into a single experience.",
                                              ),
                                            ),
                                            _footerLink(
                                              "Our Mission",
                                              () => _showInfoDialog(
                                                "Our Mission",
                                                "We want to make everyday wellbeing simple, data-driven and accessible for everyone.",
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        _footerColumn(
                                          title: "Support",
                                          children: [
                                            _footerLink(
                                              "Contact Us",
                                              () => _showInfoDialog(
                                                "Contact",
                                                "For feedback, suggestions or issues, write to: support@wellnesshub.app",
                                              ),
                                            ),
                                            _footerLink(
                                              "Help Center",
                                              () => _showInfoDialog(
                                                "Help Center",
                                                "Check FAQs, guides and troubleshooting tips inside the Help section (coming soon).",
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        _footerColumn(
                                          title: "Features",
                                          children: [
                                            _footerLink(
                                              "Dashboard",
                                              () => _openPage(
                                                  const DashboardScreen()),
                                            ),
                                            _footerLink(
                                              "AI Personal Plan",
                                              () => _openPage(
                                                  const AIPersonalPlanScreen()),
                                            ),
                                            _footerLink(
                                              "Disease Prediction",
                                              () => _openPage(
                                                  const DiseasePredictionScreen()),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        _footerColumn(
                                          title: "Legal",
                                          children: [
                                            _footerLink(
                                              "Privacy Policy",
                                              () => _showInfoDialog(
                                                "Privacy Policy",
                                                "We respect your privacy. Health data shown here is for informational & educational purposes and should not replace professional medical advice.",
                                              ),
                                            ),
                                            _footerLink(
                                              "Terms of Service",
                                              () => _showInfoDialog(
                                                "Terms of Service",
                                                "By using WellnessHub you agree to use it responsibly and not treat it as a replacement for medical diagnosis or emergency services.",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),

                              const SizedBox(height: 20),
                              Center(
                                child: Text(
                                  "© ${DateTime.now().year} WellnessHub. All rights reserved.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  // Footer column helper
  Widget _footerColumn({
    required String title,
    required List<Widget> children,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // Footer link helper
  Widget _footerLink(String label, VoidCallback onTap) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
