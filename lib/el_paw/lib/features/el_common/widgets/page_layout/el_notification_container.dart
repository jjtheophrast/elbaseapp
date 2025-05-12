import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../util/theme_util.dart';
import '../buttons/button_color_config.dart';
import '../buttons/el_button.dart';
import '../buttons/el_button_config.dart';

class ELNotificationContainer extends ConsumerWidget {
  final String text;
  final String buttonTitle;
  final Color backgroundColor;
  final IconData? icon;
  final IconData? buttonIcon;
  final VoidCallback onPressed;
  final bool isButtonLoading;
  final double paddingBottom;
  final Function getIsVisible;

  const ELNotificationContainer(
      {super.key,
      required this.text,
      required this.buttonTitle,
      required this.backgroundColor,
      this.icon,
      this.buttonIcon,
      this.isButtonLoading = false,
      this.paddingBottom = 24,
      required this.onPressed,
      required this.getIsVisible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: getIsVisible(),
      child: Padding(
        padding: EdgeInsets.only(bottom: paddingBottom),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  spacing: 8,
                  children: [
                    if (icon != null) Icon(icon),
                    Flexible(
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.regular.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              ELButton(
                config: ELButtonConfig(
                    title: buttonTitle,
                    icon: buttonIcon ?? buttonIcon,
                    isLoading: isButtonLoading,
                    colorConfig: ButtonColorConfig(ButtonColorType.filledPrimary, context)),
                onPressed: onPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
