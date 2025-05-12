import 'package:flutter/material.dart';

import '../../../../util/theme_util.dart';

class ELPageFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget headerNotification;

  const ELPageFrame(
      {super.key, required this.title, required this.child, this.headerNotification = const SizedBox.shrink()});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        children: [
          Container(
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
                const SizedBox(width: 28,),
                Flexible(child: headerNotification),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
