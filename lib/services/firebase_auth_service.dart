// lib/services/firebase_auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

/// Result wrapper so callers never need to catch at the UI layer.
class AuthResult {
  final bool success;
  final String? errorMessage;
  final User? user;

  const AuthResult._({
    required this.success,
    this.errorMessage,
    this.user,
  });

  factory AuthResult.ok(User user) => AuthResult._(success: true, user: user);

  factory AuthResult.fail(String message) =>
      AuthResult._(success: false, errorMessage: message);
}

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  // ── Auth state stream ────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ── Sign Up ──────────────────────────────────────────────────────
  Future<AuthResult> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      // Update display name in FirebaseAuth
      await user.updateDisplayName(name.trim());

      // Persist user document to Firestore
      final userModel = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        createdAt: DateTime.now(),
      );
      await _firestore.createUser(userModel);

      return AuthResult.ok(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapAuthError(e.code));
    } catch (e) {
      return AuthResult.fail('An unexpected error occurred. Please try again.');
    }
  }

  // ── Sign In ──────────────────────────────────────────────────────
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AuthResult.ok(credential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapAuthError(e.code));
    } catch (e) {
      return AuthResult.fail('An unexpected error occurred. Please try again.');
    }
  }

  // ── Sign Out ─────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Password Reset ───────────────────────────────────────────────
  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult._(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapAuthError(e.code));
    }
  }

  // ── Error mapper ─────────────────────────────────────────────────
  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
