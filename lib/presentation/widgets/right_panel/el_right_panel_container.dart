import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Remove or replace this dependency
// import '../../../../../../util/theme_util.dart';
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
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and close button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.keyboard_tab,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    // Directly close the panel
                    ref.read(panelProvider.notifier).state = null;
                  },
                ),
              ],
            ),
          ),
          
          // Content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
          
          // Optional button row for actions
          if (isButtonRowVisible) 
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    width: 1,
                  ),
                ),
              ),
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
        ],
      ),
    );
  }
} 