import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/screen_size_state.dart';

final screenSizeProvider = StateNotifierProvider<ScreenSizeNotifier, ScreenSizeState>(
  (ref) => ScreenSizeNotifier(),
);

class ScreenSizeNotifier extends StateNotifier<ScreenSizeState> {
  static const double smallScreenMaxWidth = 840;
  static const double mediumScreenMaxWidth = 1250;
  static const double largeScreenMaxWidth = 1550;

  ScreenSizeNotifier() : super(const ScreenSizeState.small());

  void updateScreenSize(double width) {
    if (width < smallScreenMaxWidth) {
      _setScreenSize(const ScreenSizeState.small());
    } else if (width >= smallScreenMaxWidth && width <= mediumScreenMaxWidth) {
      _setScreenSize(const ScreenSizeState.medium());
    } else if (width >= mediumScreenMaxWidth && width <= largeScreenMaxWidth) {
      _setScreenSize(const ScreenSizeState.large());
    } else {
      _setScreenSize(const ScreenSizeState.extraLarge());
    }
  }

  void _setScreenSize(ScreenSizeState newSize) {
    if (state != newSize) {
      state = newSize;
    }
  }
}
