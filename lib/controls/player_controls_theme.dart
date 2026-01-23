import 'package:flutter/material.dart';

/// Theme configuration for player controls.
/// Allows easy customization without rebuilding UI.
class PlayerControlsTheme {
  // Colors
  final Color primaryColor;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color progressBarColor;
  final Color progressBarBackgroundColor;
  
  // Sizes
  final double mainIconSize;
  final double secondaryIconSize;
  final double progressBarHeight;
  final double borderRadius;
  
  // Text Styles
  final TextStyle? timeTextStyle;
  final TextStyle? buttonTextStyle;
  
  // Behavior
  final bool autoHideControls;
  final Duration autoHideDuration;
  final Duration animationDuration;
  
  // Opacity
  final double controlsBackgroundOpacity;

  const PlayerControlsTheme({
    this.primaryColor = Colors.blue,
    this.backgroundColor = Colors.black54,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.progressBarColor = Colors.blue,
    this.progressBarBackgroundColor = Colors.white30,
    this.mainIconSize = 60,
    this.secondaryIconSize = 40,
    this.progressBarHeight = 3,
    this.borderRadius = 8,
    this.timeTextStyle,
    this.buttonTextStyle,
    this.autoHideControls = true,
    this.autoHideDuration = const Duration(seconds: 3),
    this.animationDuration = const Duration(milliseconds: 300),
    this.controlsBackgroundOpacity = 0.54,
  });

  /// Create a dark theme
  factory PlayerControlsTheme.dark() {
    return const PlayerControlsTheme(
      primaryColor: Colors.white,
      backgroundColor: Colors.black54,
      iconColor: Colors.white,
      textColor: Colors.white,
    );
  }

  /// Create a light theme
  factory PlayerControlsTheme.light() {
    return const PlayerControlsTheme(
      primaryColor: Colors.blue,
      backgroundColor: Colors.white70,
      iconColor: Colors.black87,
      textColor: Colors.black87,
      progressBarColor: Colors.blue,
      progressBarBackgroundColor: Colors.black26,
    );
  }

  /// Create a custom theme with specific brand colors
  factory PlayerControlsTheme.brand({
    required Color primaryColor,
    Brightness brightness = Brightness.dark,
  }) {
    final isDark = brightness == Brightness.dark;
    return PlayerControlsTheme(
      primaryColor: primaryColor,
      backgroundColor: isDark ? Colors.black54 : Colors.white70,
      iconColor: isDark ? Colors.white : Colors.black87,
      textColor: isDark ? Colors.white : Colors.black87,
      progressBarColor: primaryColor,
      progressBarBackgroundColor: isDark ? Colors.white30 : Colors.black26,
    );
  }

  /// Copy with modifications
  PlayerControlsTheme copyWith({
    Color? primaryColor,
    Color? backgroundColor,
    Color? iconColor,
    Color? textColor,
    Color? progressBarColor,
    Color? progressBarBackgroundColor,
    double? mainIconSize,
    double? secondaryIconSize,
    double? progressBarHeight,
    double? borderRadius,
    TextStyle? timeTextStyle,
    TextStyle? buttonTextStyle,
    bool? autoHideControls,
    Duration? autoHideDuration,
    Duration? animationDuration,
    double? controlsBackgroundOpacity,
  }) {
    return PlayerControlsTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      iconColor: iconColor ?? this.iconColor,
      textColor: textColor ?? this.textColor,
      progressBarColor: progressBarColor ?? this.progressBarColor,
      progressBarBackgroundColor: progressBarBackgroundColor ?? this.progressBarBackgroundColor,
      mainIconSize: mainIconSize ?? this.mainIconSize,
      secondaryIconSize: secondaryIconSize ?? this.secondaryIconSize,
      progressBarHeight: progressBarHeight ?? this.progressBarHeight,
      borderRadius: borderRadius ?? this.borderRadius,
      timeTextStyle: timeTextStyle ?? this.timeTextStyle,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      autoHideControls: autoHideControls ?? this.autoHideControls,
      autoHideDuration: autoHideDuration ?? this.autoHideDuration,
      animationDuration: animationDuration ?? this.animationDuration,
      controlsBackgroundOpacity: controlsBackgroundOpacity ?? this.controlsBackgroundOpacity,
    );
  }
}
