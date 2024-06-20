import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add or update user data
  Future<void> postDetailsToFirestore({required String uid, required String email, required String role, required String name}) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'role': role,
      'name': name,
    });
  }

  // Get user data by UID
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  // Stream for fetching posters
  Stream<QuerySnapshot> getPostersStream() {
    return _firestore.collection('Posters').snapshots();
  }
}
