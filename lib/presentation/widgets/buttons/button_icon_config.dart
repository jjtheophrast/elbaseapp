import 'package:flutter/material.dart';

enum ButtonIconType {
  left,
  none,
}

class ButtonIconConfig {
  const ButtonIconConfig({this.iconType, this.icon});

  ButtonIconConfig.noIcon()
      : iconType = ButtonIconType.none,
        icon = null;

  final ButtonIconType? iconType;
  final IconData? icon;

  static double iconSize = 18;
  static double iconGap = 8;
} 