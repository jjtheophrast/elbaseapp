import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../buttons/button_color_config.dart';
import '../buttons/el_button.dart';
import '../buttons/el_button_config.dart';
import 'el_dialog_with_buttonlist.dart';

class ELUnsavedChangesDialog extends ConsumerWidget {
  final String message;
  final Future Function() onSave;
  final Function() onContinue;
  final Function() onDiscard;

  const ELUnsavedChangesDialog(
      {required this.message, required this.onSave, required this.onContinue, required this.onDiscard, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ELDialogWithButtonList(
      title: 'Unsaved changes',
      buttonChildren: [
        ELButton(
          config: ELButtonConfig(
              title: 'Discard changes', colorConfig: ButtonColorConfig(ButtonColorType.outlinedPrimary, context)),
          onPressed: () {
            Navigator.of(context).pop();
            onDiscard();
          },
        ),
        ELButton(
          config: ELButtonConfig(
              title: 'Continue editing', colorConfig: ButtonColorConfig(ButtonColorType.outlinedPrimary, context)),
          onPressed: () {
            Navigator.of(context).pop();
            onContinue();
          },
        ),
        ELButton(
          config: ELButtonConfig(
              title: 'Save changes', colorConfig: ButtonColorConfig(ButtonColorType.filledPrimary, context)),
          onPressed: () {
            Navigator.of(context).pop();
            onSave();
          },
        )
      ],
      children: [Text(message)],
    );
  }
}

void showELUnsavedChangedDialog(
    {required BuildContext context,
    required String message,
    required Future Function() onSave,
    required Function() onContinue,
    required Function() onDiscard}) {
  showDialog(
    context: context,
    builder: (BuildContext context) =>
        ELUnsavedChangesDialog(message: message, onSave: onSave, onContinue: onContinue, onDiscard: onDiscard),
  );
}
