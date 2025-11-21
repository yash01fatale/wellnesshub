// lib/screens/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/theme_notifier.dart';

// Core / auth
import 'login_screen.dart';
import 'profile_screen.dart';

// Core wellness areas
import 'dashboard_screen.dart';
import 'nutrition_screen.dart';
import 'fitness_screen.dart';
import 'sleep_screen.dart';
import 'mental_screen.dart';
import 'spirituality_screen.dart';
import 'habits_screen.dart';
import 'women_wellness_screen.dart';
import 'addiction_recovery_screen.dart';

// Tools / AI
import 'ai_chat_screen.dart';
import 'ai_personal_plan_screen.dart';
import 'daily_stats_screen.dart';
import 'habit_tracker_screen.dart';
import 'focus_screen.dart';
import 'digital_detox_screen.dart';
import 'disease_prediction_screen.dart';
import 'voice_command_screen.dart';
import 'community_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String displayName = "User";
  bool loading = true;

  // Example vitals – can later come from Firestore
  int steps = 6543;
  int calories = 1820;
  String heartRate = "78";
  String sleep = "7h 05m";

  late AnimationController _heroAnim;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _heroAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _heroAnim.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          displayName = (doc.data()?['name'] ?? displayName).toString();
        });
      }
    } catch (_) {
      // ignore for now
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  // ----------------- Navigation helpers -----------------

  void _open(Widget page) {
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
          ),
        ],
      ),
    );
  }

  // ----------------- Reusable buttons -----------------

  Widget _primaryButton(String label, VoidCallback onPressed,
      {Color textColor = Colors.white}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: BorderSide(color: Colors.white.withOpacity(0.9)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Widget _secondaryButton(String label, VoidCallback onPressed,
      {Color textColor = Colors.white}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: BorderSide(color: Colors.white.withOpacity(0.9)),
      ),
      onPressed: onPressed,
      child: Text(label, style: TextStyle(color: textColor)),
    );
  }

  // ----------------- Cards -----------------

  Widget _problemCard(
      String title, String desc, IconData icon, VoidCallback onTap) {
    return HoverScale(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF1A237E).withOpacity(0.12),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFF1A237E)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard(String title, String desc, IconData icon,
      {VoidCallback? onTap}) {
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF1A237E).withOpacity(0.12),
            child: Icon(icon, color: const Color(0xFF1A237E)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );

    final card = HoverScale(child: content);
    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: card,
    );
  }

  Widget _vitalCard(String title, String value, IconData icon, Color color) {
    return HoverScale(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _toolRow({
    required String title,
    required String desc,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return HoverScale(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF1A237E).withOpacity(0.12),
                child: Icon(icon, color: const Color(0xFF1A237E)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _testimonialCard(String name, String role, String quote) {
    return HoverScale(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(
                      role,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "\"$quote\"",
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _footerColumn(String title, List<Widget> children) {
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

  Widget _screenShowcaseCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget page,
  }) {
    return HoverScale(
      child: InkWell(
        onTap: () => _open(page),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 260,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.96),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mock preview
              Container(
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1A237E),
                      Color(0xFF0D47A1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 42),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- BUILD -----------------

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 70,
        elevation: 0,
        backgroundColor: const Color.fromARGB(0, 148, 27, 27),
        titleSpacing: 24,
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Color(0xFF1A237E)),
            const SizedBox(width: 8),
            const Text(
              "WellnessHub",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text("Home")),
            TextButton(
                onPressed: () => _open(const FitnessScreen()),
                child: const Text("Fitness")),
            TextButton(
                onPressed: () => _open(const NutritionScreen()),
                child: const Text("Nutrition")),
            TextButton(
                onPressed: () => _open(const SleepScreen()),
                child: const Text("Sleep")),
            TextButton(
                onPressed: () => _open(const MentalScreen()),
                child: const Text("Mental")),
            TextButton(
                onPressed: () => _open(const AIChatScreen()),
                child: const Text("AI Coach")),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Toggle theme",
            onPressed: () => themeNotifier.toggleTheme(),
            icon: Icon(
              themeNotifier.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
          if (user != null)
            TextButton.icon(
              onPressed: () => _open(const ProfileScreen()),
              icon: const Icon(Icons.person),
              label: const Text("Profile"),
            )
          else
            TextButton(
              onPressed: () => _open(const LoginScreen()),
              child: const Text("Login"),
            ),
          if (user != null)
            TextButton(onPressed: _logout, child: const Text("Logout")),
          const SizedBox(width: 12),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUser,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const maxWidth = 1100.0;
                  final isWide = constraints.maxWidth > 900;

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: maxWidth),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ---------- HERO ----------
                              FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: _heroAnim,
                                  curve: Curves.easeOut,
                                ),
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.05),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: _heroAnim,
                                    curve: Curves.easeOut,
                                  )),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: isWide ? 280 : 230,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF1A237E),
                                                Color(0xFF0D47A1)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  Colors.black
                                                      .withOpacity(0.6),
                                                  Colors.black
                                                      .withOpacity(0.05),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 22,
                                          right: isWide ? 260 : 22,
                                          bottom: 22,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Hi, $displayName 👋",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17),
                                              ),
                                              const SizedBox(height: 8),
                                              const Text(
                                                "Your AI-powered lifestyle, wellness & spirituality OS.",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              const Text(
                                                "One place to align food, fitness, sleep, focus, emotions & inner growth.",
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Wrap(
                                                spacing: 12,
                                                runSpacing: 8,
                                                key: ValueKey(
                                                  TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                children: [
                                                  _primaryButton(
                                                    "Start AI Plan",
                                                    () => _open(
                                                        const AIPersonalPlanScreen()),
                                                  ),
                                                  _secondaryButton(
                                                    "Talk to AI Coach",
                                                    () => _open(
                                                        const AIChatScreen()),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Wrap(
                                                spacing: 24,
                                                runSpacing: 8,
                                                children: const [
                                                  _HeroStat(
                                                      label:
                                                          "feel better in 7 days",
                                                      value: "90%"),
                                                  _HeroStat(
                                                      label:
                                                          "daily active check-ins",
                                                      value: "3x"),
                                                  _HeroStat(
                                                      label:
                                                          "journeys completed",
                                                      value: "10K+"),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // ---------- PROBLEM SECTION ----------
                              const Text(
                                "Why the world needs WellnessHub",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Life is busy, screens are constant and health is fragmented across dozens of apps. People want calmer minds, better sleep, stronger bodies and deeper meaning – in one place.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                              const SizedBox(height: 16),

                              Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                children: [
                                  SizedBox(
                                    width: isWide ? (maxWidth - 14) / 2 : null,
                                    child: _problemCard(
                                      "Irregular Sleep & Low Energy",
                                      "Late nights, doom-scrolling and shallow sleep drain focus and mood.",
                                      Icons.bedtime,
                                      () => _open(const SleepScreen()),
                                    ),
                                  ),
                                  SizedBox(
                                    width: isWide ? (maxWidth - 14) / 2 : null,
                                    child: _problemCard(
                                      "Poor Nutrition & Lifestyle Diseases",
                                      "Ultra-processed food, random diets and no structure increase long-term risk.",
                                      Icons.restaurant,
                                      () => _open(const NutritionScreen()),
                                    ),
                                  ),
                                  SizedBox(
                                    width: isWide ? (maxWidth - 14) / 2 : null,
                                    child: _problemCard(
                                      "Sedentary Routine & Stress",
                                      "Long sitting, no workouts and constant pressure build anxiety & burnout.",
                                      Icons.fitness_center,
                                      () => _open(const FitnessScreen()),
                                    ),
                                  ),
                                  SizedBox(
                                    width: isWide ? (maxWidth - 14) / 2 : null,
                                    child: _problemCard(
                                      "Addictions & Ignored Women’s Health",
                                      "Smoking, binge eating, alcohol and PCOS, hormonal issues stay in the shadows.",
                                      Icons.warning_amber,
                                      () =>
                                          _open(const AddictionRecoveryScreen()),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 28),

                              // ---------- SOLUTION + VITALS ----------
                              const Text(
                                "Our solution: one AI wellness operating system",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "WellnessHub brings Nutrition, Fitness, Sleep, Mental Health, Spirituality, Habits, Focus and Women’s Wellness into a single adaptive companion.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                              const SizedBox(height: 18),

                              Row(
                                children: [
                                  Expanded(
                                    child: _vitalCard(
                                      "Today’s Steps",
                                      "$steps",
                                      Icons.directions_walk,
                                      Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _vitalCard(
                                      "Sleep Duration",
                                      sleep,
                                      Icons.bedtime,
                                      Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _vitalCard(
                                      "Heart Rate",
                                      "$heartRate bpm",
                                      Icons.favorite,
                                      Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _vitalCard(
                                      "Calories Today",
                                      "$calories kcal",
                                      Icons.local_fire_department,
                                      Colors.teal,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 30),

                              // ---------- DIFFERENTIATORS ----------
                              const Text(
                                "Why WellnessHub is different",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 12),

                              LayoutBuilder(
                                builder: (_, c) {
                                  final threeCols = c.maxWidth > 850;
                                  final twoCols = c.maxWidth > 550;
                                  final itemWidth = threeCols
                                      ? (c.maxWidth - 28) / 3
                                      : twoCols
                                          ? (c.maxWidth - 14) / 2
                                          : c.maxWidth;

                                  return Wrap(
                                    spacing: 14,
                                    runSpacing: 14,
                                    children: [
                                      SizedBox(
                                        width: itemWidth,
                                        child: _featureCard(
                                          "All-in-one, not fragmented",
                                          "No more jumping between diet, workout, meditation and habit apps.",
                                          Icons.hub,
                                          onTap: () =>
                                              _open(const NutritionScreen()),
                                        ),
                                      ),
                                      SizedBox(
                                        width: itemWidth,
                                        child: _featureCard(
                                          "AI with emotional tone",
                                          "Tone-aware conversations that feel like a coach, not a chatbot.",
                                          Icons.sentiment_satisfied_alt,
                                          onTap: () =>
                                              _open(const AIChatScreen()),
                                        ),
                                      ),
                                      SizedBox(
                                        width: itemWidth,
                                        child: _featureCard(
                                          "Women’s wellness at the core",
                                          "PCOS, periods, pregnancy and hormones built into journeys, not hidden.",
                                          Icons.female,
                                          onTap: () =>
                                              _open(const WomenWellnessScreen()),
                                        ),
                                      ),
                                      SizedBox(
                                        width: itemWidth,
                                        child: _featureCard(
                                          "Body, mind & spirit together",
                                          "Fitness, food, focus, journaling, gratitude and breathwork in one flow.",
                                          Icons.spa,
                                          onTap: () =>
                                              _open(const MentalScreen()),
                                        ),
                                      ),
                                      SizedBox(
                                        width: itemWidth,
                                        child: _featureCard(
                                          "Real-world friendly",
                                          "Local foods, budgets, family life, exams, startup stress – not just theory.",
                                          Icons.public,
                                          onTap: () =>
                                              _open(const FocusScreen()),
                                        ),
                                      ),
                                      SizedBox(
                                        width: itemWidth,
                                        child: _featureCard(
                                          "Actionable, not overwhelming",
                                          "Small nudges, micro-habits and quick wins instead of 50-page PDFs.",
                                          Icons.bolt,
                                          onTap: () =>
                                              _open(const HabitTrackerScreen()),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 30),

                              // ---------- SHOWCASE ----------
                              const Text(
                                "Explore the experience",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Every screen is part of one system that learns your rhythm over time.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                              const SizedBox(height: 14),

                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _screenShowcaseCard(
                                      title: "Unified Dashboard",
                                      subtitle:
                                          "Steps, sleep, habits, mood & focus in one clean view.",
                                      icon: Icons.dashboard,
                                      page: const DashboardScreen(),
                                    ),
                                    _screenShowcaseCard(
                                      title: "AI Coach Chat",
                                      subtitle:
                                          "Daily conversations to check-in, vent and plan.",
                                      icon: Icons.smart_toy,
                                      page: const AIChatScreen(),
                                    ),
                                    _screenShowcaseCard(
                                      title: "Habits & Streaks",
                                      subtitle:
                                          "Micro-habits, streaks and reflections that stick.",
                                      icon: Icons.track_changes,
                                      page: const HabitTrackerScreen(),
                                    ),
                                    _screenShowcaseCard(
                                      title: "Focus & Digital Detox",
                                      subtitle:
                                          "Focus timers, screen nudges and digital fasts.",
                                      icon: Icons.timelapse,
                                      page: const FocusScreen(),
                                    ),
                                    _screenShowcaseCard(
                                      title: "Deep Sleep Routines",
                                      subtitle:
                                          "Wind-down flows, journaling & calming prompts.",
                                      icon: Icons.nightlight_round,
                                      page: const SleepScreen(),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // ---------- TOOLS ----------
                              const Text(
                                "AI tools & predictive insights",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 14),

                              _toolRow(
                                title: "AI Personal Plan",
                                desc:
                                    "One plan across food, movement, sleep, habits & focus.",
                                icon: Icons.auto_awesome,
                                onTap: () => _open(const AIPersonalPlanScreen()),
                              ),
                              const SizedBox(height: 12),
                              _toolRow(
                                title: "Daily Stats & Trends",
                                desc:
                                    "See how your energy, mood and habits move over time.",
                                icon: Icons.insights,
                                onTap: () => _open(const DailyStatsScreen()),
                              ),
                              const SizedBox(height: 12),
                              _toolRow(
                                title: "Disease Risk Prediction",
                                desc:
                                    "Early lifestyle risk hints (not diagnosis) from your patterns.",
                                icon: Icons.biotech,
                                onTap: () =>
                                    _open(const DiseasePredictionScreen()),
                              ),
                              const SizedBox(height: 12),
                              _toolRow(
                                title: "Voice Commands",
                                desc:
                                    "Start workouts, meditations & affirmations hands-free.",
                                icon: Icons.mic,
                                onTap: () => _open(const VoiceCommandScreen()),
                              ),
                              const SizedBox(height: 12),
                              _toolRow(
                                title: "Community & Challenges",
                                desc:
                                    "Safe spaces, accountability partners and healthy challenges.",
                                icon: Icons.people,
                                onTap: () => _open(const CommunityScreen()),
                              ),const SizedBox(height: 12),
                              _toolRow(
                                title: "Spirituality & happiness",
                                desc:
                                    "Support your inner peace and joy through mindful practices.",
                                icon: Icons.spa,
                                onTap: () => _open(const SpiritualityScreen()),
                              ),

                              const SizedBox(height: 30),

                              // ---------- TESTIMONIALS ----------
                              const Text(
                                "People already feel the shift",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 14),

                              LayoutBuilder(
                                builder: (_, c) {
                                  final twoCols = c.maxWidth > 700;
                                  final itemWidth = twoCols
                                      ? (c.maxWidth - 14) / 2
                                      : c.maxWidth;

                                  return Column(
                                    children: [
                                      Wrap(
                                        spacing: 14,
                                        runSpacing: 14,
                                        children: [
                                          SizedBox(
                                            width: itemWidth,
                                            child: _testimonialCard(
                                              "Aarav, 27",
                                              "Engineer",
                                              "I was juggling 4 different apps. WellnessHub finally connects my sleep, workouts and focus in one flow.",
                                            ),
                                          ),
                                          SizedBox(
                                            width: itemWidth,
                                            child: _testimonialCard(
                                              "Sneha, 24",
                                              "Student with PCOS",
                                              "The AI coach feels surprisingly human and the women’s wellness journeys feel safe and practical.",
                                            ),
                                          ),
                                          SizedBox(
                                            width: itemWidth,
                                            child: _testimonialCard(
                                              "Rohit, 35",
                                              "Founder",
                                              "Focus mode + sleep routines + small nudges helped me rebuild my mornings without burnout.",
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Wrap(
                                        spacing: 16,
                                        runSpacing: 10,
                                        children: const [
                                          _StatChip(
                                              label:
                                                  "report better sleep in 14 days",
                                              value: "78%"),
                                          _StatChip(
                                              label:
                                                  "stick to habits for 30+ days",
                                              value: "65%"),
                                          _StatChip(
                                              label:
                                                  "feel calmer & less anxious",
                                              value: "82%"),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 30),

                              // ---------- FAQ ----------
                              const Text(
                                "Frequently asked questions",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              _faqItem(
                                "Is WellnessHub a medical app?",
                                "No. WellnessHub focuses on lifestyle, habits and mental wellbeing. It does not replace doctors, therapists or emergency services.",
                              ),
                              _faqItem(
                                "Is my data private?",
                                "We respect your privacy. Data is used to personalise your experience. You choose what to share.",
                              ),
                              _faqItem(
                                "Can this help with diabetes, PCOS or obesity?",
                                "We offer lifestyle and habit guidance around these conditions. All medical decisions must be taken with your doctor.",
                              ),

                              const SizedBox(height: 26),

                              // ---------- CTA BANNER ----------
                              HoverScale(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1A237E),
                                        Color(0xFF0D47A1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              "Ready to design your new baseline?",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              "Take a 3-minute AI assessment and get your first personalised actions across food, movement, sleep and focus.",
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Wrap(
                                        direction: Axis.vertical,
                                        spacing: 8,
                                        children: [
                                          _primaryButton(
                                            "Start Assessment",
                                            () => _open(
                                                const AIPersonalPlanScreen()),
                                          ),
                                          _secondaryButton(
                                            "Open Dashboard",
                                            () =>
                                                _open(const DashboardScreen()),
                                            textColor: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // ---------- FOOTER ----------
                              Divider(
                                color: Colors.grey.withOpacity(0.3),
                                thickness: 1,
                              ),
                              const SizedBox(height: 20),

                              LayoutBuilder(
                                builder: (_, c) {
                                  final fourCols = c.maxWidth > 800;

                                  if (fourCols) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _footerColumn("Company", [
                                          _footerLink("About",
                                              () => _showInfoDialog(
                                                    "About WellnessHub",
                                                    "WellnessHub is an AI-powered lifestyle, wellness and spirituality companion bringing body, mind, focus and spirit into one operating system.",
                                                  )),
                                          _footerLink("Mission",
                                              () => _showInfoDialog(
                                                    "Mission",
                                                    "To make holistic wellness practical, affordable and culturally aware for every family.",
                                                  )),
                                        ]),
                                        const SizedBox(width: 40),
                                        _footerColumn("Platform", [
                                          _footerLink("Fitness",
                                              () => _open(const FitnessScreen())),
                                          _footerLink("Nutrition", () {
                                            _open(const NutritionScreen());
                                          }),
                                          _footerLink("Sleep", () {
                                            _open(const SleepScreen());
                                          }),
                                          _footerLink("Mental Health", () {
                                            _open(const MentalScreen());
                                          }),
                                          _footerLink("Spirituality", () {
                                            _open(const SpiritualityScreen());
                                          }),
                                        ]),
                                        const SizedBox(width: 40),
                                        _footerColumn("Tools", [
                                          _footerLink("AI Personal Plan", () {
                                            _open(const AIPersonalPlanScreen());
                                          }),
                                          _footerLink("Disease Prediction", () {
                                            _open(
                                                const DiseasePredictionScreen());
                                          }),
                                          _footerLink("Habit Tracker", () {
                                            _open(const HabitTrackerScreen());
                                          }),
                                          _footerLink("Focus & Detox", () {
                                            _open(const DigitalDetoxScreen());
                                          }),
                                        ]),
                                        const SizedBox(width: 40),
                                        _footerColumn("Support", [
                                          _footerLink("Contact",
                                              () => _showInfoDialog(
                                                    "Contact",
                                                    "For feedback, partnerships or support, write to: support@wellnesshub.app",
                                                  )),
                                          _footerLink("Privacy Policy",
                                              () => _showInfoDialog(
                                                    "Privacy Policy",
                                                    "We respect your privacy. Suggestions are informational only and do not replace professional care.",
                                                  )),
                                        ]),
                                      ],
                                    );
                                  } else {
                                    // Stacked footer on small screens
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _footerColumn("Company", [
                                          _footerLink("About",
                                              () => _showInfoDialog(
                                                    "About WellnessHub",
                                                    "WellnessHub is an AI-powered lifestyle, wellness and spirituality companion bringing body, mind, focus and spirit into one operating system.",
                                                  )),
                                          _footerLink("Mission",
                                              () => _showInfoDialog(
                                                    "Mission",
                                                    "To make holistic wellness practical, affordable and culturally aware for every family.",
                                                  )),
                                        ]),
                                        const SizedBox(height: 16),
                                        _footerColumn("Platform", [
                                          _footerLink(
                                              "Fitness",
                                              () =>
                                                  _open(const FitnessScreen())),
                                          _footerLink("Nutrition", () {
                                            _open(const NutritionScreen());
                                          }),
                                          _footerLink("Sleep", () {
                                            _open(const SleepScreen());
                                          }),
                                        ]),
                                        const SizedBox(height: 16),
                                        _footerColumn("Tools", [
                                          _footerLink("AI Personal Plan", () {
                                            _open(const AIPersonalPlanScreen());
                                          }),
                                          _footerLink("Habit Tracker", () {
                                            _open(const HabitTrackerScreen());
                                          }),
                                        ]),
                                        const SizedBox(height: 16),
                                        _footerColumn("Support", [
                                          _footerLink("Contact",
                                              () => _showInfoDialog(
                                                    "Contact",
                                                    "For feedback, partnerships or support, write to: support@wellnesshub.app",
                                                  )),
                                          _footerLink("Privacy Policy",
                                              () => _showInfoDialog(
                                                    "Privacy Policy",
                                                    "We respect your privacy. Suggestions are informational only and do not replace professional care.",
                                                  )),
                                        ]),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              _toolRow(
                                title: "Spirituality & happiness",
                                desc:
                                    "Support your inner peace and joy through mindful practices.",
                                icon: Icons.spa,
                                onTap: () => _open(const SpiritualityScreen()),
                              ),

                              const SizedBox(height: 18),
                              Center(
                                child: Text(
                                  "© ${DateTime.now().year} WellnessHub. All rights reserved.",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[500]),
                                ),
                              ),
                              const SizedBox(height: 8),
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
}

// ---------------- SMALL REUSABLE WIDGETS ----------------

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return HoverScale(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.96),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 8,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodySmall?.color),
            ),
          ],
        ),
      ),
    );
  }
}

/// HoverScale gives a subtle scale animation on web hover.
/// On mobile, it simply keeps the child normal but still animated when rebuilt.
class HoverScale extends StatefulWidget {
  final Widget child;
  const HoverScale({super.key, required this.child});

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final enableHover = kIsWeb;
    final scale = enableHover && _hovering ? 1.03 : 1.0;

    Widget content = AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: widget.child,
    );

    if (!enableHover) return content;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: content,
    );
  }
}
