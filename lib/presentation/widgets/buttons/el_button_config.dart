import 'package:flutter/material.dart';
import 'button_color_config.dart';
import 'button_icon_config.dart';

class ELButtonConfig {
  const ELButtonConfig({
    required this.title,
    required this.colorConfig,
    this.iconConfig,
    this.icon,
    this.iconSize = 18,
    this.isFixedSize = false,
    this.width = 200,
    this.disabled = false,
    this.isLoading = false,
    this.focusNode,
    this.fillWidth = false,
    this.autofocus = false,
    this.parentClass,
  });

  final String title;
  final ButtonColorConfig colorConfig;
  final ButtonIconConfig? iconConfig;
  final IconData? icon;
  final double iconSize;
  final bool isFixedSize;
  final double width;
  final bool disabled;
  final bool isLoading;
  final FocusNode? focusNode;
  final bool fillWidth;
  final bool autofocus;
  final Object? parentClass;
} 