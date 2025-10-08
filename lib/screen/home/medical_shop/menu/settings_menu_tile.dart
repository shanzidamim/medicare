import 'package:flutter/material.dart';

import '../../../../common/color_extension.dart';

class SettingsMenuTile extends StatelessWidget {
  const SettingsMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 28, color: TColor.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),

      trailing: trailing,
      onTap: onTap,
    );
  }
}