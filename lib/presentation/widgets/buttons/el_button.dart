import 'package:flutter/material.dart';

import 'button_color_config.dart';
import 'button_icon_config.dart';
import 'el_button_config.dart';

class ELButton extends StatelessWidget {
  const ELButton({
    super.key,
    required this.config,
    required this.onPressed,
  });

  final ELButtonConfig config;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = _buildButtonStyle();
    final iconType = config.iconConfig?.iconType;

    return switch (iconType) {
      ButtonIconType.left => _buildLeftIconButton(context, style),
      ButtonIconType.none || null => _buildStandardButton(context, style),
    };
  }

  ButtonStyle _buildButtonStyle() {
    return ButtonStyle(
      elevation: WidgetStateProperty.all(2),
      shadowColor: WidgetStateProperty.resolveWith<Color?>((states) =>
      states.contains(WidgetState.disabled) ? null : config.colorConfig.shadowColor),
      splashFactory: NoSplash.splashFactory,
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) =>
      states.contains(WidgetState.disabled)
          ? config.colorConfig.disabledForeGroundColor
          : config.colorConfig.foregroundColor),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) return config.colorConfig.disabledColor;
        if (states.contains(WidgetState.pressed)) return config.colorConfig.pressedColor;
        if (states.contains(WidgetState.hovered)) return config.colorConfig.hoveredColor;
        return config.colorConfig.backgroundColor;
      }),
      side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(width: 1.5, color: config.colorConfig.disabledBorderColor);
        } else if (states.contains(WidgetState.pressed)) {
          return BorderSide(width: 1.5, color: config.colorConfig.pressedBorderColor!);
        } else if (states.contains(WidgetState.hovered)) {
          return BorderSide(width: 1.5, color: config.colorConfig.hoverBorderColor!);
        }
        return BorderSide(width: 1.5, color: config.colorConfig.borderColor);
      }),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
      ),
      overlayColor: const WidgetStatePropertyAll<Color?>(Colors.transparent),
      alignment: Alignment.center,
      fixedSize: config.isFixedSize ? WidgetStatePropertyAll(Size.fromWidth(config.width)) : null,
    );
  }

  Widget _buildLeftIconButton(BuildContext context, ButtonStyle style) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: config.disabled ? config.colorConfig.disabledForeGroundColor : config.colorConfig.foregroundColor,
    );
    
    final Object parent = (config.parentClass is String)
        ? (config.parentClass ?? '_')
        : config.parentClass?.runtimeType.toString() ?? '_';

    return TextButton(
      autofocus: config.autofocus,
      focusNode: config.focusNode,
      onPressed: config.disabled
          ? null
          : () {
        onPressed?.call();
      },
      style: style,
      child: Padding(
        padding: config.colorConfig.colorType == ButtonColorType.textPrimary
            ? const EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 16)
            : const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              config.icon,
              size: ButtonIconConfig.iconSize,
              color: config.disabled ? config.colorConfig.disabledForeGroundColor : config.colorConfig.foregroundColor,
            ),
            SizedBox(width: ButtonIconConfig.iconGap),
            Flexible(
              child: Text(
                config.title,
                textScaleFactor: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textStyle,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardButton(BuildContext context, ButtonStyle style) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: config.disabled ? config.colorConfig.disabledForeGroundColor : config.colorConfig.foregroundColor,
    );

    return Stack(
      children: [
        TextButton(
          autofocus: config.autofocus,
          focusNode: config.focusNode,
          onPressed: (config.disabled || config.isLoading) ? null : onPressed,
          style: style,
          child: Padding(
            padding: config.colorConfig.colorType == ButtonColorType.textPrimary ||
                config.colorConfig.colorType == ButtonColorType.textDelete
                ? EdgeInsets.symmetric(
              vertical: 10,
              horizontal: config.colorConfig.colorType == ButtonColorType.textDelete ? 2 : 12,
            )
                : const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
            child: Row(
              mainAxisSize: config.fillWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (config.icon != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        config.icon,
                        size: config.iconSize,
                        color: config.disabled
                            ? config.colorConfig.disabledForeGroundColor
                            : config.colorConfig.foregroundColor,
                      ),
                      SizedBox(width: ButtonIconConfig.iconGap),
                    ],
                  ),
                Text(
                  config.title,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textStyle,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ),
        if (config.isLoading) _buildLoadingIndicator(context),
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          height: 15,
          width: 15,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }
} 