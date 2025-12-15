import 'package:flutter/material.dart';
import 'size_exception.dart';

/// Boyutlarla ilgili güvenli işlemler için helper class
class SizeHelper {
  /// Minimum ve maksimum değerler arasında güvenli bir boyut döndürür
  static double safeSize({
    required double value,
    double min = 0.0,
    double? max,
    String? context,
  }) {
    try {
      if (value < min) {
        throw InvalidSizeException(
          message: 'Size value is below minimum',
          context: context,
          attemptedValue: value,
          minValue: min,
          maxValue: max,
        );
      }

      if (max != null && value > max) {
        throw InvalidSizeException(
          message: 'Size value exceeds maximum',
          context: context,
          attemptedValue: value,
          minValue: min,
          maxValue: max,
        );
      }

      // Negatif değerleri 0'a çevir
      if (value < 0) {
        return 0.0;
      }

      // NaN veya Infinity kontrolü
      if (value.isNaN || value.isInfinite) {
        throw InvalidSizeException(
          message: 'Size value is NaN or Infinite',
          context: context,
          attemptedValue: value,
          minValue: min,
          maxValue: max,
        );
      }

      return value;
    } catch (e) {
      // Exception durumunda güvenli bir değer döndür
      if (e is SizeException) {
        debugPrint('⚠️ SizeHelper Error: ${e.toString()}');
        // Güvenli fallback değer döndür
        if (max != null && max > 0) {
          return max;
        }
        return min > 0 ? min : 100.0; // Varsayılan güvenli değer
      }
      rethrow;
    }
  }

  /// Ekran genişliğini güvenli bir şekilde döndürür
  static double safeWidth(BuildContext context, {double? maxWidth}) {
    try {
      final size = MediaQuery.of(context).size.width;
      return safeSize(
        value: size,
        max: maxWidth,
        context: 'Screen width',
      );
    } catch (e) {
      debugPrint('⚠️ SafeWidth Error: $e');
      return maxWidth ?? 1920.0; // Varsayılan maksimum genişlik
    }
  }

  /// Ekran yüksekliğini güvenli bir şekilde döndürür
  static double safeHeight(BuildContext context, {double? maxHeight}) {
    try {
      final size = MediaQuery.of(context).size.height;
      return safeSize(
        value: size,
        max: maxHeight,
        context: 'Screen height',
      );
    } catch (e) {
      debugPrint('⚠️ SafeHeight Error: $e');
      return maxHeight ?? 1080.0; // Varsayılan maksimum yükseklik
    }
  }

