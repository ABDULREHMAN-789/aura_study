import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:aura_study/features/auth/domain/user_model.dart';

abstract class AuthRepository {
  Stream<AuraUser?> get authStateChanges;
  AuraUser? get currentUser;
  Future<AuraUser> signInWithEmailAndPassword(String email, String password);
  Future<AuraUser> signUpWithEmailAndPassword(String email, String password, String displayName);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  bool get isMockMode;
}

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth? _firebaseAuth;
  bool _useMock = false;

  // Stream controller for mock auth changes
  final _mockStreamController = StreamController<AuraUser?>.broadcast();
  AuraUser? _mockUser;

  FirebaseAuthRepository() : _firebaseAuth = _getFirebaseAuthInstance() {
    _useMock = _firebaseAuth == null;
    if (_useMock) {
      // Seed a default unauthenticated state
      _mockUser = null;
      _mockStreamController.add(null);
    }
  }

  static fb.FirebaseAuth? _getFirebaseAuthInstance() {
    try {
      if (Firebase.apps.isNotEmpty) {
        return fb.FirebaseAuth.instance;
      }
    } catch (e) {
      // Firebase Core is present in pubspec but initialization was skipped
    }
    return null;
  }

  @override
  bool get isMockMode => _useMock;

  @override
  Stream<AuraUser?> get authStateChanges {
    if (_useMock) {
      return _mockStreamController.stream;
    }
    return _firebaseAuth!.authStateChanges().map((fbUser) {
      if (fbUser == null) return null;
      return AuraUser.fromFirebaseUser(fbUser);
    });
  }

  @override
  AuraUser? get currentUser {
    if (_useMock) {
      return _mockUser;
    }
    final fbUser = _firebaseAuth?.currentUser;
    if (fbUser == null) return null;
    return AuraUser.fromFirebaseUser(fbUser);
  }

  @override
  Future<AuraUser> signInWithEmailAndPassword(String email, String password) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 1200)); // Simulate cyber network delay

      // Simple mock validations
      if (!email.contains('@') || email.length < 5) {
        throw Exception('INVALID_COGNITIVE_CREDENTIAL: Email format is invalid.');
      }
      if (password.length < 6) {
        throw Exception('WEAK_CYPHER: Password must be at least 6 characters.');
      }

      // Successful simulated sign in
      final mockDisplayName = email.split('@')[0];
      final user = AuraUser.mock(
        uid: 'aura-mock-${email.hashCode}',
        email: email,
        displayName: mockDisplayName[0].toUpperCase() + mockDisplayName.substring(1),
        isPremium: email.contains('premium'),
      );
      _mockUser = user;
      _mockStreamController.add(user);
      return user;
    }

    try {
      final credential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw Exception('Firebase authentication returned an empty user.');
      }
      return AuraUser.fromFirebaseUser(credential.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during authentication.');
    }
  }

  @override
  Future<AuraUser> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 1400)); // Cyber network simulation

      if (!email.contains('@')) {
        throw Exception('INVALID_COGNITIVE_CREDENTIAL: Email format is invalid.');
      }
      if (password.length < 6) {
        throw Exception('WEAK_CYPHER: Security cypher key must be at least 6 characters.');
      }
      if (displayName.trim().isEmpty) {
        throw Exception('IDENTITY_REQUIRED: Cognitive identity name cannot be empty.');
      }

      final user = AuraUser(
        uid: 'aura-mock-${email.hashCode}',
        email: email,
        displayName: displayName,
        isPremium: email.contains('premium'),
        createdAt: DateTime.now(),
      );
      _mockUser = user;
      _mockStreamController.add(user);
      return user;
    }

    try {
      final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw Exception('Registration process failed to create user.');
      }
      // Update display name on Firebase
      await credential.user!.updateDisplayName(displayName);
      
      // Get updated user instance
      final updatedUser = _firebaseAuth.currentUser ?? credential.user!;
      return AuraUser.fromFirebaseUser(updatedUser);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failure occurred.');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!email.contains('@')) {
        throw Exception('INVALID_IDENTITY: Target communication link invalid.');
      }
      return;
    }

    try {
      await _firebaseAuth!.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Password recovery transmission failed.');
    }
  }

  @override
  Future<void> signOut() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      _mockUser = null;
      _mockStreamController.add(null);
      return;
    }
    await _firebaseAuth!.signOut();
  }
}
