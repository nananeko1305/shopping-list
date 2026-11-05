import 'package:flutter/material.dart';

import '../theme.dart';

/// An icon button with a border and a tinted background, so it reads as a
/// button rather than a bare icon. Tinted with the brand colour unless
/// [color] is given (red for deleting).
class FramedIconButton extends StatelessWidget {
  const FramedIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    final tint = color ?? p.brand;
    final enabled = onPressed != null;
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: tint,
        backgroundColor: tint.withValues(alpha: 0.10),
        disabledForegroundColor: p.muted.withValues(alpha: 0.6),
        disabledBackgroundColor: p.muted.withValues(alpha: 0.06),
        side: BorderSide(
          color: (enabled ? tint : p.muted).withValues(alpha: 0.35),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
