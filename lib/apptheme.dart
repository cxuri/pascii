import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppTheme {
  ColorScheme get colorScheme;
  String get name;
  Color get primaryColor;
  Color get secondaryColor;
  Color get backgroundColor;
  Color get cardColor;
  Color get textColor;
  Color get accentColor;
  Color get searchBarColor;
  Color get iconColor;
  Color get bannerColor;
  ThemeData get themeData;
}

class DefaultDarkTheme implements AppTheme {
  @override
  String get name => "Midnight";

  @override
  Color get primaryColor => const Color(0xFF121212);

  @override
  Color get secondaryColor => const Color(0xFF1E1E1E);

  @override
  Color get backgroundColor => const Color(0xFF0A0A0A);

  @override
  Color get cardColor => const Color(0xFF1E1E1E);

  @override
  Color get textColor => const Color(0xFFE0E0E0);

  @override
  Color get accentColor => const Color(0xFFBB86FC); // Purple accent

  @override
  Color get searchBarColor => const Color(0xFF1E1E1E);

  @override
  Color get iconColor => const Color(0xFFBB86FC);

  @override
  Color get bannerColor => const Color(0xFF3700B3); // Darker purple

  @override
  ColorScheme get colorScheme => const ColorScheme.dark().copyWith(
    primary: accentColor,
    onPrimary: Colors.black,
    secondary: const Color(0xFF03DAC6), // Teal secondary
    onSecondary: Colors.black,
    error: const Color(0xFFCF6679),
    onError: Colors.black,
    background: backgroundColor,
    onBackground: textColor,
    surface: cardColor,
    onSurface: textColor,
  );

  @override
  ThemeData get themeData => ThemeData(
    colorScheme: colorScheme,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 14),
      bodySmall: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: iconColor),
    ),
    iconTheme: IconThemeData(color: iconColor),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accentColor),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[800],
      thickness: 1,
      space: 1,
    ),
  );
}

class LightTheme implements AppTheme {
  @override
  String get name => "Daylight";

  @override
  Color get primaryColor => const Color(0xFFFFFFFF);

  @override
  Color get secondaryColor => const Color(0xFFF5F5F5);

  @override
  Color get backgroundColor => const Color(0xFFFAFAFA);

  @override
  Color get cardColor => const Color(0xFFFFFFFF);

  @override
  Color get textColor => const Color(0xFF333333);

  @override
  Color get accentColor => const Color(0xFF6200EE); // Deep purple

  @override
  Color get searchBarColor => const Color(0xFFFFFFFF);

  @override
  Color get iconColor => const Color(0xFF6200EE);

  @override
  Color get bannerColor => const Color(0xFF3700B3); // Darker purple

  @override
  ColorScheme get colorScheme => const ColorScheme.light().copyWith(
    primary: accentColor,
    onPrimary: Colors.white,
    secondary: const Color(0xFF03DAC6), // Teal
    onSecondary: Colors.black,
    error: const Color(0xFFB00020),
    onError: Colors.white,
    background: backgroundColor,
    onBackground: textColor,
    surface: cardColor,
    onSurface: textColor,
  );

  @override
  ThemeData get themeData => ThemeData(
    colorScheme: colorScheme,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 14),
      bodySmall: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: iconColor),
    ),
    iconTheme: IconThemeData(color: iconColor),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accentColor),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1,
      space: 1,
    ),
  );
}

class OceanTheme implements AppTheme {
  @override
  String get name => "Ocean";

  @override
  Color get primaryColor => const Color(0xFF0A1128); // Navy blue

  @override
  Color get secondaryColor => const Color(0xFF001F54);

  @override
  Color get backgroundColor => const Color(0xFF000814);

  @override
  Color get cardColor => const Color(0xFF001F54);

  @override
  Color get textColor => const Color(0xFFF8F9FA);

  @override
  Color get accentColor => const Color(0xFF00B4D8); // Sky blue

  @override
  Color get searchBarColor => const Color(0xFF001F54);

  @override
  Color get iconColor => const Color(0xFF00B4D8);

  @override
  Color get bannerColor => const Color(0xFF0077B6); // Darker blue

  @override
  ColorScheme get colorScheme => const ColorScheme.dark().copyWith(
    primary: accentColor,
    onPrimary: Colors.black,
    secondary: const Color(0xFF90E0EF), // Lighter blue
    onSecondary: Colors.black,
    error: const Color(0xFFFF6B6B),
    onError: Colors.white,
    background: backgroundColor,
    onBackground: textColor,
    surface: cardColor,
    onSurface: textColor,
  );

