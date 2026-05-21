import 'package:flutter_test/flutter_test.dart';
import 'package:aura_study/features/auth/domain/user_model.dart';
import 'package:aura_study/features/auth/data/auth_repository.dart';

void main() {
  group('Auth Model Tests', () {
    test('AuraUser.mock creates a valid user with correct premium status', () {
      final premiumUser = AuraUser.mock(
        uid: 'user-123',
        email: 'premium@example.com',
        displayName: 'Premium Dev',
        isPremium: true,
      );

      expect(premiumUser.uid, 'user-123');
      expect(premiumUser.email, 'premium@example.com');
      expect(premiumUser.displayName, 'Premium Dev');
      expect(premiumUser.isPremium, true);
      expect(premiumUser.createdAt, isNotNull);
    });

    test('AuraUser serialization/deserialization', () {
      final user = AuraUser(
        uid: 'user-456',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        isPremium: false,
        createdAt: DateTime(2026, 5, 21),
      );

      final json = user.toJson();
      expect(json['uid'], 'user-456');
      expect(json['email'], 'test@example.com');
      expect(json['displayName'], 'Test User');
      expect(json['photoUrl'], 'https://example.com/photo.jpg');
      expect(json['isPremium'], false);
      expect(json['createdAt'], '2026-05-21T00:00:00.000');

      final deserialized = AuraUser.fromJson(json);
      expect(deserialized.uid, user.uid);
      expect(deserialized.email, user.email);
      expect(deserialized.displayName, user.displayName);
      expect(deserialized.photoUrl, user.photoUrl);
      expect(deserialized.isPremium, user.isPremium);
      expect(deserialized.createdAt, user.createdAt);
    });
  });

  group('FirebaseAuthRepository Mock Mode Tests', () {
    late FirebaseAuthRepository authRepository;

    setUp(() {
      authRepository = FirebaseAuthRepository();
    });

    test('Initial state is mock mode and has no user', () {
      expect(authRepository.isMockMode, isTrue);
      expect(authRepository.currentUser, isNull);
    });

    test('SignIn validates email and password constraints', () async {
      expect(
        () => authRepository.signInWithEmailAndPassword('invalid', '123456'),
        throwsA(isA<Exception>()),
      );

      expect(
        () => authRepository.signInWithEmailAndPassword('test@example.com', '123'),
        throwsA(isA<Exception>()),
      );
    });

    test('SignIn successfully signs in mock user', () async {
      final user = await authRepository.signInWithEmailAndPassword(
        'developer@example.com',
        'securePassword123',
      );

      expect(user.email, 'developer@example.com');
      expect(user.displayName, 'Developer');
      expect(authRepository.currentUser, isNotNull);
      expect(authRepository.currentUser!.uid, user.uid);
    });

    test('SignUp successfully registers a mock user', () async {
      final user = await authRepository.signUpWithEmailAndPassword(
        'scholar@example.com',
        'securePassword123',
        'Scholar Jane',
      );

      expect(user.email, 'scholar@example.com');
      expect(user.displayName, 'Scholar Jane');
      expect(authRepository.currentUser, isNotNull);
      expect(authRepository.currentUser!.uid, user.uid);
    });

    test('SignOut clears active mock session', () async {
      await authRepository.signInWithEmailAndPassword(
        'developer@example.com',
        'securePassword123',
      );
      expect(authRepository.currentUser, isNotNull);

      await authRepository.signOut();
      expect(authRepository.currentUser, isNull);
    });
  });
}