  /// Padding değerini güvenli bir şekilde döndürür
  static EdgeInsets safePadding({
    required BuildContext context,
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    try {
      final screenWidth = safeWidth(context);
      final screenHeight = safeHeight(context);

      // Mobil cihazlar için daha küçük padding
      final isMobile = screenWidth < 768;
      final isTablet = screenWidth >= 768 && screenWidth < 1024;

      double hPadding;
      double vPadding;

      if (all != null) {
        hPadding = safeSize(
          value: isMobile ? all * 0.5 : (isTablet ? all * 0.75 : all),
          max: screenWidth * 0.1,
          context: 'Padding horizontal',
        );
        vPadding = safeSize(
          value: isMobile ? all * 0.5 : (isTablet ? all * 0.75 : all),
          max: screenHeight * 0.1,
          context: 'Padding vertical',
        );
      } else {
        hPadding = safeSize(
          value: horizontal ?? (isMobile ? 20.0 : 60.0),
          max: screenWidth * 0.1,
          context: 'Padding horizontal',
        );
        vPadding = safeSize(
          value: vertical ?? (isMobile ? 40.0 : 60.0),
          max: screenHeight * 0.1,
          context: 'Padding vertical',
        );
      }

      return EdgeInsets.symmetric(
        horizontal: hPadding,
        vertical: vPadding,
      );
    } catch (e) {
      debugPrint('⚠️ SafePadding Error: $e');
      return const EdgeInsets.all(20.0); // Güvenli fallback padding
    }
  }

  /// Container genişliğini güvenli bir şekilde döndürür
  static double safeContainerWidth(BuildContext context, {double? preferredWidth}) {
    try {
      final screenWidth = safeWidth(context);
      final width = preferredWidth ?? screenWidth;

      return safeSize(
        value: width,
        min: 100.0,
        max: screenWidth * 0.95, // Ekran genişliğinin %95'ini geçmesin
        context: 'Container width',
      );
    } catch (e) {
      debugPrint('⚠️ SafeContainerWidth Error: $e');
      return 100.0;
    }
  }

  /// Container yüksekliğini güvenli bir şekilde döndürür
  static double safeContainerHeight(BuildContext context, {double? preferredHeight}) {
    try {
      final screenHeight = safeHeight(context);
      final height = preferredHeight ?? screenHeight;

      return safeSize(
        value: height,
        min: 50.0,
        max: screenHeight * 0.9, // Ekran yüksekliğinin %90'ını geçmesin
        context: 'Container height',
      );
    } catch (e) {
      debugPrint('⚠️ SafeContainerHeight Error: $e');
      return 200.0;
    }
  }

  /// Font boyutunu güvenli bir şekilde döndürür
  static double safeFontSize(BuildContext context, {required double preferredSize}) {
    try {
      final screenWidth = safeWidth(context);
      
      // Responsive font boyutu
      double fontSize = preferredSize;
      if (screenWidth < 768) {
        fontSize = preferredSize * 0.7; // Mobil için küçült
      } else if (screenWidth < 1024) {
        fontSize = preferredSize * 0.85; // Tablet için biraz küçült
      }

      return safeSize(
        value: fontSize,
        min: 10.0,
        max: 100.0,
        context: 'Font size',
      );
    } catch (e) {
      debugPrint('⚠️ SafeFontSize Error: $e');
      return 16.0; // Varsayılan font boyutu
    }
  }

  /// BoxConstraints'i güvenli bir şekilde oluşturur
  static BoxConstraints safeBoxConstraints({
    required BuildContext context,
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    try {
      final screenWidth = safeWidth(context);
      final screenHeight = safeHeight(context);

      return BoxConstraints(
        minWidth: minWidth != null
            ? safeSize(value: minWidth, max: screenWidth * 0.9, context: 'Min width')
            : 0.0,
        maxWidth: maxWidth != null
            ? safeSize(value: maxWidth, max: screenWidth * 0.95, context: 'Max width')
            : screenWidth * 0.95,
        minHeight: minHeight != null
            ? safeSize(value: minHeight, max: screenHeight * 0.9, context: 'Min height')
            : 0.0,
        maxHeight: maxHeight != null
            ? safeSize(value: maxHeight, max: screenHeight * 0.9, context: 'Max height')
            : screenHeight * 0.9,
      );
    } catch (e) {
      debugPrint('⚠️ SafeBoxConstraints Error: $e');
      return const BoxConstraints(
        minWidth: 0,
        maxWidth: 1920,
        minHeight: 0,
        maxHeight: 1080,
      );
    }
  }

  /// Responsive grid crossAxisCount döndürür
  static int safeCrossAxisCount(BuildContext context, {int? preferredCount}) {
    try {
      final screenWidth = safeWidth(context);
      final count = preferredCount ?? 4;

      if (screenWidth < 600) {
        return 1; // Mobil: 1 sütun
      } else if (screenWidth < 900) {
        return 2; // Küçük tablet: 2 sütun
      } else if (screenWidth < 1200) {
        return 3; // Tablet: 3 sütun
      } else {
        return safeSize(
          value: count.toDouble(),
          min: 1,
          max: 6,
          context: 'Cross axis count',
        ).toInt();
      }
    } catch (e) {
      debugPrint('⚠️ SafeCrossAxisCount Error: $e');
      return 2; // Güvenli fallback
    }
  }

  /// double.infinity yerine güvenli bir değer döndürür
  static double safeInfinity(BuildContext context, {bool isWidth = true}) {
    try {
      if (isWidth) {
        return safeWidth(context);
      } else {
        return safeHeight(context);
      }
    } catch (e) {
      debugPrint('⚠️ SafeInfinity Error: $e');
      return isWidth ? 1920.0 : 1080.0;
    }
  }

  /// Mobil cihaz kontrolü
  static bool isMobile(BuildContext context) {
    try {
      return safeWidth(context) < 768;
    } catch (e) {
      debugPrint('⚠️ IsMobile Error: $e');
      return false;
    }
  }

  /// Tablet cihaz kontrolü
  static bool isTablet(BuildContext context) {
    try {
      final width = safeWidth(context);
      return width >= 768 && width < 1024;
    } catch (e) {
      debugPrint('⚠️ IsTablet Error: $e');
      return false;
    }
  }

  /// Desktop cihaz kontrolü
  static bool isDesktop(BuildContext context) {
    try {
      return safeWidth(context) >= 1024;
    } catch (e) {
      debugPrint('⚠️ IsDesktop Error: $e');
      return true;
    }
  }
}