  @override
  ThemeData get themeData => ThemeData(
    colorScheme: colorScheme,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 14),
      bodySmall: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: iconColor),
    ),
    iconTheme: IconThemeData(color: iconColor),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accentColor),
    ),
    dividerTheme: DividerThemeData(
      color: const Color(0xFF1A3A8F),
      thickness: 1,
      space: 1,
    ),
  );
}

class EmeraldTheme implements AppTheme {
  @override
  String get name => "Emerald";

  @override
  Color get primaryColor => const Color(0xFF1A2E35); // Dark teal

  @override
  Color get secondaryColor => const Color(0xFF2D4A53);

  @override
  Color get backgroundColor => const Color(0xFF0F1A1C);

  @override
  Color get cardColor => const Color(0xFF2D4A53);

  @override
  Color get textColor => const Color(0xFFE0F2F1);

  @override
  Color get accentColor => const Color(0xFF4DB6AC); // Teal

  @override
  Color get searchBarColor => const Color(0xFF2D4A53);

  @override
  Color get iconColor => const Color(0xFF4DB6AC);

  @override
  Color get bannerColor => const Color(0xFF00897B); // Darker teal

  @override
  ColorScheme get colorScheme => const ColorScheme.dark().copyWith(
    primary: accentColor,
    onPrimary: Colors.black,
    secondary: const Color(0xFF80CBC4), // Light teal
    onSecondary: Colors.black,
    error: const Color(0xFFE57373),
    onError: Colors.white,
    background: backgroundColor,
    onBackground: textColor,
    surface: cardColor,
    onSurface: textColor,
  );

  @override
  ThemeData get themeData => ThemeData(
    colorScheme: colorScheme,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 14),
      bodySmall: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: iconColor),
    ),
    iconTheme: IconThemeData(color: iconColor),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accentColor),
    ),
    dividerTheme: DividerThemeData(
      color: const Color(0xFF3E5D65),
      thickness: 1,
      space: 1,
    ),
  );
}

class ThemeManager {
  static final List<AppTheme> _themes = [
    DefaultDarkTheme(),
    LightTheme(),
    OceanTheme(),
    EmeraldTheme(),
  ];

  // Add this new factory method
  static AppTheme _createThemeInstance(int index) {
    switch (index) {
      case 0:
        return DefaultDarkTheme();
      case 1:
        return LightTheme();
      case 2:
        return OceanTheme();
      case 3:
        return EmeraldTheme();
      default:
        return DefaultDarkTheme();
    }
  }

  static List<AppTheme> get themes => _themes;

  static Future<AppTheme> getCurrentTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt('themeIndex') ?? 0;
      return _themes[themeIndex.clamp(0, _themes.length - 1)];
    } catch (e) {
      return _themes[0]; // Return default theme if any error occurs
    }
  }

  static Future<void> setTheme(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeIndex', index.clamp(0, _themes.length - 1));
  }

  static Future<void> cycleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final currentIndex = prefs.getInt('themeIndex') ?? 0;
    final newIndex = (currentIndex + 1) % _themes.length;
    await setTheme(newIndex);
  }

  static Future<int> getCurrentThemeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('themeIndex') ?? 0;
  }
}

class ThemeNotifier with ChangeNotifier {
  late AppTheme currentTheme;

  ThemeNotifier() {
    currentTheme = DefaultDarkTheme(); // Default theme
    loadTheme();
  }

  Future<void> loadTheme() async {
    final loadedTheme = await ThemeManager.getCurrentTheme();
    currentTheme = _createFreshThemeInstance(loadedTheme);
    notifyListeners();
  }

  Future<void> setTheme(int index) async {
    await ThemeManager.setTheme(index);
    currentTheme = _createFreshThemeInstance(ThemeManager.themes[index]);
    notifyListeners();
  }

  AppTheme _createFreshThemeInstance(AppTheme theme) {
    // Create new instances to prevent caching
    switch (theme.runtimeType) {
      case DefaultDarkTheme:
        return DefaultDarkTheme();
      case LightTheme:
        return LightTheme();
      case OceanTheme:
        return OceanTheme();
      case EmeraldTheme:
        return EmeraldTheme();
      default:
        return DefaultDarkTheme();
    }
  }
}
