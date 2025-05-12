import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/left_navigation_interaction_provider.dart';
import '../../providers/screen_size_provider.dart';
import '../../states/screen_size_state.dart';
import 'el_right_panel_destination.dart';

class ELRightPanelRail<T extends Enum> extends ConsumerWidget {
  final StateProvider<T?> panelProvider;
  final List<T> availableOptions;
  final List<ELRightPanelDestination> destinations;
  final Map<T, Widget Function()> panelBuilders;
  final Map<T, bool Function(T destination)>? panelHasUnsavedChanges;

  const ELRightPanelRail({
    super.key,
    required this.panelProvider,
    required this.availableOptions,
    required this.destinations,
    required this.panelBuilders,
    this.panelHasUnsavedChanges,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedOption = ref.watch(panelProvider);
    final screenSizeState = ref.watch(screenSizeProvider);
    final isExtraLargeScreen = screenSizeState == const ScreenSizeState.extraLarge();

    final selectedIndex = selectedOption != null ? availableOptions.indexOf(selectedOption) : null;

    return Row(
      children: [
        if (selectedOption != null)
          panelBuilders[selectedOption]?.call() ?? const SizedBox(),
        Container(
          width: 60,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                width: 1,
              ),
            ),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(destinations.length, (index) {
                final isSelected = selectedIndex == index;
                final destination = destinations[index];
                return Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: IgnorePointer(
                    ignoring: destination.disabled,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        final selected = availableOptions[index];
                        final current = ref.read(panelProvider);

                        if (panelHasUnsavedChanges != null &&
                            panelHasUnsavedChanges!.isNotEmpty &&
                            panelHasUnsavedChanges![selectedOption] != null) {
                          final unsavedChanges = panelHasUnsavedChanges![selectedOption]!(selected);
                          if (unsavedChanges) return;
                        }

                        if (current == selected) {
                          ref.read(panelProvider.notifier).state = null;
                          if (ref.read(leftNavigationMenuInteractionProvider.notifier).previousState == true) {
                            ref.read(leftNavigationMenuInteractionProvider.notifier).open();
                          }
                        } else {
                          ref.read(panelProvider.notifier).state = selected;
                          if (!isExtraLargeScreen) {
                            ref.read(leftNavigationMenuInteractionProvider.notifier).close();
                          }
                        }
                      },
                      child: Opacity(
                        opacity: destination.disabled ? 0.4 : 1.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Colors.transparent,
                            ),
                            child: Icon(
                              destination.icon.icon,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),

                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
