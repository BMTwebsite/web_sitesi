import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../utils/size_helper.dart';

class ImageViewerDialog extends StatelessWidget {
  final String imageUrl;
  final String? title;

  const ImageViewerDialog({
    super.key,
    required this.imageUrl,
    this.title,
  });

  static void show(BuildContext context, String imageUrl, {String? title}) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => ImageViewerDialog(
        imageUrl: imageUrl,
        title: title,
      ),
    );
  }

  Widget _buildImage() {
    if (kIsWeb) {
      // Web için HTML img elementi kullan
      final imageId = 'image_viewer_${DateTime.now().millisecondsSinceEpoch}';
      
      final imgElement = html.ImageElement()
        ..src = imageUrl
        ..style.maxWidth = '90vw'
        ..style.maxHeight = '90vh'
        ..style.objectFit = 'contain'
        ..style.cursor = 'pointer'
        ..onError.listen((_) {
          print('❌ Image Viewer - HTML img yükleme hatası: $imageUrl');
        })
        ..onLoad.listen((_) {
          print('✅ Image Viewer - HTML img yüklendi: $imageUrl');
        });
      
      ui_web.platformViewRegistry.registerViewFactory(
        imageId,
        (int viewId) => imgElement,
      );
      
      return HtmlElementView(viewType: imageId);
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: const Color(0xFF2196F3),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Resim yüklenemedi',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: SizeHelper.isMobile(context) ? 16 : 40,
        vertical: SizeHelper.isMobile(context) ? 16 : 40,
      ),
      child: Stack(
        children: [
          // Image
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: _buildImage(),
            ),
          ),
          // Close button
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                shape: const CircleBorder(),
              ),
            ),
          ),
          // Title (if provided)
          if (title != null && title!.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

