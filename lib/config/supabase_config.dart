import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url => (dotenv.env['SUPABASE_URL'] ?? '').trim();
  static String get anonKey => (dotenv.env['SUPABASE_ANON_KEY'] ?? '').trim();

  /// Anon keys are JWTs from Project Settings → API → anon public.
  static bool get isAnonKeyValid =>
      anonKey.startsWith('eyJ') && anonKey.length > 100;

  static bool get isConfigured =>
      url.isNotEmpty &&
      url.contains('.supabase.co') &&
      !url.contains('YOUR_PROJECT_REF') &&
      isAnonKeyValid;

  static String? get configurationHint {
    if (url.isEmpty || url.contains('YOUR_PROJECT_REF')) {
      return 'Set SUPABASE_URL in .env (Project Settings → API → Project URL).';
    }
    if (!isAnonKeyValid) {
      return 'SUPABASE_ANON_KEY must be the long "anon public" JWT from '
          'Project Settings → API — not the project ID from the URL.';
    }
    return null;
  }
}
