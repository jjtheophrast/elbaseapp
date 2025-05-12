import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/screen_size_provider.dart';
import '../../states/screen_size_state.dart';
import '../right_panel/el_right_panel_rail.dart';
import 'el_page_frame.dart';
import 'el_page_frame_extended.dart';

class ELPageFrameWithRightPanel extends ConsumerWidget {
  final List<Widget>? headerNotifications;
  final Widget page;
  final Widget? bottomWidget;
  final ELRightPanelRail rightPanelRail;
  final String pageTitle;
  final bool isExtendedPageType;

  const ELPageFrameWithRightPanel({
    super.key,
    this.headerNotifications,
    required this.page,
    this.bottomWidget,
    required this.rightPanelRail,
    required this.pageTitle,
    this.isExtendedPageType = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSizeState = ref.watch(screenSizeProvider);
    final isSmallerScreen =
        screenSizeState == const ScreenSizeState.small() || screenSizeState == const ScreenSizeState.medium();

    return isSmallerScreen
        ? Scaffold(
            body: Stack(
              children: [
                bottomWidget != null || isExtendedPageType
                    ? ELPageFrameExtended(
                        title: pageTitle,
                        headerNotification: headerNotifications == null
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(right: 48.0),
                                child: Column(
                                  children: headerNotifications!,
                                ),
                              ),
                        bottomWidget: bottomWidget,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                          child: page,
                        ),
                      )
                    : ELPageFrame(
                        title: pageTitle,
                        headerNotification: headerNotifications == null
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(right: 48.0),
                                child: Column(
                                  children: headerNotifications!,
                                ),
                              ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                          child: page,
                        ),
                      ),
                Row(
                  children: [
                    const Spacer(),
                    rightPanelRail,
                  ],
                ),
              ],
            ),
          )
        : Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: bottomWidget != null || isExtendedPageType
                      ? ELPageFrameExtended(
                          title: pageTitle,
                          headerNotification: headerNotifications == null
                              ? const SizedBox.shrink()
                              : Column(
                                  children: headerNotifications!,
                                ),
                          bottomWidget: bottomWidget,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                            child: page,
                          ),
                        )
                      : ELPageFrame(
                          title: pageTitle,
                          headerNotification: headerNotifications == null
                              ? const SizedBox.shrink()
                              : Column(
                                  children: headerNotifications!,
                                ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                            child: page,
                          ),
                        ),
                ),
                Row(
                  children: [
                    rightPanelRail,
                  ],
                ),
              ],
            ),
          );
  }
}
