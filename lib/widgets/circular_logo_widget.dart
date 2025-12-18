import 'package:flutter/material.dart';
import '../utils/size_helper.dart';

/// Yuvarlak logo widget'ı
/// 
/// logoUrl varsa network'ten, yoksa web/icon.png asset'ini yuvarlak beyaz arka plan ile gösterir.
/// Responsive tasarıma sahiptir ve taşma yapmaz.
class CircularLogoWidget extends StatelessWidget {
  /// Logo boyutu (opsiyonel, null ise responsive olarak hesaplanır)
  final double? size;
  
  /// Padding değeri (opsiyonel, null ise responsive olarak hesaplanır)
  final double? padding;
  
  /// Network'ten yüklenecek logo URL'i (opsiyonel, null ise varsayılan asset kullanılır)
  final String? logoUrl;

  const CircularLogoWidget({
    super.key,
    this.size,
    this.padding,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive boyut hesaplama
    final logoSize = size ?? (SizeHelper.isMobile(context) 
        ? 60.0 
        : (SizeHelper.isTablet(context) ? 80.0 : 100.0));
    
    final logoPadding = padding ?? (SizeHelper.isMobile(context) 
        ? 8.0 
        : (SizeHelper.isTablet(context) ? 10.0 : 12.0));

    return ClipOval(
      child: Container(
        width: logoSize,
        height: logoSize,
        color: Colors.white,
        padding: EdgeInsets.all(logoPadding),
        child: _buildLogoImage(),
      ),
    );
  }
  
  Widget _buildLogoImage() {
    // Eğer logoUrl varsa ve boş değilse network image kullan
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return Image.network(
        logoUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Network image yüklenemezse varsayılan asset'i göster
          return Image.asset(
            'web/icon.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image,
                color: Colors.grey,
              );
            },
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }
    
    // Varsayılan olarak asset image kullan
    return Image.asset(
      'web/icon.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.image,
          color: Colors.grey,
        );
      },
    );
  }
}

