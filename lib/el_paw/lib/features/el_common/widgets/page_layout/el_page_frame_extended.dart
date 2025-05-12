import 'package:flutter/material.dart';

import '../../../../util/theme_util.dart';

class ELPageFrameExtended extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottomWidget;
  final Widget headerNotification;

  const ELPageFrameExtended({
    super.key,
    required this.title,
    required this.child,
    this.bottomWidget,
    this.headerNotification = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Stack(children: [
          SingleChildScrollView(
            child: SizedBox(
              height: screenSize,
              child: Column(
                children: [
                  // Page Header
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.semiBold.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(
                                width: 28,
                              ),
                              Flexible(child: headerNotification),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: child,
                  ),
                ],
              ),
            ),
          ),
          if (bottomWidget != null) bottomWidget!,
        ]),
      ),
    );
  }
}

