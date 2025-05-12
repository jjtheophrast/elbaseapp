import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppButtonStyles {
  static final Color primaryColor = const Color(0xFF37618E);
  
  // Primary filled button style
  static ButtonStyle primaryFilledButton = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 24),
    minimumSize: const Size(120, 40),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
    ),
    elevation: 0,
    textStyle: GoogleFonts.notoSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: 0.1,
    ),
  );
  
  // Outlined button style
  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 24),
    side: BorderSide(color: Colors.grey.shade300),
    minimumSize: const Size(120, 40),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
    ),
    textStyle: GoogleFonts.notoSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: 0.1,
    ),
  );
  
  // Text button style
  static ButtonStyle textButton = TextButton.styleFrom(
    foregroundColor: primaryColor,
    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 24),
    minimumSize: const Size(82, 40),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
    ),
    textStyle: GoogleFonts.notoSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43, 
      letterSpacing: 0.1,
    ),
  );
  
  // Text for button content with proper styling
  static Widget buttonText(String text) {
    return Text(
      text,
      style: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
      ),
      textAlign: TextAlign.center,
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
        height: 1.43,
        letterSpacing: 0.1,
      ),
    );
    
    final iconWidget = Icon(icon, size: 18);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: iconLeading 
        ? [iconWidget, const SizedBox(width: 8), textWidget]
        : [textWidget, const SizedBox(width: 8), iconWidget],
    );
  }
} 