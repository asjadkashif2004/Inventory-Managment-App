import 'package:supabase_flutter/supabase_flutter.dart';

String friendlyError(Object error) {
  if (error is AuthException) {
    return friendlyAuthError(error);
  }

  final text = error.toString().toLowerCase();

  if (text.contains('rate limit') || text.contains('email rate')) {
    return 'Too many emails sent. Wait a while or disable email confirmation in Supabase for development.';
  }
  if (text.contains('invalid login') || text.contains('invalid credentials')) {
    return 'Incorrect email or password.';
  }
  if (text.contains('user already registered')) {
    return 'An account with this email already exists. Try signing in.';
  }
  if (text.contains('network') || text.contains('socket')) {
    return 'Network error. Check your connection and try again.';
  }
  if (text.contains('row-level security') || text.contains('permission denied')) {
    return 'Permission denied. Run supabase/setup.sql and storage_setup.sql in your project.';
  }
  if (text.contains('bucket') || text.contains('storage')) {
    return 'Storage not configured. Run supabase/storage_setup.sql in Supabase SQL Editor.';
  }
  if (text.contains('duplicate key') || text.contains('unique')) {
    return 'This item ID already exists. Use a different SKU.';
  }

  final raw = error.toString();
  if (raw.startsWith('Exception: ')) {
    return raw.substring(11);
  }
  return raw;
}

String friendlyAuthError(AuthException error) {
  final msg = error.message.toLowerCase();
  if (msg.contains('rate limit')) {
    return 'Email rate limit exceeded. Wait 30–60 minutes or turn off email confirmation in Supabase → Authentication → Email.';
  }
  if (msg.contains('weak') || msg.contains('password')) {
    return error.message;
  }
  return error.message;
}
