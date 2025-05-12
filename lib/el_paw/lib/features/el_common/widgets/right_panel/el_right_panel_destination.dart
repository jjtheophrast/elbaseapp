import 'package:flutter/cupertino.dart';

class ELRightPanelDestination {
  final Icon icon;
  final Icon? selectedIcon;
  final String label;
  final bool disabled;

  const ELRightPanelDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.disabled = false,
  });
}
