import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final Widget icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 115 || constraints.maxWidth < 155;
        final padding = compact ? 10.0 : 16.0;
        final iconPad = compact ? 8.0 : 12.0;
        final iconSize = compact ? 18.0 : 22.0;
        final gap = compact ? 10.0 : 14.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: compact
              ? _CompactLayout(
                  label: label,
                  value: value,
                  icon: icon,
                  accentColor: accentColor,
                  iconPad: iconPad,
                  iconSize: iconSize,
                )
              : _ExpandedLayout(
                  label: label,
                  value: value,
                  icon: icon,
                  accentColor: accentColor,
                  iconPad: iconPad,
                  gap: gap,
                ),
        );
      },
    );
  }
}

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.iconPad,
    required this.iconSize,
  });

  final String label;
  final String value;
  final Widget icon;
  final Color accentColor;
  final double iconPad;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        );
    final valueStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(iconPad),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(width: iconSize, height: iconSize, child: icon),
        ),
        const SizedBox(height: 8),
        Text(label, style: labelStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(
          value,
          style: valueStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ExpandedLayout extends StatelessWidget {
  const _ExpandedLayout({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.iconPad,
    required this.gap,
  });

  final String label;
  final String value;
  final Widget icon;
  final Color accentColor;
  final double iconPad;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(iconPad),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: icon,
        ),
        SizedBox(width: gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
