// lib/services/stats_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatsService {
  final _db = FirebaseFirestore.instance;

  Future<void> setDailyStats(Map<String, dynamic> data, {DateTime? date}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not signed in");
    final dayId = (date ?? DateTime.now()).toIso8601String().split('T').first;
    await _db.collection('users').doc(user.uid).collection('daily_stats').doc(dayId).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDailyStats({DateTime? date}) async {
    final user = FirebaseAuth.instance.currentUser!;
    final dayId = (date ?? DateTime.now()).toIso8601String().split('T').first;
    return _db.collection('users').doc(user.uid).collection('daily_stats').doc(dayId).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamLast7Days() {
    final user = FirebaseAuth.instance.currentUser!;
    final coll = _db.collection('users').doc(user.uid).collection('daily_stats');
    return coll.orderBy('updatedAt', descending: true).limit(7).snapshots();
  }
}
