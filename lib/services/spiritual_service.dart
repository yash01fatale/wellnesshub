// lib/services/spiritual_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SpiritualService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _uidOrThrow() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not signed in");
    return user.uid;
  }

  // Save affirmation entry
  Future<void> saveAffirmation(String text) async {
    final uid = _uidOrThrow();
    final doc = _db.collection('users').doc(uid).collection('spiritual').doc();
    await doc.set({
      'type': 'affirmation',
      'text': text,
      'time': FieldValue.serverTimestamp(),
    });
  }

  // Save gratitude entry
  Future<void> saveGratitude(String text) async {
    final uid = _uidOrThrow();
    final doc = _db.collection('users').doc(uid).collection('spiritual').doc();
    await doc.set({
      'type': 'gratitude',
      'text': text,
      'time': FieldValue.serverTimestamp(),
    });
    await _incrementStreak(uid, 'gratitude_streak');
  }

  // Save journal entry
  Future<void> saveJournal(String title, String body) async {
    final uid = _uidOrThrow();
    final doc = _db.collection('users').doc(uid).collection('journals').doc();
    await doc.set({
      'title': title,
      'body': body,
      'time': FieldValue.serverTimestamp(),
    });
  }

  // Record meditation session
  Future<void> logMeditation(int minutes) async {
    final uid = _uidOrThrow();
    final doc = _db.collection('users').doc(uid).collection('spiritual_logs').doc();
    await doc.set({
      'type': 'meditation',
      'minutes': minutes,
      'time': FieldValue.serverTimestamp(),
    });
    await _incrementStreak(uid, 'meditation_streak');
  }

  // Record breathwork session
  Future<void> logBreathwork(int cycles) async {
    final uid = _uidOrThrow();
    final doc = _db.collection('users').doc(uid).collection('spiritual_logs').doc();
    await doc.set({
      'type': 'breathwork',
      'cycles': cycles,
      'time': FieldValue.serverTimestamp(),
    });
    await _incrementStreak(uid, 'breathwork_streak');
  }

  // Generic streak increment: stores lastDate and streak count
  Future<void> _incrementStreak(String uid, String streakField) async {
    final docRef = _db.collection('users').doc(uid).collection('meta').doc(streakField);
    final snap = await docRef.get();
    final today = DateTime.now();
    final todayKey = "${today.year}-${today.month}-${today.day}";
    if (!snap.exists) {
      await docRef.set({'streak': 1, 'lastDate': todayKey});
      return;
    }
    final data = snap.data()!;
    final lastDate = data['lastDate'] as String? ?? '';
    if (lastDate == todayKey) {
      // already incremented today - do nothing
      return;
    } else {
      // if lastDate is yesterday then increment else reset to 1
      final parts = lastDate.split('-');
      if (parts.length == 3) {
        final last = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        final diff = today.difference(last).inDays;
        if (diff == 1) {
          await docRef.update({'streak': FieldValue.increment(1), 'lastDate': todayKey});
          return;
        }
      }
      // reset
      await docRef.set({'streak': 1, 'lastDate': todayKey});
    }
  }

  // Get streak value stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> streakStream(String streakField) {
    final uid = _uidOrThrow();
    return _db.collection('users').doc(uid).collection('meta').doc(streakField).snapshots();
  }

  // Fetch last N spiritual entries
  Stream<QuerySnapshot<Map<String, dynamic>>> streamSpiritualEntries({int limit = 20}) {
    final uid = _uidOrThrow();
    return _db
        .collection('users')
        .doc(uid)
        .collection('spiritual')
        .orderBy('time', descending: true)
        .limit(limit)
        .snapshots();
  }
}
