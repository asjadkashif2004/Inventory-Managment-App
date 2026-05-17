import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_app/config/supabase_config.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/item_service.dart';
import 'package:my_app/services/profile_service.dart';
import 'package:my_app/shell/app_shell.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return _ConfigRequiredScreen(
        hint: SupabaseConfig.configurationHint,
      );
    }

    final client = Supabase.instance.client;
    final authService = AuthService(client);
    final itemService = ItemService(client);
    final profileService = ProfileService(client);

    return StreamBuilder<AuthState>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        final session = authService.currentSession;
        if (session != null) {
          return AppShell(
            authService: authService,
            itemService: itemService,
            profileService: profileService,
          );
        }
        return LoginScreen(authService: authService);
      },
    );
  }
}

class _ConfigRequiredScreen extends StatelessWidget {
  const _ConfigRequiredScreen({this.hint});

  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Supabase not configured',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (hint != null) ...[
                const SizedBox(height: 12),
                Text(
                  hint!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                '1. Supabase → Project Settings → API\n'
                '2. Copy Project URL → SUPABASE_URL\n'
                '3. Copy anon public key (starts with eyJ...) → SUPABASE_ANON_KEY\n'
                '4. Save .env and hot restart (R)\n'
                '5. Run supabase/setup.sql if items fail to load\n'
                '6. Run supabase/storage_setup.sql for profile photos',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
