import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:ui_web' as ui_web show platformViewRegistry;
import '../services/firestore_service.dart';
import '../utils/size_helper.dart';
import 'image_viewer_dialog.dart';

class TeamMemberCard extends StatelessWidget {
  final TeamMemberData member;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TeamMemberCard({
    super.key,
    required this.member,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
  });

  Widget _buildPhoto(BuildContext context) {
    final photoUrl = member.photoUrl;
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth < 600 ? 80.0 : (screenWidth < 1024 ? 90.0 : 100.0);
    
    if (photoUrl != null && photoUrl.isNotEmpty) {
      // URL'i normalize et
      String normalizedUrl = photoUrl;
      try {
        final uri = Uri.parse(photoUrl);
        normalizedUrl = uri.toString();
      } catch (e) {
        print('⚠️ Team Member Card - URL parse hatası: $e');
      }
      
      // Flutter web'de CORS sorununu çözmek için HTML img elementi kullan
      if (kIsWeb) {
        final imageId = 'team_img_${member.id ?? DateTime.now().millisecondsSinceEpoch}';
        
        final imgElement = html.ImageElement()
          ..src = normalizedUrl
          ..style.width = '${imageSize}px'
          ..style.height = '${imageSize}px'
          ..style.objectFit = 'cover'
          ..style.borderRadius = '12px'
          ..style.cursor = 'pointer'
          ..style.transition = 'transform 0.2s ease, opacity 0.2s ease'
          ..onError.listen((_) {
            print('❌ Team Member Card - HTML img yükleme hatası: $normalizedUrl');
          })
          ..onLoad.listen((_) {
            print('✅ Team Member Card - HTML img yüklendi: $normalizedUrl');
          });
        
        imgElement.onMouseEnter.listen((_) {
          imgElement.style.transform = 'scale(1.05)';
          imgElement.style.opacity = '0.9';
        });
        imgElement.onMouseLeave.listen((_) {
          imgElement.style.transform = 'scale(1.0)';
          imgElement.style.opacity = '1.0';
        });
        imgElement.onClick.listen((_) {
          ImageViewerDialog.show(context, normalizedUrl, title: member.name);
        });
        
        ui_web.platformViewRegistry.registerViewFactory(
          imageId,
          (int viewId) => imgElement,
        );
        
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              ImageViewerDialog.show(context, normalizedUrl, title: member.name);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: imageSize,
                height: imageSize,
                child: HtmlElementView(viewType: imageId),
              ),
            ),
          ),
        );
      } else {
        return GestureDetector(
          onTap: () {
            ImageViewerDialog.show(context, normalizedUrl, title: member.name);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.transparent,
                  width: 2,
                ),
              ),
              child: Image.network(
                normalizedUrl,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person,
                      color: const Color(0xFF2196F3),
                      size: imageSize * 0.5,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }
    } else {
      final imageSize = MediaQuery.of(context).size.width < 600 ? 80.0 : (MediaQuery.of(context).size.width < 1024 ? 90.0 : 100.0);
      return Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.person,
          color: const Color(0xFF2196F3),
          size: imageSize * 0.5,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2196F3).withOpacity(0.3),
          width: 2,
        ),
      ),
      padding: EdgeInsets.only(
        top: SizeHelper.isMobile(context) ? 16 : 20,
        left: 0,
        right: 0,
        bottom: (isAdmin && (onEdit != null || onDelete != null))
            ? SizeHelper.isMobile(context) ? 16 : 20
            : SizeHelper.isMobile(context) ? 16 : 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Fotoğraf
          _buildPhoto(context),
          SizedBox(height: SizeHelper.isMobile(context) ? 10 : 12),
          // İsim
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeHelper.isMobile(context) ? 10 : 12),
            child: Text(
              member.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeHelper.clampFontSize(
                  MediaQuery.of(context).size.width,
                  14,
                  16,
                  18,
                ),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: SizeHelper.isMobile(context) ? 5 : 6),
          // Ünvan
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeHelper.isMobile(context) ? 10 : 12),
            child: Text(
              member.title,
              style: TextStyle(
                color: const Color(0xFF2196F3),
                fontSize: SizeHelper.clampFontSize(
                  MediaQuery.of(context).size.width,
                  11,
                  13,
                  15,
                ),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: SizeHelper.isMobile(context) ? 5 : 6),
          // Bölüm
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeHelper.isMobile(context) ? 10 : 12),
            child: Text(
              member.department,
              style: TextStyle(
                color: Colors.white70,
                fontSize: SizeHelper.clampFontSize(
                  MediaQuery.of(context).size.width,
                  10,
                  12,
                  14,
                ),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Sınıf (varsa)
          if (member.className != null && member.className!.isNotEmpty) ...[
            SizedBox(height: SizeHelper.isMobile(context) ? 3 : 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeHelper.isMobile(context) ? 10 : 12),
              child: Text(
                member.className!,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: SizeHelper.clampFontSize(
                    MediaQuery.of(context).size.width,
                    9,
                    11,
                    13,
                  ),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          // Admin butonları (varsa)
          if (isAdmin && (onEdit != null || onDelete != null)) ...[
            SizedBox(height: SizeHelper.isMobile(context) ? 16 : 20),
            Padding(
              padding: EdgeInsets.all(SizeHelper.isMobile(context) ? 8 : 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onEdit != null) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: SizeHelper.isMobile(context) ? 6 : 8,
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
                            vertical: SizeHelper.isMobile(context) ? 6 : 8,
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
            ),
          ],
        ],
      ),
    );
  }
}

