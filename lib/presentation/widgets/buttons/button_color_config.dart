import 'package:flutter/material.dart';

enum ButtonColorType {
  filledPrimary,
  outlinedPrimary,
  filledTertiary,
  outlinedDelete,
  filledDelete,
  textDelete,
  textPrimary,
}

class ButtonColorConfig {
  factory ButtonColorConfig(ButtonColorType type, BuildContext context) {
    switch (type) {
      case ButtonColorType.filledPrimary:
        return ButtonColorConfig._filledPrimary(context);
      case ButtonColorType.outlinedPrimary:
        return ButtonColorConfig._outlinedPrimary(context);
      case ButtonColorType.filledTertiary:
        return ButtonColorConfig._filledTertiary(context);
      case ButtonColorType.filledDelete:
        return ButtonColorConfig._filledDelete(context);
      case ButtonColorType.outlinedDelete:
        return ButtonColorConfig._outlinedDelete(context);
      case ButtonColorType.textDelete:
        return ButtonColorConfig._textDelete(context);
      case ButtonColorType.textPrimary:
        return ButtonColorConfig._textPrimary(context);
      default:
        throw UnimplementedError('ButtonColorConfig missing implementation');
    }
  }

  ButtonColorConfig._filledPrimary(BuildContext context)
      : foregroundColor = Theme.of(context).colorScheme.onPrimary,
        backgroundColor = Theme.of(context).colorScheme.primary,
        borderColor = Theme.of(context).colorScheme.primary,
        pressedColor = Color.alphaBlend(Colors.white.withAlpha(pressedOpacity), Theme.of(context).colorScheme.primary),
        pressedBorderColor =
            Color.alphaBlend(Colors.white.withAlpha(pressedOpacity), Theme.of(context).colorScheme.primary),
        hoveredColor = Color.alphaBlend(Colors.white.withAlpha(hoverOpacity), Theme.of(context).colorScheme.primary),
        hoverBorderColor =
            Color.alphaBlend(Colors.white.withAlpha(hoverOpacity), Theme.of(context).colorScheme.primary),
        focusColor = Color.alphaBlend(Colors.white.withAlpha(focusOpacity), Theme.of(context).colorScheme.primary),
        disabledColor = Theme.of(context).colorScheme.onSurface.withAlpha(disabledContainerOpacity),
        disabledBorderColor = Colors.transparent,
        disabledForeGroundColor = Theme.of(context).colorScheme.onSurface.withAlpha(disabledLabelOpacity),
        shadowColor = null,
        colorType = ButtonColorType.filledPrimary;

  ButtonColorConfig._filledDelete(BuildContext context)
      : foregroundColor = Theme.of(context).colorScheme.onError,
        backgroundColor = Theme.of(context).colorScheme.error,
        borderColor = Theme.of(context).colorScheme.error,
        pressedColor = Color.alphaBlend(Colors.white.withAlpha(pressedOpacity), Theme.of(context).colorScheme.error),
        pressedBorderColor =
            Color.alphaBlend(Colors.white.withAlpha(pressedOpacity), Theme.of(context).colorScheme.error),
        hoveredColor = Color.alphaBlend(Colors.white.withAlpha(hoverOpacity), Theme.of(context).colorScheme.error),
        hoverBorderColor = Color.alphaBlend(Colors.white.withAlpha(hoverOpacity), Theme.of(context).colorScheme.error),
        focusColor = Color.alphaBlend(Colors.white.withAlpha(focusOpacity), Theme.of(context).colorScheme.error),
        disabledColor = Theme.of(context).colorScheme.onSurface.withAlpha(disabledContainerOpacity),
        disabledBorderColor = Colors.transparent,
        disabledForeGroundColor = Theme.of(context).colorScheme.onSurface.withAlpha(disabledLabelOpacity),
        shadowColor = null,
        colorType = ButtonColorType.filledDelete;

  ButtonColorConfig._outlinedPrimary(BuildContext context)
      : foregroundColor = Theme.of(context).colorScheme.primary,
        backgroundColor = Colors.transparent,
        borderColor = Theme.of(context).colorScheme.primary.withAlpha(90),
        pressedColor = Theme.of(context).colorScheme.primary.withAlpha(pressedOpacity),
        pressedBorderColor = Theme.of(context).colorScheme.primary,
        hoveredColor = Theme.of(context).colorScheme.primary.withAlpha(hoverOpacity),
        hoverBorderColor = Theme.of(context).colorScheme.primary,
        focusColor = Theme.of(context).colorScheme.primary.withAlpha(focusOpacity),
        disabledColor = Colors.transparent,
        disabledForeGroundColor = Theme.of(context).colorScheme.onSurface.withAlpha(disabledLabelOpacity),
        disabledBorderColor = Theme.of(context).colorScheme.onSurface.withAlpha(outlinedDisabledBorderOpacity),
        shadowColor = null,
        colorType = ButtonColorType.outlinedPrimary;

