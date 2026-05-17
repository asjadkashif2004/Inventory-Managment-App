import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  ProfileService(this._client);

  final SupabaseClient _client;
  static const _bucket = 'avatars';

  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    String extension = 'jpg',
  }) async {
    final path = '$userId/avatar.$extension';
    final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';

    await _client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
          ),
        );

    return _client.storage.from(_bucket).getPublicUrl(path);
  }

  Future<void> removeAvatar(String userId) async {
    await _client.storage.from(_bucket).remove([
      '$userId/avatar.jpg',
      '$userId/avatar.png',
      '$userId/avatar.jpeg',
    ]);
  }
}
