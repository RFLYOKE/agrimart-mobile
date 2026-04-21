import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

sealed class AuthState {}
class Unauthenticated extends AuthState {}
class Loading extends AuthState {}
class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);
}
class Error extends AuthState {
  final String message;
  Error(this.message);
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<AuthState> {
  late FlutterSecureStorage _secureStorage;
  late AuthRepository _repository;

  @override
  Future<AuthState> build() async {
    _secureStorage = const FlutterSecureStorage();
    _repository = ref.read(authRepositoryProvider);
    
    // Inject logout callback to DioClient interceptor here
    DioClient.instance.onLogoutCallback = () {
      state = AsyncValue.data(Unauthenticated());
    };

    try {
      return await _checkAuth();
    } catch (e) {
      print('Auth check error: $e');
      return Unauthenticated();
    }
  }

  Future<AuthState> _checkAuth() async {
    print("DEBUG: _checkAuth started");
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      print("DEBUG: _secureStorage.read completed, token: $accessToken");
      
      if (accessToken != null && accessToken.isNotEmpty) {
        if (JwtDecoder.isExpired(accessToken)) {
          // Try refresh
          final refreshToken = await _secureStorage.read(key: 'refresh_token');
          if (refreshToken != null) {
            try {
              final res = await _repository.refreshToken(refreshToken);
              await _secureStorage.write(key: 'access_token', value: res['data']['access_token']);
              if (res['data']['refresh_token'] != null) {
                await _secureStorage.write(key: 'refresh_token', value: res['data']['refresh_token']);
              }
              final user = await _repository.getMe();
              return Authenticated(user);
            } catch (e) {
              await _secureStorage.deleteAll();
              return Unauthenticated();
            }
          }
        } else {
          try {
            final user = await _repository.getMe();
            return Authenticated(user);
          } catch (e) {
             return Unauthenticated();
          }
        }
      }
    } catch (e) {
      print("DEBUG: _checkAuth caught error: $e");
      return Unauthenticated();
    }
    return Unauthenticated();
  }

  UserModel? get currentUser {
    final currentState = state.value;
    if (currentState is Authenticated) {
      return currentState.user;
    }
    return null;
  }

  Future<void> loginWithEmail(String email, String password) async {
    state = AsyncValue.data(Loading());
    try {
      final res = await _repository.loginWithEmail(email, password);
      final tokens = res['data'];
      await _secureStorage.write(key: 'access_token', value: tokens['access_token']);
      await _secureStorage.write(key: 'refresh_token', value: tokens['refresh_token']);
      
      final user = await _repository.getMe();
      state = AsyncValue.data(Authenticated(user));
    } catch (e) {
      state = AsyncValue.data(Error(e.toString()));
    }
  }

  Future<void> loginWithPhone(String phone, String otp, {String? name, String? role}) async {
    state = AsyncValue.data(Loading());
    try {
      final res = await _repository.verifyOtp(phone, otp, name: name, role: role);
      final tokens = res['data'];
      await _secureStorage.write(key: 'access_token', value: tokens['access_token']);
      await _secureStorage.write(key: 'refresh_token', value: tokens['refresh_token']);
      
      final user = await _repository.getMe();
      state = AsyncValue.data(Authenticated(user));
    } catch (e) {
      state = AsyncValue.data(Error(e.toString()));
    }
  }

  Future<void> loginWithGoogle({String? role}) async {
    state = AsyncValue.data(Loading());
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        state = AsyncValue.data(Unauthenticated());
        return; // User canceled
      }
      
      final GoogleSignInAuthentication googleAuth = await account.authentication;
      if (googleAuth.idToken == null) throw Exception('Google ID Token missing');

      final res = await _repository.loginWithGoogle(googleAuth.idToken!, role: role);
      final tokens = res['data'];
      await _secureStorage.write(key: 'access_token', value: tokens['access_token']);
      await _secureStorage.write(key: 'refresh_token', value: tokens['refresh_token']);
      
      final user = await _repository.getMe();
      state = AsyncValue.data(Authenticated(user));
    } catch (e) {
      state = AsyncValue.data(Error(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {}
    await _secureStorage.deleteAll();
    state = AsyncValue.data(Unauthenticated());
  }
}
