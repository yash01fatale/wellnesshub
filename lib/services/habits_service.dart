import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitsService {
  final _db = FirebaseFirestore.instance;

  Future<void> addHabit(String title) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = _db.collection('users').doc(uid).collection('habits').doc();
    await doc.set({
      'title': title,
      'streak': 0,
      'completedToday': false,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamHabits() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('habits').snapshots();
  }

  Future<void> toggleCompleted(String habitId, bool completed) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = _db.collection('users').doc(uid).collection('habits').doc(habitId);
    await ref.update({
      'completedToday': completed,
      'lastUpdated': FieldValue.serverTimestamp(),
      'streak': FieldValue.increment(completed ? 1 : -1),
    });
  }

  Future<void> deleteHabit(String habitId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _db.collection('users').doc(uid).collection('habits').doc(habitId).delete();
  }
}
