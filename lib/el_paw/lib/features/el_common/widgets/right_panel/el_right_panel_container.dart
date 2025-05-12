import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../util/theme_util.dart';
import '../buttons/button_color_config.dart';
import '../buttons/el_button.dart';
import '../buttons/el_button_config.dart';

class ELRightPanelContainer<T extends Enum> extends ConsumerWidget {
  final List<Widget> children;
  final String title;
  final VoidCallback? onSave;
  final VoidCallback onCancel;
  final bool isLoading;
  final bool disabled;
  final bool isButtonRowVisible;
  final bool unsavedChanges;
  final StateProvider<T?> panelProvider;
  final VoidCallback? unsavedChangesDialog;

  const ELRightPanelContainer({
    super.key,
    required this.children,
    required this.title,
    this.onSave,
    this.onCancel = _noop,
    this.disabled = false,
    this.isLoading = false,
    this.isButtonRowVisible = false,
    this.unsavedChanges = false,
    required this.panelProvider,
    this.unsavedChangesDialog,
  });

  static void _noop() {
    return;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 450,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            width: 1,
          ),
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.regular.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.keyboard_tab,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: unsavedChangesDialog == null
                      ? () => ref.read(panelProvider.notifier).state = null
                      : () {
                          if (unsavedChanges) {
                            unsavedChangesDialog!();
                          } else {
                            ref.read(panelProvider.notifier).state = null;
                          }
                        },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
            ),
          ),
          Visibility(
            visible: isButtonRowVisible,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ELButton(
                    config: ELButtonConfig(
                      title: "Cancel",
                      colorConfig: ButtonColorConfig(ButtonColorType.outlinedPrimary, context),
                      isFixedSize: true,
                      width: 130,
                    ),
                    onPressed: onCancel,
                  ),
                  const SizedBox(width: 8),
                  ELButton(
                    config: ELButtonConfig(
                      title: "Save",
                      isLoading: isLoading,
                      disabled: disabled,
                      colorConfig: ButtonColorConfig(ButtonColorType.filledPrimary, context),
                      isFixedSize: true,
                      width: 130,
                    ),
                    onPressed: onSave,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
