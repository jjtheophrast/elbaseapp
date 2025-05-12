import 'package:flutter/material.dart';

import '../../../util/theme_util.dart';

class ActionItem {
  final String value;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  ActionItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class ELActionsMenu extends StatelessWidget {
  final List<ActionItem> actions;

  const ELActionsMenu({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: 'Actions',
      textStyle: theme.textTheme.regular.bodySmall?.copyWith(
        color: theme.colorScheme.onPrimary,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.outline,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2),
      child: PopupMenuButton<String>(
        tooltip: '',
        icon: const Icon(Icons.more_vert),
        iconColor: theme.colorScheme.onSurface,
        onSelected: (String value) {
          final action = actions.firstWhere((action) => action.value == value);
          action.onTap();
        },
        itemBuilder: (BuildContext context) {
          return actions.map((action) {
            return PopupMenuItem<String>(
              value: action.value,
              child: ListTile(
                leading: Icon(action.icon),
                title: Text(
                  action.label,
                  style: theme.textTheme.regular.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                mouseCursor: SystemMouseCursors.click,
              ),
            );
          }).toList();
        },
      ),
    );
  }
}
