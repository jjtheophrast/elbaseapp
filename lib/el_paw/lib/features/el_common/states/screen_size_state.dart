import 'package:freezed_annotation/freezed_annotation.dart';

part 'screen_size_state.freezed.dart';

@freezed
class ScreenSizeState with _$ScreenSizeState {
  const factory ScreenSizeState.small() = _Small;
  const factory ScreenSizeState.medium() = _Medium;
  const factory ScreenSizeState.large() = _Large;
  const factory ScreenSizeState.extraLarge() = _ExtraLarge;
}
