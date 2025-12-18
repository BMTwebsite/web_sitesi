import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:ui_web' as ui_web show platformViewRegistry;
import '../services/firestore_service.dart';
import '../utils/size_helper.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementData announcement;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
  });

  Widget _buildPosterImage(String imageUrl, Color fallbackColor, String? id) {
    if (kIsWeb) {
      // Web için HTML img elementi kullan (CORS sorununu çözer)
      final imageId = 'announcement_img_${id ?? DateTime.now().millisecondsSinceEpoch}';
      
      // HTML img elementi oluştur
      final imgElement = html.ImageElement()
        ..src = imageUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain'
        ..onError.listen((_) {
          print('❌ Announcement Card - HTML img yükleme hatası: $imageUrl');
        })
        ..onLoad.listen((_) {
          print('✅ Announcement Card - HTML img yüklendi: $imageUrl');
        });
      
      // Platform view registry'ye kaydet
      ui_web.platformViewRegistry.registerViewFactory(
        imageId,
        (int viewId) => imgElement,
      );
      
      return HtmlElementView(viewType: imageId);
    } else {
      // Mobile için normal Image.network kullan
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: fallbackColor.withOpacity(0.2),
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.white54,
                size: 32,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A2332),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF2196F3).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Görsel - Sabit yükseklik
              if (announcement.posterUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    height: constraints.maxHeight * 0.6, // Kart yüksekliğinin %60'ı
                    width: double.infinity,
                    color: const Color(0xFF0A1929),
                    child: _buildPosterImage(
                      announcement.posterUrl,
                      announcement.color,
                      announcement.id,
                    ),
                  ),
                ),
              ],
              // İçerik alanı - Kalan alanı kullan
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(SizeHelper.isMobile(context) ? 16 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Duyuru adı
                        Text(
                          announcement.eventName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeHelper.clampFontSize(
                              MediaQuery.of(context).size.width,
                              16,
                              18,
                              20,
                            ),
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Açıklama
                        if (announcement.description != null && announcement.description!.isNotEmpty) ...[
                          SizedBox(height: SizeHelper.isMobile(context) ? 12 : 16),
                          Text(
                            announcement.description!,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: SizeHelper.clampFontSize(
                                MediaQuery.of(context).size.width,
                                13,
                                15,
                                17,
                              ),
                              height: 1.5,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        // Link
                        if (announcement.link != null && announcement.link!.isNotEmpty) ...[
                          SizedBox(height: SizeHelper.isMobile(context) ? 12 : 16),
                          InkWell(
                            onTap: () {
                              // Eğer internal link ise (etkinlikler sayfasına yönlendirme)
                              if (announcement.link!.startsWith('internal:/')) {
                                final route = announcement.link!.substring('internal:'.length);
                                Navigator.pushNamed(context, route);
                              } else {
                                // Dış link ise yeni sekmede aç
                                html.window.open(announcement.link!, '_blank');
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  announcement.link!.startsWith('internal:/') 
                                      ? Icons.event 
                                      : Icons.link,
                                  color: const Color(0xFF2196F3),
                                  size: SizeHelper.isMobile(context) ? 16 : 18,
                                ),
                                SizedBox(width: SizeHelper.isMobile(context) ? 6 : 8),
                                Expanded(
                                  child: Text(
                                    announcement.link!.startsWith('internal:/')
                                        ? 'Etkinlikler Sayfasına Git'
                                        : 'Linke Git',
                                    style: TextStyle(
                                      color: const Color(0xFF2196F3),
                                      fontSize: SizeHelper.clampFontSize(
                                        MediaQuery.of(context).size.width,
                                        13,
                                        15,
                                        17,
                                      ),
                                      decoration: TextDecoration.underline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        // Admin butonları
                        if (isAdmin && (onEdit != null || onDelete != null)) ...[
                          SizedBox(height: SizeHelper.isMobile(context) ? 12 : 16),
                          Row(
                            children: [
                              if (onEdit != null) ...[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: onEdit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2196F3),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: SizeHelper.isMobile(context) ? 8 : 10,
                                      ),
                                    ),
                                    child: Text(
                                      'Düzenle',
                                      style: TextStyle(
                                        fontSize: SizeHelper.clampFontSize(
                                          MediaQuery.of(context).size.width,
                                          11,
                                          12,
                                          13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              if (onEdit != null && onDelete != null)
                                SizedBox(width: SizeHelper.isMobile(context) ? 8 : 12),
                              if (onDelete != null) ...[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: onDelete,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: SizeHelper.isMobile(context) ? 8 : 10,
                                      ),
                                    ),
                                    child: Text(
                                      'Sil',
                                      style: TextStyle(
                                        fontSize: SizeHelper.clampFontSize(
                                          MediaQuery.of(context).size.width,
                                          11,
                                          12,
                                          13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

