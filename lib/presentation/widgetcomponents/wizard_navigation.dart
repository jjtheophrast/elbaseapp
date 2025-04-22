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
    final primaryColor = const Color(0xFF266DAF);
    
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
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              
              // Back to Review button (if applicable)
              if (isFromReviewStep && onBackToReview != null)
                TextButton(
                  onPressed: onBackToReview,
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    'Back to Review',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                
              // Small spacing between buttons
              const SizedBox(width: 8),
              
              // Next button
              ElevatedButton(
                onPressed: canProceed ? (isLastStep ? onComplete : onNext) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  isLastStep ? 'Start crawl!' : 'Next',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