  ButtonColorConfig._filledTertiary(BuildContext context)
      : foregroundColor = Theme.of(context).colorScheme.tertiary,
        backgroundColor = Colors.transparent,
        borderColor = Theme.of(context).colorScheme.outlineVariant,
        pressedColor = Theme.of(context).colorScheme.tertiary.withAlpha(pressedOpacity),
        pressedBorderColor = Theme.of(context).colorScheme.tertiary,
        hoveredColor = Theme.of(context).colorScheme.tertiary.withAlpha(hoverOpacity),
        hoverBorderColor = Theme.of(context).colorScheme.tertiary,
        focusColor = Theme.of(context).colorScheme.tertiary.withAlpha(focusOpacity),
        disabledColor = Colors.transparent,
        disabledForeGroundColor = Theme.of(context).colorScheme.onSurface.withAlpha(disabledLabelOpacity),
        disabledBorderColor = Theme.of(context).colorScheme.onSurface.withAlpha(outlinedDisabledBorderOpacity),
        shadowColor = null,
        colorType = ButtonColorType.filledTertiary;

  ButtonColorConfig._outlinedDelete(BuildContext context)
      : foregroundColor = Theme.of(context).colorScheme.error,
        backgroundColor = Colors.transparent,
        borderColor = Theme.of(context).colorScheme.outlineVariant,
        pressedColor = Theme.of(context).colorScheme.error.withAlpha(pressedOpacity),
        pressedBorderColor = Theme.of(context).colorScheme.error,
        hoveredColor = Theme.of(context).colorScheme.error.withAlpha(hoverOpacity),
        hoverBorderColor = Theme.of(context).colorScheme.error,
        focusColor = Theme.of(context).colorScheme.error.withAlpha(focusOpacity),
        disabledColor = Colors.transparent,
        disabledForeGroundColor = Theme.of(context).colorScheme.onSurface.withAlpha(disabledLabelOpacity),
        disabledBorderColor = Theme.of(context).colorScheme.onSurface.withAlpha(outlinedDisabledBorderOpacity),
        shadowColor = null,
        colorType = ButtonColorType.outlinedDelete;

  ButtonColorConfig._textDelete(BuildContext context)
      : foregroundColor = Theme.of(context).colorScheme.error,
        backgroundColor = Colors.transparent,
        borderColor = Colors.transparent,
        pressedColor = Theme.of(context).colorScheme.error.withAlpha(pressedOpacity),
        pressedBorderColor = Colors.transparent,
        hoveredColor = Theme.of(context).colorScheme.error.withAlpha(hoverOpacity),
        hoverBorderColor = Colors.transparent,
        focusColor = Theme.of(context).colorScheme.error.withAlpha(focusOpacity),
        disabledColor = Colors.transparent,
        disabledForeGroundColor = Theme.of(context).colorScheme.error.withAlpha(disabledLabelOpacity),
        disabledBorderColor = Colors.transparent,
        shadowColor = null,
        colorType = ButtonColorType.textDelete;

  ButtonColorConfig._textPrimary(BuildContext context)
      : foregroundColor = Theme.of(context).colorScheme.primary,
        backgroundColor = Colors.transparent,
        borderColor = Colors.transparent,
        pressedColor = Theme.of(context).colorScheme.primary.withAlpha(pressedOpacity),
        pressedBorderColor = Colors.transparent,
        hoveredColor = Theme.of(context).colorScheme.primary.withAlpha(hoverOpacity),
        hoverBorderColor = Colors.transparent,
        focusColor = Theme.of(context).colorScheme.primary.withAlpha(focusOpacity),
        disabledColor = Colors.transparent,
        disabledForeGroundColor = Theme.of(context).colorScheme.primary.withAlpha(disabledLabelOpacity),
        disabledBorderColor = Colors.transparent,
        shadowColor = null,
        colorType = ButtonColorType.textPrimary;

  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color pressedColor;
  final Color? pressedBorderColor;
  final Color hoveredColor;
  final Color focusColor;
  final Color disabledColor;
  final Color disabledBorderColor;
  final Color? hoverBorderColor;
  final Color disabledForeGroundColor;
  final Color? shadowColor;
  final ButtonColorType colorType;

  static const hoverOpacity = 20;
  static const focusOpacity = 25;
  static const pressedOpacity = 25;
  static const disabledContainerOpacity = 30;
  static const outlinedDisabledBorderOpacity = 30;
  static const disabledLabelOpacity = 96;
} 