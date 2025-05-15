import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Removed commented-out provider imports
import 'el_right_panel_destination.dart';

// Removed placeholder provider/class definitions

class ELRightPanelRail<T extends Enum> extends ConsumerWidget {
  final StateProvider<T?> panelProvider;
  final List<T> availableOptions;
  final List<ELRightPanelDestination> destinations;
  final Map<T, Widget Function()> panelBuilders;
  final Map<T, bool Function(T destination)>? panelHasUnsavedChanges;
  final Function(int)? onDestinationSelected;

  const ELRightPanelRail({
    super.key,
    required this.panelProvider,
    required this.availableOptions,
    required this.destinations,
    required this.panelBuilders,
    this.panelHasUnsavedChanges,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedOption = ref.watch(panelProvider);
    final selectedIndex = selectedOption != null ? availableOptions.indexOf(selectedOption) : null;

    // Return row with panel content and rail
    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Panel content (if selected)
          if (selectedOption != null)
            Container(
              width: 450,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: panelBuilders[selectedOption]?.call() ?? const SizedBox.shrink(),
            ),
          // The rail
          Container(
            width: 60,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(destinations.length, (index) {
                  final isSelected = selectedIndex == index;
                  final destination = destinations[index];
                  final paddingTop = index == 0 ? 16.0 : 8.0;
                  return Padding(
                    padding: EdgeInsets.only(top: paddingTop, bottom: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: Tooltip(
                            message: destination.tooltip ?? destination.label,
                            preferBelow: false,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: destination.disabled ? null : () {
                                final selected = availableOptions[index];
                                final current = ref.read(panelProvider);

                                // First call custom handler if provided
                                if (onDestinationSelected != null) {
                                  onDestinationSelected!(index);
                                  return;
                                }

                                // Default toggle behavior
                                if (current == selected) {
                                  ref.read(panelProvider.notifier).state = null;
                                } else {
                                  ref.read(panelProvider.notifier).state = selected;
                                }
                              },
                              child: Opacity(
                                opacity: destination.disabled ? 0.4 : 1.0,
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
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.onSurface
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 