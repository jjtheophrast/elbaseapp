import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../el_theme/provider/theme_provider.dart';
import '../../../../providers/dialog_manager_state_notifier.dart';
import '../buttons/button_color_config.dart';
import '../buttons/el_button.dart';
import '../buttons/el_button_config.dart';

class ELAlertDialog extends ConsumerStatefulWidget {
  /// The title of the dialog
  final String title;

  /// Cancel button text
  final String? cancelBtnText;

  /// OK button text
  final String? okBtnText;

  /// Delete button text
  final String? deleteBtnText;

  /// Function to call when the cancel button is pressed
  final Function? onCancel;

  /// Function to call when the OK button is pressed
  final Function? onOk;

  /// Function to call when the delete button is pressed
  final Function? onDelete;

  /// Function to call when the dialog is closed with the "x" button.
  /// If this function is not given, the "x" button is not rendered
  final Function? onClose;

  /// Rows of text to put in the contents of the dialog
  final List<Widget> children;

  /// Optional width for the dialog
  final double? width;

  /// Optional external `isLoading` state
  final bool? isLoading;

  /// Optional override for isLoading, for when Cancel button needs to be managed separately
  final bool? overrideIsLoadingWithValue;

  const ELAlertDialog({
    super.key,
    required this.title,
    this.width,
    this.cancelBtnText,
    this.deleteBtnText,
    this.okBtnText,
    this.onCancel,
    this.onDelete,
    this.onOk,
    this.onClose,
    this.children = const [],
    this.isLoading, // External isLoading state
    this.overrideIsLoadingWithValue,
  })  : assert((okBtnText != null && deleteBtnText == null) || (okBtnText == null && deleteBtnText != null),
            'Only one of [okBtnText] and [deleteBtnText] should be given'),
        assert(okBtnText != null || onOk == null, 'Function [onOk] must not be null, if [okBtnText] is given'),
        assert(deleteBtnText != null || onDelete == null,
            'Function [onDelete] must not be null, if [deleteBtnText] is given');

  @override
  ConsumerState<ELAlertDialog> createState() => _ELAlertDialogState();
}

class _ELAlertDialogState extends ConsumerState<ELAlertDialog> {
  bool internalIsLoading = false;
  final FocusNode _focusNode = FocusNode();

  bool get isLoading => widget.isLoading ?? internalIsLoading;
  bool? get overrideIsLoadingValue => widget.overrideIsLoadingWithValue;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  void _setLoading(bool value) {
    if (widget.isLoading == null) {
      setState(() {
        internalIsLoading = value;
      });
    }
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
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: context.typography.fTokens.regular.headLine.small.copyWith(
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
        actions: [
          if (widget.cancelBtnText != null)
            ELButton(
              config: ELButtonConfig(
                title: widget.cancelBtnText!,
                disabled: overrideIsLoadingValue ?? isLoading,
                colorConfig: ButtonColorConfig(ButtonColorType.textPrimary, context),
              ),
              onPressed: () {
                _setLoading(true);
                widget.onCancel?.call();
                _setLoading(false);
              },
            ),
          if (widget.okBtnText != null)
            ELButton(
              config: ELButtonConfig(
                title: widget.okBtnText!,
                colorConfig: ButtonColorConfig(ButtonColorType.filledPrimary, context),
                disabled: widget.onOk == null || isLoading,
              ),
              onPressed: () {
                _setLoading(true);
                widget.onOk?.call();
                _setLoading(false);
              },
            )
          else
            ELButton(
              config: ELButtonConfig(
                title: widget.deleteBtnText!,
                colorConfig: ButtonColorConfig(ButtonColorType.filledDelete, context),
                disabled: isLoading,
              ),
              onPressed: () {
                _setLoading(true);
                widget.onDelete?.call();
                _setLoading(false);
              },
            ),
        ],
        content: SizedBox(
          width: widget.width ?? 451 - 24 - 24, // Default width if not provided
          child: DefaultTextStyle(
            style: context.typography.fTokens.regular.body.medium.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: widget.children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
