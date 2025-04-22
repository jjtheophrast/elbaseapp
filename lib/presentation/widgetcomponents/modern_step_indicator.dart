import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernStepIndicator extends StatelessWidget {
  final int currentStep;
  final int stepCount;
  final List<String> stepTitles;
  final Function(int) onTap;

  const ModernStepIndicator({
    super.key,
    required this.currentStep,
    required this.stepCount,
    required this.stepTitles,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF37618E);
    final Color selectedTextColor = const Color(0xFF181C20);
    final Color lineColor = Colors.grey.shade300; // Consistent line color
    
    // Constants for line heights
    const double standardLineHeight = 16.0; // Standard line height for inactive steps
    const double extendedLineHeight = 40.0; // Extended line height for active step
    const double stepSpacing = 4.0; // Reduced spacing between steps
    
    return Container(
      width: 200,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(stepCount, (index) {
            final bool isActive = index == currentStep;
            final bool isPast = index < currentStep;
            final bool isClickable = isPast || isActive;
            final bool isNotLast = index < stepCount - 1;
            
            // Determine if this step's line should be extended
            // (only extend the line if it's the current active step)
            final bool extendLine = isActive && isNotLast;
            
            return Column(
              children: [
                // Step with number and text
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column for number and connecting line
                    SizedBox(
                      width: 32,
                      child: Column(
                        children: [
                          // Circle with number
                          GestureDetector(
                            onTap: isClickable ? () => onTap(index) : null,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive || isPast ? primaryColor : Colors.grey.shade200,
                                border: Border.all(
                                  color: isActive || isPast ? primaryColor : Colors.grey.shade400,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isActive || isPast ? Colors.white : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Gap between circle and line
                          if (isNotLast) const SizedBox(height: 2),
                          
                          // Connector line with dynamic height
                          if (isNotLast)
                            Container(
                              width: 1,
                              height: extendLine ? extendedLineHeight : standardLineHeight,
                              color: lineColor,
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Step Title
                    Expanded(
                      child: GestureDetector(
                        onTap: isClickable ? () => onTap(index) : null,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            stepTitles[index],
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                              color: isActive 
                                  ? selectedTextColor
                                  : (isPast ? Colors.black87 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Only add spacing if there's a connector line (for non-last items)
                if (isNotLast)
                  SizedBox(height: stepSpacing), // Minimal spacing between steps
              ],
            );
          }),
        ),
      ),
    );
  }
}
