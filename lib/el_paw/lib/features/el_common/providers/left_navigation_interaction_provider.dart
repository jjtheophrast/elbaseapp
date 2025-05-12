import 'package:flutter/animation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widget/navigation_drawer/presentation/navigation.dart';
import '../../../widget/shell_page_body_wrapper/presentation/shell_page_body_wrapper.dart';
import '../states/screen_size_state.dart';
import 'right_panel_providers.dart';
import 'screen_size_provider.dart';

/// This provider manages the state of the [Navigation] widget.
final leftNavigationMenuInteractionProvider = StateNotifierProvider<LeftNavigationMenuInteraction, bool>((ref) {
  final screenSize = ref.watch(screenSizeProvider);
  return LeftNavigationMenuInteraction(ref, screenSize);
});

class LeftNavigationMenuInteraction extends StateNotifier<bool> {
  final Ref ref;
  final bool isSmallScreen;
  final ScreenSizeState screenSizeState;

  // final bool isExtraLargeScreen;
  bool _previousState = true;

  AnimationController? backgroundLayerAnimationController;
  double? backgroundLayerWidth;

  LeftNavigationMenuInteraction(this.ref, this.screenSizeState)
      : isSmallScreen = _isSmallScreen(screenSizeState),
  // isExtraLargeScreen = _isExtraLargeScreen(screenSize),
        backgroundLayerWidth = _getBackgroundWidth(screenSizeState),
        super(!_isSmallScreen(screenSizeState));

  static bool _isSmallScreen(ScreenSizeState screenSize) {
    return screenSize.when(
      small: () => true,
      medium: () => true,
      large: () => false,
      extraLarge: () => false,
    );
  }

  static double _getBackgroundWidth(ScreenSizeState screenSize) {
    return screenSize.when(
      small: () => 0,
      medium: () => 0,
      large: () => ShellPageBodyWrapper.openedWidth,
      extraLarge: () => ShellPageBodyWrapper.openedWidth,
    );
  }

  bool get previousState => _previousState;

  void setState(bool newState) {
    state = newState;
  }

  void open() {
    _previousState = state;
    if (screenSizeState != const ScreenSizeState.extraLarge()) {
      RightPanelProviders.closeAllRightPanels(ref);
    }
    backgroundLayerAnimationController?.value = 1;
    backgroundLayerWidth = ShellPageBodyWrapper.openedWidth;
    backgroundLayerAnimationController?.forward();
    state = true;
  }

  void close() {
    _previousState = state;
    backgroundLayerAnimationController?.value = 0;
    backgroundLayerWidth = isSmallScreen ? 0 : ShellPageBodyWrapper.closedWidth;
    backgroundLayerAnimationController?.reverse();
    state = false;
  }

  void toggle() {
    _previousState = state;
    state == false ? open() : close();
  }
}
