import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';

/// Tema de la aplicación — "Resonant Horizon"
/// Material 3 con paleta púrpura/indigo, glassmorphism y tipografía editorial
abstract final class AppTheme {
  // ============ TEMA CLARO ============
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentPrimary,
        brightness: Brightness.light,
        primary: AppColors.accentPrimary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.accentSecondary,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.accentSecondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.accentPrimary.withValues(alpha: 0.12),
        tertiary: AppColors.accentTertiary,
        surface: AppColors.bgSecondary,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.bgTertiary,
        surfaceContainerLow: AppColors.bgTertiary,
        error: AppColors.error,
        errorContainer: AppColors.errorContainer,
        outline: AppColors.outline,
        shadow: AppColors.shadow,
        scrim: AppColors.scrim,
      ),

      scaffoldBackgroundColor: AppColors.bgPrimary,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgPrimary.withValues(alpha: 0.8),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleMedium,
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.bgSecondary,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgSecondary.withValues(alpha: 0.9),
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

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSecondary,
        selectedItemColor: AppColors.accentPrimary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.bgSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          textStyle: AppTypography.buttonSmall,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeightSm),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          side: const BorderSide(color: AppColors.accentPrimary, width: 1.5),
          textStyle: AppTypography.buttonSmall,
        ),
      ),

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

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        sizeConstraints: const BoxConstraints.tightFor(
          width: AppSpacing.fabSizeSm,
          height: AppSpacing.fabSizeSm,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          borderSide: const BorderSide(
            color: AppColors.accentPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.helper,
        labelStyle: AppTypography.bodyMedium,
        floatingLabelStyle: AppTypography.label.copyWith(
          color: AppColors.accentPrimary,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.md,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.chipInactive,
        selectedColor: AppColors.accentPrimary,
        disabledColor: AppColors.divider,
        labelStyle: AppTypography.chipLabel,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        elevation: 0,
        pressElevation: 0,
      ),

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

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
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

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        minLeadingWidth: 24,
        horizontalTitleGap: AppSpacing.md,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentPrimary,
        linearTrackColor: AppColors.divider,
        circularTrackColor: AppColors.divider,
      ),

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

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      splashFactory: InkSparkle.splashFactory,
    );
  }

  // ============ TEMA OSCURO ============
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.accentPrimaryDark,
        onPrimary: AppColors.bgPrimaryDark,
        primaryContainer: AppColors.accentSecondaryDark,
        onPrimaryContainer: AppColors.bgPrimaryDark,
        secondary: AppColors.accentSecondaryDark,
        onSecondary: AppColors.bgPrimaryDark,
        secondaryContainer: Color(0xFF2A2A50),
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

      scaffoldBackgroundColor: AppColors.bgPrimaryDark,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgPrimaryDark.withValues(alpha: 0.8),
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
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

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgSecondaryDark.withValues(alpha: 0.9),
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

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSecondaryDark,
        selectedItemColor: AppColors.accentPrimaryDark,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: AppColors.bgSecondaryDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        shadowColor: Colors.black54,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimaryDark,
          foregroundColor: AppColors.bgPrimaryDark,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          textStyle: AppTypography.buttonSmall,
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentPrimaryDark,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeightSm),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          side: const BorderSide(
            color: AppColors.accentPrimaryDark,
            width: 1.5,
          ),
          textStyle: AppTypography.buttonSmall,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimaryDark,
          textStyle: AppTypography.buttonSmall,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentPrimaryDark,
        foregroundColor: AppColors.bgPrimaryDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgTertiaryDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
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

      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: AppSpacing.md,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.chipInactiveDark,
        selectedColor: AppColors.accentPrimaryDark,
        labelStyle: AppTypography.chipLabel.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),

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

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        iconColor: AppColors.textSecondaryDark,
        textColor: AppColors.textPrimaryDark,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentPrimaryDark,
        linearTrackColor: AppColors.outlineDark,
        circularTrackColor: AppColors.outlineDark,
      ),

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

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      splashFactory: InkSparkle.splashFactory,
    );
  }
}
