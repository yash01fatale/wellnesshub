import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data);
  }

  Stream<DocumentSnapshot> getUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }
}
