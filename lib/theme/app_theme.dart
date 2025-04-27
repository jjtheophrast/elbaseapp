import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static late ColorScheme _colorScheme;
  static bool _isInitialized = false;

  // Add a getter for the color scheme
  static ColorScheme get colorScheme {
    if (!_isInitialized) {
      throw Exception('AppTheme must be initialized before accessing color scheme');
    }
    return _colorScheme;
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    final jsonString = await rootBundle.loadString('lib/theme/light_dark.json');
    final themeJson = json.decode(jsonString);
    final lightColors = themeJson['light'];

    _colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(int.parse(lightColors['primary'].substring(1, 7), radix: 16) + 0xFF000000),
      onPrimary: Color(int.parse(lightColors['onPrimary'].substring(1, 7), radix: 16) + 0xFF000000),
      primaryContainer: Color(int.parse(lightColors['primaryContainer'].substring(1, 7), radix: 16) + 0xFF000000),
      onPrimaryContainer: Color(int.parse(lightColors['onPrimaryContainer'].substring(1, 7), radix: 16) + 0xFF000000),
      secondary: Color(int.parse(lightColors['secondary'].substring(1, 7), radix: 16) + 0xFF000000),
      onSecondary: Color(int.parse(lightColors['onSecondary'].substring(1, 7), radix: 16) + 0xFF000000),
      secondaryContainer: Color(int.parse(lightColors['secondaryContainer'].substring(1, 7), radix: 16) + 0xFF000000),
      onSecondaryContainer: Color(int.parse(lightColors['onSecondaryContainer'].substring(1, 7), radix: 16) + 0xFF000000),
      tertiary: Color(int.parse(lightColors['tertiary'].substring(1, 7), radix: 16) + 0xFF000000),
      onTertiary: Color(int.parse(lightColors['onTertiary'].substring(1, 7), radix: 16) + 0xFF000000),
      error: Color(int.parse(lightColors['error'].substring(1, 7), radix: 16) + 0xFF000000),
      onError: Color(int.parse(lightColors['onError'].substring(1, 7), radix: 16) + 0xFF000000),
      background: Color(int.parse(lightColors['background'].substring(1, 7), radix: 16) + 0xFF000000),
      onBackground: Color(int.parse(lightColors['onBackground'].substring(1, 7), radix: 16) + 0xFF000000),
      surface: Color(int.parse(lightColors['surface'].substring(1, 7), radix: 16) + 0xFF000000),
      onSurface: Color(int.parse(lightColors['onSurface'].substring(1, 7), radix: 16) + 0xFF000000),
      surfaceVariant: Color(int.parse(lightColors['surfaceVariant'].substring(1, 7), radix: 16) + 0xFF000000),
      onSurfaceVariant: Color(int.parse(lightColors['onSurfaceVariant'].substring(1, 7), radix: 16) + 0xFF000000),
      outline: Color(int.parse(lightColors['outline'].substring(1, 7), radix: 16) + 0xFF000000),
      outlineVariant: Color(int.parse(lightColors['outlineVariant'].substring(1, 7), radix: 16) + 0xFF000000),
      shadow: Color(int.parse(lightColors['shadow'].substring(1, 7), radix: 16) + 0xFF000000),
    );

    _isInitialized = true;
  }

  // Typography
  static final TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 28,
      letterSpacing: -0.5,
      color: _colorScheme.onSurface,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 24,
      letterSpacing: -0.5,
      color: _colorScheme.onSurface,
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      letterSpacing: -0.25,
      color: _colorScheme.onSurface,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      letterSpacing: 0,
      color: _colorScheme.onSurface,
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: 0,
      color: _colorScheme.onSurface,
    ),
    titleSmall: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: 0,
      color: _colorScheme.onSurface,
    ),
    bodyLarge: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 16,
      letterSpacing: 0.15,
      color: _colorScheme.onSurface.withOpacity(0.9),
    ),
    bodyMedium: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      letterSpacing: 0.15,
      color: _colorScheme.onSurface.withOpacity(0.9),
    ),
    bodySmall: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 12,
      letterSpacing: 0.1,
      color: _colorScheme.onSurfaceVariant,
    ),
    labelLarge: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      letterSpacing: 0.1,
      color: _colorScheme.primary,
    ),
    displayLarge: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 24,
      color: Colors.black87,
    ),
    displayMedium: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: Colors.black87,
    ),
    displaySmall: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: Colors.black87,
    ),
    labelMedium: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: Colors.black87,
    ),
    labelSmall: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: _colorScheme.error,
      height: 1,
    ),
  );

  // Custom text styles for restrictions screen
  static final TextStyle crs_BodyMonospace = TextStyle(
    fontFamily: 'NotoSans',
    fontSize: 14,
    color: _colorScheme.onSurface,
  );

  // Wizard step title style
  static final TextStyle crs_StepTitle = TextStyle(
    fontFamily: 'NotoSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: _colorScheme.onSurface,
  );

  // Type screen styles
  static final TextStyle crs_TypeTitle = TextStyle(
    fontFamily: 'NotoSans',
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static final TextStyle crs_TypeSubtitle = TextStyle(
    fontFamily: 'NotoSans',
    fontSize: 14,
    color: Colors.black87,
  );

  static final TextStyle crs_TypeLabel = TextStyle(
    fontFamily: 'NotoSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static final TextStyle crs_TypeText = TextStyle(
    fontFamily: 'NotoSans',
    fontSize: 14,
    color: Colors.black87,
  );

  static final TextStyle crs_TypeMono = TextStyle(
    fontFamily: 'NotoSans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  // Light theme
  static ThemeData get lightTheme {
    if (!_isInitialized) {
      throw Exception('AppTheme must be initialized before accessing theme data');
    }

    // Create a text theme using Google Fonts NotoSans
    final notoSansTextTheme = GoogleFonts.notoSansTextTheme(textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      textTheme: notoSansTextTheme,
      fontFamily: GoogleFonts.notoSans().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: _colorScheme.surface,
        foregroundColor: _colorScheme.primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: notoSansTextTheme.titleMedium?.copyWith(
          color: _colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: _colorScheme.primary, size: 22),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _colorScheme.outlineVariant, width: 1),
        ),
        color: _colorScheme.surface,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _colorScheme.primary,
          foregroundColor: _colorScheme.onPrimary,
          minimumSize: const Size(120, 40),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          elevation: 0,
          textStyle: notoSansTextTheme.bodyMedium?.copyWith(
            fontSize: 14,
            height: 1.4285,
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          iconSize: MaterialStateProperty.all(18),
          iconColor: MaterialStateProperty.all(_colorScheme.onPrimary),
          padding: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return const EdgeInsets.symmetric(horizontal: 24, vertical: 10);
            }
            // Check if button has icon
            return const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 16,
              right: 24,
            );
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _colorScheme.primary,
          minimumSize: const Size(120, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          side: BorderSide(color: _colorScheme.primary),
          textStyle: notoSansTextTheme.bodyMedium?.copyWith(
            fontSize: 14,
            height: 1.4285,
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          iconSize: MaterialStateProperty.all(18),
          iconColor: MaterialStateProperty.all(_colorScheme.primary),
          padding: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
            }
            // Check if button has icon
            return const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 16,
              right: 16,
            );
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _colorScheme.primary,
          minimumSize: const Size(82, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          textStyle: notoSansTextTheme.bodyMedium?.copyWith(
            fontSize: 14,
            height: 1.4285,
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          iconSize: MaterialStateProperty.all(18),
          iconColor: MaterialStateProperty.all(_colorScheme.primary),
          padding: MaterialStateProperty.resolveWith((states) {
            // For delete color text buttons
            if (states.contains(MaterialState.error)) {
              return const EdgeInsets.symmetric(horizontal: 2, vertical: 10);
            }
            // For primary color text buttons with icon
            if (states.contains(MaterialState.selected)) {
              return const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 12,
                right: 16,
              );
            }
            // Default text button padding
            return const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
          }),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _colorScheme.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _colorScheme.outlineVariant, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: false,
        hintStyle: TextStyle(
          color: _colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: _colorScheme.onSurface,
          fontSize: 14,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return _colorScheme.primary;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return _colorScheme.primary;
          }
          return Colors.grey;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return _colorScheme.primary;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return _colorScheme.primary.withOpacity(0.4);
          }
          return _colorScheme.surfaceVariant;
        }),
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        titleTextStyle: notoSansTextTheme.bodyLarge,
        subtitleTextStyle: notoSansTextTheme.bodySmall,
      ),
      dividerTheme: DividerThemeData(
        space: 16,
        thickness: 1,
        color: _colorScheme.outlineVariant,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _colorScheme.surfaceVariant,
        labelStyle: TextStyle(color: _colorScheme.onSurfaceVariant),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: _colorScheme.primary,
        unselectedLabelColor: _colorScheme.onSurfaceVariant,
        indicator: BoxDecoration(
          border: Border(bottom: BorderSide(color: _colorScheme.primary, width: 2)),
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        textColor: _colorScheme.primary,
        iconColor: _colorScheme.primary,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _colorScheme.primary,
        inactiveTrackColor: _colorScheme.surfaceVariant,
        thumbColor: _colorScheme.primary,
        overlayColor: _colorScheme.primary.withOpacity(0.2),
        valueIndicatorColor: _colorScheme.primary,
        valueIndicatorTextStyle: TextStyle(color: _colorScheme.onPrimary),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        titleTextStyle: notoSansTextTheme.titleLarge,
        contentTextStyle: notoSansTextTheme.bodyMedium,
        backgroundColor: _colorScheme.surface,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: _colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: TextStyle(color: _colorScheme.onInverseSurface),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      scaffoldBackgroundColor: _colorScheme.background,
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        backgroundColor: _colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
