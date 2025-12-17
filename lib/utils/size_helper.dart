import 'package:flutter/material.dart';
import 'size_exception.dart';

/// Boyutlarla ilgili güvenli işlemler için helper class
class SizeHelper {
  /// Minimum ve maksimum değerler arasında güvenli bir boyut döndürür
  /// Eğer context verilirse, scale faktörü uygulanır
  static double safeSize({
    required double value,
    double min = 0.0,
    double? max,
    String? context,
    BuildContext? buildContext,
  }) {
    // Eğer buildContext verilmişse scale faktörü uygula
    if (buildContext != null && context != null) {
      try {
        final scaleFactor = getScaleFactor(buildContext);
        value = value * scaleFactor;
      } catch (e) {
        debugPrint('⚠️ SafeSize scale error: $e');
      }
    }
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
  /// Referans ekran genişliği: 1920px
  static EdgeInsets safePadding({
    required BuildContext context,
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    try {
      final scaleFactor = getScaleFactor(context);

      double hPadding;
      double vPadding;

      if (all != null) {
        hPadding = all * scaleFactor;
        vPadding = all * scaleFactor;
      } else {
        hPadding = (horizontal ?? 60.0) * scaleFactor;
        vPadding = (vertical ?? 60.0) * scaleFactor;
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
  /// Referans ekran genişliği: 1920px
  /// Tüm ekranlar bu referansa göre scale edilir
  static double safeFontSize(BuildContext context, {required double preferredSize}) {
    try {
      final screenWidth = safeWidth(context);
      
      // Referans ekran genişliği (1920px)
      const double referenceWidth = 1920.0;
      
      // Scale faktörü hesapla (referans ekrana göre)
      double scaleFactor = screenWidth / referenceWidth;
      
      // Minimum ve maksimum scale limitleri
      if (scaleFactor < 0.4) scaleFactor = 0.4; // Çok küçük ekranlar için minimum
      if (scaleFactor > 1.2) scaleFactor = 1.2; // Çok büyük ekranlar için maksimum
      
      // Font boyutunu scale et
      double fontSize = preferredSize * scaleFactor;

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
  
  /// Genel scale faktörü (referans: 1920px genişlik)
  static double getScaleFactor(BuildContext context) {
    try {
      final screenWidth = safeWidth(context);
      const double referenceWidth = 1920.0;
      double scaleFactor = screenWidth / referenceWidth;
      
      // Minimum ve maksimum scale limitleri
      if (scaleFactor < 0.4) scaleFactor = 0.4;
      if (scaleFactor > 1.2) scaleFactor = 1.2;
      
      return scaleFactor;
    } catch (e) {
      debugPrint('⚠️ GetScaleFactor Error: $e');
      return 1.0;
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
  /// mobile < 600: 1 sütun, tablet 600-1024: 2 sütun, desktop > 1024: 3-4 sütun
  static int safeCrossAxisCount(BuildContext context, {int? preferredCount}) {
    try {
      final screenWidth = safeWidth(context);
      final count = preferredCount ?? 4;

      if (screenWidth < 600) {
        return 1; // Mobil: 1 sütun
      } else if (screenWidth < 1024) {
        return 2; // Tablet: 2 sütun
      } else {
        // Desktop: 3-4 sütun (preferredCount'a göre)
        return safeSize(
          value: count.toDouble(),
          min: 3,
          max: 4,
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

  /// Mobil cihaz kontrolü (< 600px)
  static bool isMobile(BuildContext context) {
    try {
      return safeWidth(context) < 600;
    } catch (e) {
      debugPrint('⚠️ IsMobile Error: $e');
      return false;
    }
  }

  /// Tablet cihaz kontrolü (600-1024px)
  static bool isTablet(BuildContext context) {
    try {
      final width = safeWidth(context);
      return width >= 600 && width < 1024;
    } catch (e) {
      debugPrint('⚠️ IsTablet Error: $e');
      return false;
    }
  }

  /// Desktop cihaz kontrolü (> 1024px)
  static bool isDesktop(BuildContext context) {
    try {
      return safeWidth(context) >= 1024;
    } catch (e) {
      debugPrint('⚠️ IsDesktop Error: $e');
      return true;
    }
  }

  /// Clamp fonksiyonu ile responsive font boyutu hesaplar
  /// min: mobil için minimum boyut (< 600)
  /// preferred: tablet için tercih edilen boyut (600-1024)
  /// max: desktop için maksimum boyut (> 1024)
  static double clampFontSize(double screenWidth, double min, double preferred, double max) {
    if (screenWidth < 600) {
      // Mobil (< 600)
      return min;
    } else if (screenWidth < 1024) {
      // Tablet (600-1024) - min ve preferred arasında interpolasyon
      final ratio = (screenWidth - 600) / (1024 - 600);
      return min + (preferred - min) * ratio;
    } else {
      // Desktop (> 1024) - preferred ve max arasında interpolasyon
      if (screenWidth < 1440) {
        final ratio = (screenWidth - 1024) / (1440 - 1024);
        return preferred + (max - preferred) * ratio;
      } else {
        // Büyük desktop
        return max;
      }
    }
  }
}

