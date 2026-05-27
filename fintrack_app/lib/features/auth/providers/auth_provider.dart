import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../shared/models/user_model.dart';
import '../data/auth_repository.dart';
import '../../../core/services/push_notification_service.dart';

// Auth state
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      );
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref,
  );
});

// Convenience provider: is the user logged in?
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final Ref _ref;

  AuthNotifier(this._repo, this._ref) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final token = await SecureStorageService.getToken();
    final userJson = await SecureStorageService.getUser();

    if (token != null && userJson != null) {
      try {
        final user = UserModel.fromJsonString(userJson);
        state = state.copyWith(user: user, isAuthenticated: true);
        
        // Initialize push notification simulated permissions & register dynamic device token
        await _ref.read(pushNotificationServiceProvider).init();
        await _ref.read(pushNotificationServiceProvider).registerDeviceToken();

        // Refresh user from API
        final freshUser = await _repo.getMe();
        await SecureStorageService.saveUser(freshUser.toJsonString());
        state = state.copyWith(user: freshUser, isAuthenticated: true);
      } catch (_) {
        await SecureStorageService.clearAll();
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repo.login(email: email, password: password);
      await SecureStorageService.saveToken(result.token);
      await SecureStorageService.saveUser(result.user.toJsonString());
      state = state.copyWith(
        user: result.user,
        isAuthenticated: true,
        isLoading: false,
      );

      // Register push token upon successful login
      await _ref.read(pushNotificationServiceProvider).registerDeviceToken();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repo.register(name: name, email: email, password: password);
      await SecureStorageService.saveToken(result.token);
      await SecureStorageService.saveUser(result.user.toJsonString());
      state = state.copyWith(
        user: result.user,
        isAuthenticated: true,
        isLoading: false,
      );

      // Register push token upon successful registration
      await _ref.read(pushNotificationServiceProvider).registerDeviceToken();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      // Unregister token from backend before clearing credentials
      await _ref.read(pushNotificationServiceProvider).unregisterDeviceToken();
      await _repo.logout();
    } catch (_) {
      // Even if the API call fails, clear local state
    } finally {
      await SecureStorageService.clearAll();
      state = const AuthState();
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.forgotPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }
}
