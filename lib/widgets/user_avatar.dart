import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/user_profile.dart';
import 'package:my_app/theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.profile,
    this.radius = 24,
    this.showEditBadge = false,
    this.onTap,
  });

  final UserProfile profile;
  final double radius;
  final bool showEditBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.primary,
            backgroundImage: _imageProvider(),
            child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                ? Text(
                    profile.initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: radius * 0.72,
                    ),
                  )
                : null,
          ),
          if (showEditBadge)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: radius * 0.45,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );

    return avatar;
  }

  ImageProvider? _imageProvider() {
    final url = profile.avatarUrl;
    if (url == null || url.isEmpty) return null;
    return CachedNetworkImageProvider(url);
  }
}
