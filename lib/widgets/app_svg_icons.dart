import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract final class AppSvgIcons {
  static const _defaultSize = 24.0;

  static Widget inventory({double size = _defaultSize, Color? color}) =>
      _icon(_inventory, size, color);

  static Widget dashboard({double size = _defaultSize, Color? color}) =>
      _icon(_dashboard, size, color);

  static Widget email({double size = _defaultSize, Color? color}) =>
      _icon(_email, size, color);

  static Widget lock({double size = _defaultSize, Color? color}) =>
      _icon(_lock, size, color);

  static Widget add({double size = _defaultSize, Color? color}) =>
      _icon(_add, size, color);

  static Widget edit({double size = _defaultSize, Color? color}) =>
      _icon(_edit, size, color);

  static Widget delete({double size = _defaultSize, Color? color}) =>
      _icon(_delete, size, color);

  static Widget refresh({double size = _defaultSize, Color? color}) =>
      _icon(_refresh, size, color);

  static Widget logout({double size = _defaultSize, Color? color}) =>
      _icon(_logout, size, color);

  static Widget box({double size = _defaultSize, Color? color}) =>
      _icon(_box, size, color);

  static Widget dollar({double size = _defaultSize, Color? color}) =>
      _icon(_dollar, size, color);

  static Widget warning({double size = _defaultSize, Color? color}) =>
      _icon(_warning, size, color);

  static Widget logo({double size = 48, Color? color}) =>
      _icon(_logo, size, color);

  static Widget profile({double size = _defaultSize, Color? color}) =>
      _icon(_profile, size, color);

  static Widget menu({double size = _defaultSize, Color? color}) =>
      _icon(_menu, size, color);

  static Widget camera({double size = _defaultSize, Color? color}) =>
      _icon(_camera, size, color);

  static Widget tag({double size = _defaultSize, Color? color}) =>
      _icon(_tag, size, color);

  static Widget _icon(String asset, double size, Color? color) {
    return SvgPicture.string(
      asset,
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static const _logo = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect width="48" height="48" rx="12" fill="currentColor" fill-opacity="0.15"/>
  <path d="M14 18h20v4H14v-4zm0 8h14v4H14v-4zm0 8h10v4H14v-4z" fill="currentColor"/>
  <path d="M34 26l6 6-6 6v-4h-8v-4h8v-4z" fill="currentColor" fill-opacity="0.7"/>
</svg>''';

  static const _inventory = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 6h16v2H4V6zm0 5h16v2H4v-2zm0 5h10v2H4v-2z" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
  <rect x="3" y="4" width="18" height="16" rx="2" stroke="currentColor" stroke-width="1.5"/>
</svg>''';

  static const _dashboard = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="3" y="3" width="8" height="8" rx="2" stroke="currentColor" stroke-width="1.5"/>
  <rect x="13" y="3" width="8" height="5" rx="2" stroke="currentColor" stroke-width="1.5"/>
  <rect x="13" y="10" width="8" height="11" rx="2" stroke="currentColor" stroke-width="1.5"/>
  <rect x="3" y="13" width="8" height="8" rx="2" stroke="currentColor" stroke-width="1.5"/>
</svg>''';

  static const _email = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="2" y="4" width="20" height="16" rx="2" stroke="currentColor" stroke-width="1.5"/>
  <path d="M2 7l10 7 10-7" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
</svg>''';

  static const _lock = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="5" y="11" width="14" height="10" rx="2" stroke="currentColor" stroke-width="1.5"/>
  <path d="M8 11V8a4 4 0 118 0v3" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
</svg>''';

  static const _add = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="1.5"/>
  <path d="M12 8v8M8 12h8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
</svg>''';

  static const _edit = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 20h4l10-10-4-4L4 16v4z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/>
  <path d="M14 6l4 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
</svg>''';

  static const _delete = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 7h16M9 7V5h6v2M7 7l1 12h8l1-12" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

  static const _refresh = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 12a8 8 0 0113.5-5.5M20 12a8 8 0 01-13.5 5.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
  <path d="M16 4h4v4M8 20H4v-4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

  static const _logout = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

  static const _box = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 2L2 7l10 5 10-5-10-5z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/>
  <path d="M2 17l10 5 10-5M2 12l10 5 10-5" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/>
</svg>''';

  static const _dollar = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="1.5"/>
  <path d="M12 6v12M9 9.5c0-1 1.5-1.5 3-1.5s3 .5 3 1.5-1.5 1.5-3 1.5-3 .5-3 1.5 1.5 1.5 3 1.5 3 .5 3 1.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
</svg>''';

  static const _warning = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 3L2 21h20L12 3z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/>
  <path d="M12 10v4M12 17h.01" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
</svg>''';

  static const _profile = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.5"/>
  <path d="M4 20c0-4 3.6-6 8-6s8 2 8 6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
</svg>''';

  static const _menu = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 7h16M4 12h16M4 17h16" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
</svg>''';

  static const _camera = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 8h3l2-2h6l2 2h3v10H4V8z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/>
  <circle cx="12" cy="13" r="3" stroke="currentColor" stroke-width="1.5"/>
</svg>''';

  static const _tag = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M20 12l-8 8-8-8V4h8l8 8z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/>
  <circle cx="15" cy="9" r="1" fill="currentColor"/>
</svg>''';
}
