import 'package:flutter/material.dart';
import 'package:my_app/models/user_profile.dart';
import 'package:my_app/shell/nav_item.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/app_svg_icons.dart';
import 'package:my_app/widgets/user_avatar.dart';

class AppSideNav extends StatelessWidget {
  const AppSideNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.profile,
    required this.extended,
    this.onSignOut,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final UserProfile profile;
  final bool extended;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final width = extended ? 260.0 : 72.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment:
              extended ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(extended ? 20 : 12, 20, extended ? 20 : 12, 8),
              child: extended
                  ? Row(
                      children: [
                        AppSvgIcons.logo(size: 36, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Inventory Pro',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      ],
                    )
                  : AppSvgIcons.logo(size: 32, color: AppColors.primary),
            ),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 8),
            ...List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == selectedIndex;
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: extended ? 12 : 8,
                  vertical: 2,
                ),
                child: _NavTile(
                  extended: extended,
                  selected: selected,
                  item: item,
                  onTap: () => onSelected(index),
                ),
              );
            }),
            const Spacer(),
            if (extended) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    UserAvatar(profile: profile, radius: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            profile.email,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (onSignOut != null)
              Padding(
                padding: EdgeInsets.fromLTRB(extended ? 12 : 8, 0, extended ? 12 : 8, 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onSignOut,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: extended ? 16 : 12,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            extended ? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          AppSvgIcons.logout(
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                          if (extended) ...[
                            const SizedBox(width: 12),
                            Text(
                              'Sign out',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.extended,
    required this.selected,
    required this.item,
    required this.onTap,
  });

  final bool extended;
  final bool selected;
  final NavItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.accent.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: extended ? 16 : 12,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment:
                extended ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              selected ? item.selectedIcon : item.icon,
              if (extended) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? AppColors.accentDark : AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
