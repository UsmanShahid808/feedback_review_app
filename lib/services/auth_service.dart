import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';

/// Wraps Firebase Authentication and keeps a matching user profile
/// document in Firestore (users/{uid}) so we can store role (admin/user)
/// and display name.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(user.uid, doc.data()!);
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;

      // First registered account becomes admin automatically for demo
      // purposes; adjust this rule for your real organization.
      final usersSnap = await _db.collection('users').limit(1).get();
      final isFirstUser = usersSnap.docs.isEmpty;

      final appUser = AppUser(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        isAdmin: isFirstUser,
      );
      await _db.collection('users').doc(uid).set(appUser.toMap());
      await cred.user!.updateDisplayName(name.trim());
      return null; // no error
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign up failed. Please try again.';
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign in failed. Please try again.';
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Could not send reset email.';
    }
  }
}
