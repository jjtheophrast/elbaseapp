// File: lib/widgets/wizard_navigation.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WizardNavigation extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isLastStep;
  final VoidCallback onComplete;
  final bool isFromReviewStep;
  final VoidCallback? onBackToReview;
  final bool canProceed;

  const WizardNavigation({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onBack,
    required this.isLastStep,
    required this.onComplete,
    this.isFromReviewStep = false,
    this.onBackToReview,
    this.canProceed = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Left side can have a different widget if needed
          const Spacer(),
          
          // Navigation buttons grouped together
          Row(
            children: [
              // Back button (only if not on first step)
              if (currentStep > 0)
                TextButton(
                  onPressed: onBack,
                  child: Text(
                    'Back',
                  ),
                ),
              
              // Back to Review button (if applicable)
              if (isFromReviewStep && onBackToReview != null)
                TextButton(
                  onPressed: onBackToReview,
                  child: Text(
                    'Back to Review',
                  ),
                ),
                
              // Small spacing between buttons
              const SizedBox(width: 8),
              
              // Next button
              ElevatedButton(
                onPressed: canProceed ? (isLastStep ? onComplete : onNext) : null,
                child: Text(
                  isLastStep ? 'Start crawl!' : 'Next',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
