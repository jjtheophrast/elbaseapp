import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../glossary/presentation/state/enums/glossary_right_panel_option.dart';

/// Stores page-specific right panel state providers
class RightPanelProviders {
  static final glossaryRightPanelProvider = StateProvider<GlossaryRightPanelOption?>((ref) => null);

  static final List<StateProvider<dynamic>> _rightPanelProviders = [
    glossaryRightPanelProvider,
  ];

  static void closeRightPanel(Ref ref, StateProvider<dynamic> provider) {
    ref.read(provider.notifier).state = null;
  }

  static void closeAllRightPanels(Ref ref) {
    for (final provider in _rightPanelProviders) {
      ref.read(provider.notifier).state = null;
    }
  }
}