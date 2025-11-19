// lib/screens/community_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _searchCtl = TextEditingController();
  List<Map<String, dynamic>> _challenges = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;

  // Mock leaderboard / discussions
  final List<Map<String, dynamic>> _leaders = [
    {'name': 'Aisha', 'score': 320},
    {'name': 'Riya', 'score': 295},
    {'name': 'Vikram', 'score': 270},
  ];

  final List<Map<String, dynamic>> _discussions = [
    {'title': 'How to do 10k steps daily?', 'replies': 12},
    {'title': 'Healthy snacks on a budget', 'replies': 7},
  ];

  @override
  void initState() {
    super.initState();
    _loadMockChallenges();
    _searchCtl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtl.removeListener(_applyFilter);
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _loadMockChallenges() async {
    // Try to load saved joined state from SharedPreferences (simple persistence)
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('community_challenges_v1');
    // If you want Firestore integration, replace this block with a firestore fetch and map documents to the same structure.

    // default mock data
    _challenges = [
      {
        'id': 'c1',
        'title': '10k Steps Challenge',
        'description': 'Walk 10,000 steps daily for 7 days.',
        'participants': 52,
        'joined': saved?.contains('c1') ?? false,
        'progress': 80, // percent
        'days': 7
      },
      {
        'id': 'c2',
        'title': '7-Day Mindful',
        'description': 'Daily 10-minute meditation for 7 days.',
        'participants': 32,
        'joined': saved?.contains('c2') ?? true,
        'progress': 50,
        'days': 7
      },
      {
        'id': 'c3',
        'title': 'No Sugar Week',
        'description': 'Avoid added sugar for 7 days.',
        'participants': 18,
        'joined': saved?.contains('c3') ?? false,
        'progress': 20,
        'days': 7
      },
    ];

    setState(() {
      _filtered = List.from(_challenges);
      _loading = false;
    });
  }

  void _applyFilter() {
    final q = _searchCtl.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtered = List.from(_challenges));
      return;
    }
    setState(() {
      _filtered = _challenges.where((c) {
        return c['title'].toString().toLowerCase().contains(q) ||
            c['description'].toString().toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _toggleJoin(Map<String, dynamic> c) async {
    setState(() => c['joined'] = !(c['joined'] as bool));
    // update local persistence
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('community_challenges_v1')?.toSet() ?? <String>{};
    if (c['joined'] as bool) {
      saved.add(c['id'] as String);
      // increment participants for UX
      c['participants'] = (c['participants'] as int) + 1;
    } else {
      saved.remove(c['id'] as String);
      c['participants'] = (c['participants'] as int) - 1;
    }
    await prefs.setStringList('community_challenges_v1', saved.toList());
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(c['joined'] ? 'Joined "${c['title']}"' : 'Left "${c['title']}"')),
    );

    // TODO: When integrating backend, also call Firestore to update participant lists,
    // and add an activity / join event for analytics.
  }

  void _openCreateDialog() {
    final title = TextEditingController();
    final desc = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Challenge'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 8),
          TextField(controller: desc, decoration: const InputDecoration(labelText: 'Short description')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final t = title.text.trim();
              final d = desc.text.trim();
              if (t.isEmpty) return;
              final newC = {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'title': t,
                'description': d,
                'participants': 1,
                'joined': true,
                'progress': 0,
                'days': 7
              };
              setState(() {
                _challenges.insert(0, newC);
                _applyFilter();
              });
              Navigator.pop(context);
              // persist initial joined to prefs
              SharedPreferences.getInstance().then((prefs) {
                final s = prefs.getStringList('community_challenges_v1')?.toSet() ?? <String>{};
                s.add(newC['id'] as String);
                prefs.setStringList('community_challenges_v1', s.toList());
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Challenge created')));
              // TODO: Create document in Firestore in real implementation
            },
            child: const Text('Create'),
          )
        ],
      ),
    );
  }

  Widget _buildChallengeTile(Map<String, dynamic> c) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade50,
          child: Icon(Icons.flag, color: Colors.deepPurple),
        ),
        title: Text(c['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${c['description']} • ${c['participants']} participants'),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: c['joined'] ? Colors.green : Colors.deepPurple,
            minimumSize: const Size(88, 36),
          ),
          onPressed: () => _toggleJoin(c),
          child: Text(c['joined'] ? 'Joined' : 'Join'),
        ),
        onTap: () => _openChallengeDetails(c),
      ),
    );
  }

  void _openChallengeDetails(Map<String, dynamic> c) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: Text(c['title']), backgroundColor: Colors.deepPurple),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c['description'], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Row(children: [
              ElevatedButton.icon(
                onPressed: () => _toggleJoin(c),
                icon: Icon(c['joined'] ? Icons.check : Icons.add),
                label: Text(c['joined'] ? 'Leave' : 'Join'),
                style: ElevatedButton.styleFrom(backgroundColor: c['joined'] ? Colors.red : Colors.deepPurple),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(onPressed: () {/* TODO: share */}, icon: const Icon(Icons.share), label: const Text('Share')),
            ]),
            const SizedBox(height: 20),
            const Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: (c['progress'] as int) / 100.0, backgroundColor: Colors.grey.shade200),
            const SizedBox(height: 16),
            const Text('Discussion', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Recent posts & support messages will appear here (mock).'),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: () {/* TODO open discussion */}, child: const Text('Open Discussion')),
          ]),
        ),
      );
    }));
  }

  Widget _buildLeaderboardCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._leaders.map((l) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [CircleAvatar(child: Text(l['name'][0])), const SizedBox(width: 8), Text(l['name'])]),
                  Text('${l['score']} pts', style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
              )),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {/* TODO view full */}, child: const Text('View all'))),
        ]),
      ),
    );
  }

  Widget _buildDiscussionPreview() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Community Discussions', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._discussions.map((d) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(d['title'] as String),
                subtitle: Text('${d['replies']} replies'),
                onTap: () {/* TODO open thread */},
              )),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {/* TODO */}, child: const Text('Explore all threads'))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Hub'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(onPressed: _openCreateDialog, icon: const Icon(Icons.add)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: isWide
                    ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(
                          flex: 2,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _searchBar(),
                            const SizedBox(height: 12),
                            ..._filtered.map(_buildChallengeTile),
                            const SizedBox(height: 12),
                          ]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Column(children: [
                            _buildLeaderboardCard(),
                            const SizedBox(height: 12),
                            _buildDiscussionPreview(),
                          ]),
                        ),
                      ])
                    : Column(children: [
                        _searchBar(),
                        const SizedBox(height: 12),
                        ..._filtered.map(_buildChallengeTile),
                        const SizedBox(height: 12),
                        _buildLeaderboardCard(),
                        const SizedBox(height: 12),
                        _buildDiscussionPreview(),
                      ]),
              );
            }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateDialog,
        label: const Text('Create Challenge'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _searchBar() {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: _searchCtl,
          decoration: InputDecoration(
            hintText: 'Search challenges or topics',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
          ),
        ),
      ),
      const SizedBox(width: 8),
      PopupMenuButton<String>(
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'all', child: Text('All')),
          PopupMenuItem(value: 'joined', child: Text('Joined')),
          PopupMenuItem(value: 'popular', child: Text('Popular')),
        ],
        onSelected: (v) {
          if (v == 'joined') {
            setState(() => _filtered = _challenges.where((c) => c['joined'] == true).toList());
          } else if (v == 'popular') {
            setState(() => _filtered = List.from(_challenges)..sort((a, b) => (b['participants'] as int).compareTo(a['participants'] as int)));
          } else {
            _applyFilter();
          }
        },
        icon: const Icon(Icons.filter_list),
      )
    ]);
  }
}
