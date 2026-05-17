import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;

  String get displayName {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }
    if (email.isNotEmpty) return email.split('@').first;
    return 'User';
  }

  String get initials {
    final name = displayName.trim();
    if (name.isEmpty) return 'U';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  factory UserProfile.fromUser(User user) {
    final meta = user.userMetadata ?? {};
    return UserProfile(
      id: user.id,
      email: user.email ?? '',
      fullName: meta['full_name'] as String?,
      avatarUrl: meta['avatar_url'] as String?,
    );
  }
}
