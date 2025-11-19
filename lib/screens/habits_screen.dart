// lib/screens/habits_screen.dart
// Final HabitsScreen — responsive, robust, and feature-complete
// Features: add/edit/delete/undo, duplicate prevention (case-insensitive),
// filters (category dropdown), status filter, search, responsive compact UI.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

// Make sure these files exist or adjust imports.
import 'nutrition_screen.dart';
import 'fitness_screen.dart';
import 'sleep_screen.dart';
import 'mental_screen.dart';
import 'spirituality_screen.dart';
import 'addiction_recovery_screen.dart';
import 'focus_screen.dart';
import 'women_wellness_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  String? userId;
  int xp = 0;
  int userLevel = 1;

  // categories used by filter and create/edit
  static const List<String> _kCategories = [
    'Health',
    'Study',
    'Mindfulness',
    'Productivity',
    'Personal',
    'AI Suggestion',
  ];

  static const List<Map<String, dynamic>> _kWellnessCategories = [
    {"name": "Nutrition", "icon": Icons.restaurant, "color": Colors.orange},
    {"name": "Fitness", "icon": Icons.fitness_center, "color": Colors.green},
    {"name": "Sleep", "icon": Icons.bed, "color": Colors.blue},
    {"name": "Mental Health", "icon": Icons.self_improvement, "color": Colors.purple},
    {"name": "Addiction", "icon": Icons.smoke_free, "color": Colors.red},
    {"name": "Spirituality", "icon": Icons.spa, "color": Colors.teal},
    {"name": "Focus", "icon": Icons.lock_clock, "color": Colors.indigo},
    {"name": "Women Wellness", "icon": Icons.female, "color": Colors.pink},
  ];

  final List<String> aiSuggestions = const [
    "Drink 3L Water",
    "10-minute Meditation",
    "Read 5 Pages",
    "15 Push-ups",
    "No Sugar Today",
    "Gratitude Note",
    "20-minute Walk",
    "Journal for 5 mins",
    "Sleep before 11 PM",
    "Avoid Mobile for 1 Hour",
    "Deep Breathing 4-7-8",
    "No Smoking Today",
  ];

  // UI state
  String _search = '';
  String _categoryFilter = 'All'; // Dropdown chosen by user
  String _statusFilter = 'All'; // All / Completed / Pending

  Timer? _dailyResetTimer;

  // Undo storage
  Map<String, dynamic>? _lastDeletedData;
  String? _lastDeletedDocId;

  // unified button style
  final ButtonStyle _primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(fontWeight: FontWeight.w600),
  );

  @override
  void initState() {
    super.initState();
    // Listen to auth changes — safe on web & mobile
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        userId = user?.uid;
      });
      _startDailyResetTimerIfNeeded();
    });
  }

  @override
  void dispose() {
    _dailyResetTimer?.cancel();
    super.dispose();
  }

  void _startDailyResetTimerIfNeeded() {
    _dailyResetTimer?.cancel();
    if (userId == null) return;
    _dailyResetTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day, 0, 0);
      final minutesSinceMidnight = DateTime.now().difference(midnight).inMinutes;
      if (minutesSinceMidnight >= 0 && minutesSinceMidnight < 2) {
        try {
          final snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).collection('habit_logs').get();
          for (final d in snapshot.docs) {
            await d.reference.update({'completed': false});
          }
        } catch (_) {
          // ignore errors
        }
      }
    });
  }

  void _addXP() {
    setState(() {
      xp += 10;
      if (xp >= userLevel * 100) {
        xp = 0;
        userLevel++;
      }
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isTablet = constraints.maxWidth > 600;
      final isDesktop = constraints.maxWidth > 900;
      final horizontalPadding = isDesktop ? 120.0 : isTablet ? 40.0 : 16.0;

      return Scaffold(
        backgroundColor: Colors.deepPurple.shade50,
        appBar: AppBar(
          title: const Text('Habit center'),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // first row: compact level + (maybe) chart
            LayoutBuilder(builder: (ctx, inner) {
              final wide = inner.maxWidth > 700;
              return wide
                  ? Row(children: [
                      Expanded(flex: 1, child: _buildUserLevelCard(compact: true)),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: _buildHabitAnalyticsCard(compact: true)),
                    ])
                  : Column(children: [ _buildUserLevelCard(compact: true), const SizedBox(height: 12), _buildHabitAnalyticsCard(compact: false) ]);
            }),
            const SizedBox(height: 16),

            // compact wellness tiles grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isDesktop ? 4 : isTablet ? 3 : 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.6,
              children: _kWellnessCategories.map((c) => _buildWellnessTile(c)).toList(),
            ),

            const SizedBox(height: 14),

            // Filters row (Dropdown category filter + status + search)
            _buildFiltersRow(),

            const SizedBox(height: 12),
            _buildAISuggestions(),
            const SizedBox(height: 12),

            const Text('Your Habits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _habitList(),

            const SizedBox(height: 80),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add),
          onPressed: () => _showAddEditDialog(context),
        ),
      );
    });
  }

  // ----------------------------
  // Filters row (Option B: Dropdown)
  // ----------------------------
  Widget _buildFiltersRow() {
    return Row(children: [
      // Category dropdown
      Expanded(
        flex: 3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _categoryFilter,
              isExpanded: true,
              items: ['All', ..._kCategories].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _categoryFilter = v ?? 'All'),
            ),
          ),
        ),
      ),

      const SizedBox(width: 8),

      // Status dropdown
      Expanded(
        flex: 2,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _statusFilter,
              isExpanded: true,
              items: ['All', 'Completed', 'Pending'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _statusFilter = v ?? 'All'),
            ),
          ),
        ),
      ),

      const SizedBox(width: 8),

      // Search
      Expanded(
        flex: 4,
        child: TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search habits...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
          onChanged: (v) => setState(() => _search = v.trim()),
        ),
      ),
    ]);
  }

  // ----------------------------
  // Wellness tile
  // ----------------------------
  Widget _buildWellnessTile(Map<String, dynamic> c) {
    final color = (c['color'] as Color?) ?? Colors.grey;
    final icon = (c['icon'] as IconData?) ?? Icons.help_outline;
    final name = (c['name'] as String?) ?? 'Module';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        switch (name) {
          case 'Nutrition':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionScreen()));
            break;
          case 'Fitness':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FitnessScreen()));
            break;
          case 'Sleep':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepScreen()));
            break;
          case 'Mental Health':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MentalScreen()));
            break;
          case 'Addiction':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddictionRecoveryScreen()));
            break;
          case 'Spirituality':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SpiritualityScreen()));
            break;
          case 'Focus':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FocusScreen()));
            break;
          case 'Women Wellness':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WomenWellnessScreen()));
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open $name')));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.16), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
        ]),
      ),
    );
  }

  // ----------------------------
  // Level card
  // ----------------------------
  Widget _buildUserLevelCard({bool compact = false}) {
    final progress = (userLevel * 100) > 0 ? (xp / (userLevel * 100)).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 18),
      decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        CircleAvatar(radius: compact ? 22 : 28, backgroundColor: Colors.white24, child: const Icon(Icons.star, color: Colors.white)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Level $userLevel', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.white24, color: Colors.yellowAccent, minHeight: compact ? 8 : 10),
          const SizedBox(height: 6),
          Text('$xp / ${userLevel * 100} XP', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ])),
        IconButton(icon: const Icon(Icons.auto_awesome, color: Colors.white), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perks coming soon')))),
      ]),
    );
  }

  // ----------------------------
  // Habit analytics (small)
  // ----------------------------
  Widget _buildHabitAnalyticsCard({bool compact = false}) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Weekly Consistency', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: compact ? 110 : 160,
            child: LineChart(LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= days.length) return const SizedBox.shrink();
                      return Text(days[i], style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 8,
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  spots: const [
                    FlSpot(0, 2),
                    FlSpot(1, 3),
                    FlSpot(2, 5),
                    FlSpot(3, 2.5),
                    FlSpot(4, 4),
                    FlSpot(5, 5),
                    FlSpot(6, 6),
                  ],
                  color: Colors.deepPurple,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: Colors.deepPurple.withOpacity(0.14)),
                ),
              ],
            )),
          ),
        ]),
      ),
    );
  }

  // ----------------------------
  // AI suggestions + Add (dedupe case-insensitive)
  // ----------------------------
  Widget _buildAISuggestions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('AI Suggested Habits 🤖', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Column(children: aiSuggestions.map((s) {
        return Card(
          elevation: 1,
          child: ListTile(
            title: Text(s, style: const TextStyle(fontSize: 14)),
            trailing: ElevatedButton(
              style: _primaryButtonStyle,
              onPressed: () => _addAIHabit(s),
              child: const Text('Add'),
            ),
          ),
        );
      }).toList()),
    ]);
  }

  Future<void> _addAIHabit(String habit) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to add habits')));
      return;
    }

    final lower = habit.toLowerCase();
    try {
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('habit_logs')
          .where('habit_name_lower', isEqualTo: lower)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit already added')));
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).collection('habit_logs').add({
        'habit_name': habit,
        'habit_name_lower': lower,
        'category': 'AI Suggestion',
        'completed': false,
        'streak': 0,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit added')));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add habit')));
    }
  }

  // ----------------------------
  // Habit list with client-side filtering & safe parsing
  // ----------------------------
  Widget _habitList() {
    if (userId == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(children: [
          const Text('Sign in to see your habits', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          ElevatedButton(style: _primaryButtonStyle, onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open sign-in'))), child: const Text('Sign in')),
        ]),
      );
    }

    final stream = FirebaseFirestore.instance.collection('users').doc(userId).collection('habit_logs').orderBy('timestamp', descending: true).snapshots();

    return StreamBuilder<QuerySnapshot>(stream: stream, builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator()));
      }

      final docs = snap.data?.docs ?? [];
      final items = docs.map((d) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(d.data() as Map<String, dynamic>);
        data['__id'] = d.id;
        return data;
      }).toList();

      // apply category filter (safe)
      final filteredByCategory = (_categoryFilter == 'All')
          ? items
          : items.where((it) {
              final cat = (it['category'] is String) ? it['category'] as String : '';
              return cat == _categoryFilter;
            }).toList();

      // apply status filter
      final filteredByStatus = filteredByCategory.where((it) {
        final completed = (it['completed'] is bool) ? it['completed'] as bool : false;
        if (_statusFilter == 'All') return true;
        if (_statusFilter == 'Completed') return completed;
        return !completed;
      }).toList();

      // apply search (safe)
      final searchLower = _search.toLowerCase();
      final searched = searchLower.isEmpty
          ? filteredByStatus
          : filteredByStatus.where((it) {
              final name = (it['habit_name'] is String) ? (it['habit_name'] as String).toLowerCase() : '';
              return name.contains(searchLower);
            }).toList();

      if (searched.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text('No habits found.'));

      return Column(children: searched.map((d) => _buildHabitCardFromDataSafe(d)).toList());
    });
  }

  // ----------------------------
  // Build habit card with safety (null-safe)
  // ----------------------------
  Widget _buildHabitCardFromDataSafe(Map<String, dynamic> data) {
    final id = (data['__id'] is String) ? data['__id'] as String : UniqueKey().toString();
    final completed = (data['completed'] is bool) ? data['completed'] as bool : false;
    final streak = (data['streak'] is int) ? data['streak'] as int : 0;
    final name = (data['habit_name'] is String) ? data['habit_name'] as String : '';
    final category = (data['category'] is String) ? data['category'] as String : 'Personal';

    return Dismissible(
      key: Key(id),
      background: Container(color: Colors.redAccent, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final res = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
          title: const Text('Delete habit'),
          content: const Text('Are you sure you want to delete this habit?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
          ],
        ));
        return res ?? false;
      },
      onDismissed: (_) => _deleteHabitWithUndo(id, data),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: CircleAvatar(radius: 20, backgroundColor: completed ? Colors.green : Colors.grey.shade300, child: Icon(completed ? Icons.check : Icons.circle_outlined, color: completed ? Colors.white : Colors.grey)),
          title: Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          subtitle: Text('$category • 🔥 Streak: $streak days', style: const TextStyle(fontSize: 12)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            ElevatedButton(style: _primaryButtonStyle, onPressed: () => _toggleHabit(id, data), child: Text(completed ? 'Done' : 'Mark')),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _confirmAndDelete(id, data)),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') _showAddEditDialog(context, docId: id, existing: data);
                if (v == 'delete') _confirmAndDelete(id, data);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  // ----------------------------
  // Delete helpers with Undo
  // ----------------------------
  Future<void> _confirmAndDelete(String id, Map<String, dynamic> data) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Delete habit'),
      content: const Text('Delete this habit?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
      ],
    ));
    if (ok ?? false) await _deleteHabitWithUndo(id, data);
  }

  Future<void> _deleteHabitWithUndo(String id, Map<String, dynamic> data) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in to delete habits')));
      return;
    }
    _lastDeletedDocId = id;
    _lastDeletedData = Map<String, dynamic>.from(data);
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('habit_logs').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Habit deleted'),
        action: SnackBarAction(label: 'Undo', textColor: Colors.yellow, onPressed: () async {
          if (_lastDeletedData != null) {
            final restored = Map<String, dynamic>.from(_lastDeletedData!);
            restored.remove('__id');
            try {
              await FirebaseFirestore.instance.collection('users').doc(userId).collection('habit_logs').add(restored);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit restored')));
            } catch (_) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore failed')));
            }
          }
        }),
      ));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete habit')));
    }
  }

  // ----------------------------
  // Toggle completed & update streak
  // ----------------------------
  Future<void> _toggleHabit(String id, Map<String, dynamic> data) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in to update habits')));
      return;
    }
    final completed = (data['completed'] is bool) ? data['completed'] as bool : false;
    int streak = (data['streak'] is int) ? data['streak'] as int : 0;

    if (!completed) {
      streak++;
      _addXP();
      HapticFeedback.lightImpact();
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('habit_logs').doc(id).update({
        'completed': !completed,
        'streak': streak,
        'timestamp': Timestamp.now(),
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update habit')));
    }
  }

  // ----------------------------
  // Add / Edit dialog (reuse)
  // ----------------------------
  void _showAddEditDialog(BuildContext context, {String? docId, Map<String, dynamic>? existing}) {
    final TextEditingController ctrl = TextEditingController(text: existing != null && existing['habit_name'] is String ? existing['habit_name'] as String : '');
    String category = existing != null && existing['category'] is String ? existing['category'] as String : _kCategories.first;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(docId == null ? 'Create Habit' : 'Edit Habit'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Habit Name')),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: category,
              isExpanded: true,
              items: ['AI Suggestion', ..._kCategories].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => category = v ?? category),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(style: _primaryButtonStyle, onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in to save habits')));
                return;
              }

              final lower = name.toLowerCase();
              try {
                // check duplicates excluding self if editing
                final query = await FirebaseFirestore.instance.collection('users').doc(userId).collection('habit_logs').where('habit_name_lower', isEqualTo: lower).get();
                final duplicates = query.docs.where((d) => d.id != docId).toList();
                if (duplicates.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit already exists')));
                  return;
                }

                if (docId == null) {
                  // create
                  await FirebaseFirestore.instance.collection('users').doc(userId).collection('habit_logs').add({
                    'habit_name': name,
                    'habit_name_lower': lower,
                    'category': category,
                    'completed': false,
                    'streak': 0,
                    'timestamp': Timestamp.now(),
                  });
                } else {
                  // update
                  await FirebaseFirestore.instance.collection('users').doc(userId).collection('habit_logs').doc(docId).update({
                    'habit_name': name,
                    'habit_name_lower': lower,
                    'category': category,
                    'timestamp': Timestamp.now(),
                  });
                }
                Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save habit')));
              }
            }, child: const Text('Save')),
          ],
        );
      }),
    );
  }
}
