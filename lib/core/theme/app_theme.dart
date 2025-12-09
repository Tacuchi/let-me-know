import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';

/// Tema de la aplicación basado en Material 3 (2025)
/// Optimizado para accesibilidad de adultos mayores
/// Soporta tema claro y oscuro con transiciones suaves
abstract final class AppTheme {
  // ============ TEMA CLARO ============
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme Material 3
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentPrimary,
        brightness: Brightness.light,
        primary: AppColors.accentPrimary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.accentPrimary.withValues(alpha: 0.12),
        secondary: AppColors.accentSecondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.accentSecondary.withValues(alpha: 0.12),
        tertiary: AppColors.accentTertiary,
        surface: AppColors.bgSecondary,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.bgTertiary,
        error: AppColors.error,
        errorContainer: AppColors.errorContainer,
        outline: AppColors.outline,
        shadow: AppColors.shadow,
        scrim: AppColors.scrim,
      ),

      // Scaffolding
      scaffoldBackgroundColor: AppColors.bgPrimary,

      // AppBar mejorado con Material 3
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgSecondary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: AppTypography.titleMedium,
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.bgSecondary,
        ),
      ),

      // Navigation Bar Material 3
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgSecondary,
        indicatorColor: AppColors.accentPrimary.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.accentPrimary,
              size: 26,
            );
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.label.copyWith(
              color: AppColors.accentPrimary,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.label.copyWith(color: AppColors.textSecondary);
        }),
      ),

      // Bottom Navigation (legacy)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSecondary,
        selectedItemColor: AppColors.accentPrimary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Cards con efecto sutil
      cardTheme: CardThemeData(
        color: AppColors.bgSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      // Elevated Buttons con estilo moderno
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentSecondary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              textStyle: AppTypography.button,
              elevation: 2,
              shadowColor: AppColors.accentSecondary.withValues(alpha: 0.4),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.white.withValues(alpha: 0.1);
                }
                return null;
              }),
            ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeightSm),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          side: const BorderSide(color: AppColors.accentPrimary, width: 2),
          textStyle: AppTypography.button,
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          textStyle: AppTypography.buttonSmall,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: Colors.white,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
        shape: const CircleBorder(),
        sizeConstraints: const BoxConstraints.tightFor(
          width: AppSpacing.fabSize,
          height: AppSpacing.fabSize,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSecondary,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.accentPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.helper,
        labelStyle: AppTypography.bodyMedium,
        floatingLabelStyle: AppTypography.label.copyWith(
          color: AppColors.accentPrimary,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.md,
      ),

      // Chips mejorados
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgTertiary,
        selectedColor: AppColors.accentPrimary,
        disabledColor: AppColors.divider,
        labelStyle: AppTypography.label,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        elevation: 0,
        pressElevation: 0,
      ),

      // Dialog mejorado
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgSecondary,
        elevation: 8,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        titleTextStyle: AppTypography.titleSmall,
        contentTextStyle: AppTypography.bodyMedium,
        surfaceTintColor: Colors.transparent,
      ),

      // Snackbar moderno
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        elevation: 4,
      ),

      // Switch mejorado
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.textHelper;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentPrimary;
          }
          return AppColors.divider;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // List Tile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        minLeadingWidth: 24,
        horizontalTitleGap: AppSpacing.md,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentPrimary,
        linearTrackColor: AppColors.divider,
        circularTrackColor: AppColors.divider,
      ),

      // Text theme
      textTheme: const TextTheme(
        headlineLarge: AppTypography.titleLarge,
        headlineMedium: AppTypography.titleMedium,
        headlineSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.label,
        labelSmall: AppTypography.helper,
      ),

      // Animaciones de página
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Splash
      splashFactory: InkSparkle.splashFactory,
    );
  }

  // ============ TEMA OSCURO ============
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme Material 3 Dark - Manual para control total
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.accentPrimaryDark,
        onPrimary: AppColors.bgPrimaryDark,
        primaryContainer: Color(0xFF3D2A1F),
        onPrimaryContainer: AppColors.accentPrimaryDark,
        secondary: AppColors.accentSecondaryDark,
        onSecondary: AppColors.bgPrimaryDark,
        secondaryContainer: Color(0xFF1F3D35),
        onSecondaryContainer: AppColors.accentSecondaryDark,
        tertiary: AppColors.accentTertiary,
        surface: AppColors.bgSecondaryDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.bgTertiaryDark,
        surfaceContainerHigh: AppColors.bgTertiaryDark,
        surfaceContainer: AppColors.bgSecondaryDark,
        surfaceContainerLow: AppColors.bgPrimaryDark,
        surfaceContainerLowest: AppColors.bgPrimaryDark,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: Color(0xFF3D1F1F),
        outline: AppColors.outlineDark,
        outlineVariant: AppColors.dividerDark,
        shadow: Colors.black54,
        scrim: Colors.black87,
        inverseSurface: AppColors.bgSecondary,
        onInverseSurface: AppColors.textPrimary,
        inversePrimary: AppColors.accentPrimary,
      ),

      // Scaffolding
      scaffoldBackgroundColor: AppColors.bgPrimaryDark,

      // AppBar oscuro
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgSecondaryDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: AppTypography.titleMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        shadowColor: Colors.black45,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.bgSecondaryDark,
        ),
      ),

      // Navigation Bar Dark
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgSecondaryDark,
        indicatorColor: AppColors.accentPrimaryDark.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.accentPrimaryDark,
              size: 26,
            );
          }
          return const IconThemeData(
            color: AppColors.textSecondaryDark,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.label.copyWith(
              color: AppColors.accentPrimaryDark,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.label.copyWith(
            color: AppColors.textSecondaryDark,
          );
        }),
      ),

      // Bottom Navigation Dark
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSecondaryDark,
        selectedItemColor: AppColors.accentPrimaryDark,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Cards Dark
      cardTheme: CardThemeData(
        color: AppColors.bgSecondaryDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        shadowColor: Colors.black54,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      // Elevated Buttons Dark
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentSecondaryDark,
          foregroundColor: AppColors.bgPrimaryDark,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          textStyle: AppTypography.button,
          elevation: 2,
        ),
      ),

      // Outlined Buttons Dark
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentPrimaryDark,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeightSm),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          side: const BorderSide(color: AppColors.accentPrimaryDark, width: 2),
          textStyle: AppTypography.button,
        ),
      ),

      // Text Buttons Dark
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimaryDark,
          textStyle: AppTypography.buttonSmall,
        ),
      ),

      // FAB Dark
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentPrimaryDark,
        foregroundColor: AppColors.bgPrimaryDark,
        elevation: 6,
        shape: CircleBorder(),
      ),

      // Input Decoration Dark
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgTertiaryDark,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.outlineDark,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.outlineDark,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.accentPrimaryDark,
            width: 2,
          ),
        ),
        hintStyle: AppTypography.helper.copyWith(
          color: AppColors.textHelperDark,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),

      // Divider Dark
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: AppSpacing.md,
      ),

      // Chips Dark
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgTertiaryDark,
        selectedColor: AppColors.accentPrimaryDark,
        labelStyle: AppTypography.label.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),

      // Dialog Dark
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgSecondaryDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        titleTextStyle: AppTypography.titleSmall.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Snackbar Dark
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgTertiaryDark,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),

      // Switch Dark
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.bgPrimaryDark;
          }
          return AppColors.textHelperDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentPrimaryDark;
          }
          return AppColors.outlineDark;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // List Tile Dark
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        iconColor: AppColors.textSecondaryDark,
        textColor: AppColors.textPrimaryDark,
      ),

      // Progress Indicator Dark
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentPrimaryDark,
        linearTrackColor: AppColors.outlineDark,
        circularTrackColor: AppColors.outlineDark,
      ),

      // Text theme Dark
      textTheme: TextTheme(
        headlineLarge: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineMedium: AppTypography.titleMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineSmall: AppTypography.titleSmall.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodySmall: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        labelLarge: AppTypography.button.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        labelMedium: AppTypography.label.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        labelSmall: AppTypography.helper.copyWith(
          color: AppColors.textHelperDark,
        ),
      ),

      // Animaciones de página
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Splash
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
