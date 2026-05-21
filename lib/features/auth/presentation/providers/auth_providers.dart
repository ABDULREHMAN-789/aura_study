import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_study/features/auth/domain/user_model.dart';
import 'package:aura_study/features/auth/data/auth_repository.dart';

/// Provider for the AuthRepository layer
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// StreamProvider listening to authentications session states
final authStateProvider = StreamProvider<AuraUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// StateNotifier capturing loading/error states during async auth operations
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  /// Authenticate with email & security cypher key
  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Synthesize new user profile node
  Future<bool> register(String email, String password, String displayName) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signUpWithEmailAndPassword(email, password, displayName);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Issue standard password recovery link email
  Future<bool> recoverPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Purge/terminate current active credentials session
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
