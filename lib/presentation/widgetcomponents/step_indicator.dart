import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;
  final Function(int) onStepTap;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalSteps,
        itemBuilder: (context, index) {
          bool isActive = index == currentStep;
          bool isPast = index < currentStep;
          bool canNavigate = isPast || index == currentStep;

          return GestureDetector(
            onTap: canNavigate ? () => onStepTap(index) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // Circle indicator with step number
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : isPast
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.7)
                                  : Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant,
                          border: Border.all(
                            color:
                                isPast || isActive
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color:
                                  isActive || isPast
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      // Horizontal line connector
                      if (index < totalSteps - 1)
                        Container(
                          width: 40,
                          height: 2,
                          color:
                              isPast
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stepTitles[index],
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isActive
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
