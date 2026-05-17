import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/core/app_breakpoints.dart';
import 'package:my_app/core/error_message.dart';
import 'package:my_app/models/user_profile.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/profile_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/app_snackbar.dart';
import 'package:my_app/widgets/app_svg_icons.dart';
import 'package:my_app/widgets/fade_slide_in.dart';
import 'package:my_app/widgets/user_avatar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.authService,
    required this.profileService,
    required this.onProfileUpdated,
  });

  final AuthService authService;
  final ProfileService profileService;
  final VoidCallback onProfileUpdated;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _savingProfile = false;
  bool _savingPassword = false;
  bool _uploadingAvatar = false;
  bool _obscurePassword = true;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _syncFromAuth();
  }

  void _syncFromAuth() {
    _profile = widget.authService.profile;
    _nameController = TextEditingController(text: _profile?.fullName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final user = widget.authService.currentUser;
    if (user == null) return;

    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;

      setState(() => _uploadingAvatar = true);

      final bytes = await file.readAsBytes();
      final ext = file.name.split('.').last.toLowerCase();
      final safeExt = ext == 'png' ? 'png' : 'jpg';

      final url = await widget.profileService.uploadAvatar(
        userId: user.id,
        bytes: bytes,
        extension: safeExt,
      );

      await widget.authService.updateProfile(avatarUrl: url);
      await widget.authService.refreshUser();

      if (mounted) {
        setState(() {
          _profile = widget.authService.profile;
        });
        widget.onProfileUpdated();
        showAppSnackBar(context, message: 'Profile photo updated');
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _savingProfile = true);
    try {
      await widget.authService.updateProfile(
        fullName: _nameController.text.trim(),
      );
      await widget.authService.refreshUser();
      if (mounted) {
        setState(() => _profile = widget.authService.profile);
        widget.onProfileUpdated();
        showAppSnackBar(context, message: 'Profile saved');
      }
    } on AuthException catch (e) {
      if (mounted) {
        showAppSnackBar(context, message: friendlyAuthError(e), isError: true);
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _updatePassword() async {
    final password = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (password.length < 6) {
      showAppSnackBar(
        context,
        message: 'Password must be at least 6 characters',
        isError: true,
      );
      return;
    }
    if (password != confirm) {
      showAppSnackBar(context, message: 'Passwords do not match', isError: true);
      return;
    }

    setState(() => _savingPassword = true);
    try {
      await widget.authService.updatePassword(password);
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      if (mounted) {
        showAppSnackBar(context, message: 'Password updated successfully');
      }
    } on AuthException catch (e) {
      if (mounted) {
        showAppSnackBar(context, message: friendlyAuthError(e), isError: true);
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile ?? widget.authService.profile;
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final width = MediaQuery.sizeOf(context).width;
    final padding = AppBreakpoints.isDesktop(width) ? 32.0 : 16.0;
    final maxContentWidth = width > 900 ? 720.0 : double.infinity;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padding, 20, padding, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!AppBreakpoints.isMobile(width)) ...[
                Row(
                  children: [
                    AppSvgIcons.profile(color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              FadeSlideIn(child: _buildAvatarCard(context, profile)),
              const SizedBox(height: 20),
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: _buildInfoCard(context, profile),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: _buildPasswordCard(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCard(BuildContext context, UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  UserAvatar(
                    profile: profile,
                    radius: 48,
                    showEditBadge: !_uploadingAvatar,
                    onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                  ),
                  if (_uploadingAvatar)
                    const SizedBox(
                      width: 96,
                      height: 96,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile.displayName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              profile.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _uploadingAvatar ? null : _pickAndUploadAvatar,
              icon: AppSvgIcons.camera(color: AppColors.accentDark, size: 20),
              label: const Text('Change photo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Account details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: profile.email,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14),
                    child: AppSvgIcons.email(color: AppColors.textSecondary),
                  ),
                  helperText: 'Email cannot be changed here',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Display name',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14),
                    child: AppSvgIcons.profile(color: AppColors.textSecondary),
                  ),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _savingProfile ? null : _saveProfile,
                child: _savingProfile
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppSvgIcons.lock(color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Change password',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'New password',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(14),
                  child: AppSvgIcons.lock(color: AppColors.textSecondary),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Confirm new password',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(14),
                  child: AppSvgIcons.lock(color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _savingPassword ? null : _updatePassword,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
              ),
              child: _savingPassword
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Update password'),
            ),
          ],
        ),
      ),
    );
  }
}
