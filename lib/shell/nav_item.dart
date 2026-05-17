import 'package:flutter/material.dart';

class NavItem {
  const NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}
