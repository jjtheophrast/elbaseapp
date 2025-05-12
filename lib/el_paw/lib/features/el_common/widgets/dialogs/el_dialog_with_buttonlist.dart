import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../el_theme/provider/theme_provider.dart';
import '../../../../providers/dialog_manager_state_notifier.dart';


class ELDialogWithButtonList extends ConsumerStatefulWidget {
  /// The title of the dialog
  final String title;

  /// Function to call when the dialog is closed with the "x" button.
  /// If this function is not given, the "x" button is not rendered
  final Function? onClose;

  /// Rows of text to put in the contents of the dialog
  final List<Widget> children;

  /// Rows of text to put in the contents of the dialog
  final List<Widget> buttonChildren;

  /// Optional width for the dialog
  final double? width;

  /// Optional external `isLoading` state
  final bool isLoading;

  /// Optional override for isLoading, for when Cancel button needs to be managed separately
  final bool? overrideIsLoadingWithValue;

  const ELDialogWithButtonList({
    super.key,
    required this.title,
    this.width,
    this.onClose,
    this.children = const [],
    this.buttonChildren = const [],
    this.isLoading = false, // External isLoading state
    this.overrideIsLoadingWithValue,
  });

  @override
  ConsumerState<ELDialogWithButtonList> createState() => _ELCustomDialogState();
}

class _ELCustomDialogState extends ConsumerState<ELDialogWithButtonList> {
  bool internalIsLoading = false;
  final FocusNode _focusNode = FocusNode();

  bool get isLoading => widget.isLoading;

  bool? get overrideIsLoadingValue => widget.overrideIsLoadingWithValue;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  void _setLoading(bool value) {
    // if (widget.isLoading == null) {
      setState(() {
        internalIsLoading = value;
      });
    // }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if ((event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape)) {
      ref.read(dialogManagerStateNotifierProvider.notifier).closeDialog();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
            ),
            if (widget.onClose != null)
              IconButton(
                onPressed: () {
                  widget.onClose!();
                },
                icon: Icon(
                  Icons.close,
                  size: 24,
                  color: context.colors.onSurface,
                ),
              )
          ],
        ),
        backgroundColor: Color.alphaBlend(
          context.colors.primary.withOpacity(0.11),
          context.colors.surface,
        ),
        surfaceTintColor: Colors.transparent,
        actions: [...widget.buttonChildren],
        content: SizedBox(
          width: widget.width ?? 451 - 24 - 24, // Default width if not provided
          child: DefaultTextStyle(
            style: theme.textTheme.bodyMedium!.copyWith(
              color: context.colors.onSurface,
            ),
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                ...widget.children,
              ]),
            ),
          ),
        ),
      ),
    );
  }
}