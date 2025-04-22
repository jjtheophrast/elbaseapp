import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppButtonStyles {
  static final Color primaryColor = const Color(0xFF37618E);
  
  // Primary filled button style
  static ButtonStyle primaryFilledButton = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
    minimumSize: const Size(120, 40),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
    ),
    elevation: 0,
  );
  
  // Outlined button style
  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    side: BorderSide(color: Colors.grey.shade300),
    minimumSize: const Size(120, 40),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
    ),
  );
  
  // Text button style
  static ButtonStyle textButton = TextButton.styleFrom(
    foregroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    minimumSize: const Size(82, 40),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
    ),
  );
  
  // Text for button content with proper styling
  static Widget buttonText(String text) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Icon and text layout for buttons
  static Widget buttonWithIcon({
    required String text,
    required IconData icon,
    bool iconLeading = false,
  }) {
    final textWidget = Text(
      text,
      style: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
    
    final iconWidget = Icon(icon, size: 18);
    
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: iconLeading 
          ? [iconWidget, const SizedBox(width: 8), textWidget]
          : [textWidget, const SizedBox(width: 8), iconWidget],
      ),
    );
  }
} 