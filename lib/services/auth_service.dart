import 'package:my_app/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  UserProfile? get profile =>
      currentUser != null ? UserProfile.fromUser(currentUser!) : null;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) {
    final data = <String, dynamic>{
      ...?currentUser?.userMetadata,
    };
    if (fullName != null) data['full_name'] = fullName;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    return _client.auth.updateUser(UserAttributes(data: data));
  }

  Future<UserResponse> updatePassword(String newPassword) {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> refreshUser() async {
    await _client.auth.refreshSession();
  }
}
