import 'package:flutter/material.dart';
import 'package:my_app/core/error_message.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/widgets/app_snackbar.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/app_svg_icons.dart';
import 'package:my_app/widgets/auth_shell.dart';
import 'package:my_app/widgets/fade_slide_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final response = await widget.authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response.session != null) {
        Navigator.of(context).pop();
        return;
      }

      showAppSnackBar(
        context,
        message:
            'Account created. Check your email to confirm, then sign in.',
      );
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          message: friendlyAuthError(e),
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      showBack: true,
      title: 'Create account',
      subtitle: 'Join Inventory Pro and start managing stock',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeSlideIn(
              delay: const Duration(milliseconds: 240),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14),
                    child: AppSvgIcons.email(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your email';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            FadeSlideIn(
              delay: const Duration(milliseconds: 320),
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14),
                    child: AppSvgIcons.lock(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            FadeSlideIn(
              delay: const Duration(milliseconds: 400),
              child: TextFormField(
                controller: _confirmController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14),
                    child: AppSvgIcons.lock(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 28),
            FadeSlideIn(
              delay: const Duration(milliseconds: 480),
              child: FilledButton(
                onPressed: _loading ? null : _signUp,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                ),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
