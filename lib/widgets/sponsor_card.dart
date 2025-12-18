import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../services/firestore_service.dart';
import '../utils/size_helper.dart';
import 'image_viewer_dialog.dart';

class SponsorCard extends StatelessWidget {
  final SponsorData sponsor;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SponsorCard({
    super.key,
    required this.sponsor,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
  });

  Widget _buildMapWidget(String address) {
    final encodedAddress = Uri.encodeComponent(address);
    final mapUrl = 'https://www.google.com/maps?q=$encodedAddress&output=embed';
    
    final viewId = 'sponsor-map-${address.hashCode}';
    
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int id) {
        final iframe = html.IFrameElement()
          ..src = mapUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      },
    );
    
    return HtmlElementView(viewType: viewId);
  }

  Widget _buildCardContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2196F3).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeHelper.isMobile(context) ? 12 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              // Header: Logo ve Sponsor Bilgileri
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  if (sponsor.logoUrl.isNotEmpty) ...[
                    Container(
                      width: SizeHelper.isMobile(context) ? 50 : 60,
                      height: SizeHelper.isMobile(context) ? 50 : 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white.withOpacity(0.08),
                        border: Border.all(
                          color: const Color(0xFF2196F3).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          ImageViewerDialog.show(context, sponsor.logoUrl, title: sponsor.name);
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Padding(
                            padding: EdgeInsets.all(SizeHelper.isMobile(context) ? 6 : 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                sponsor.logoUrl,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        color: const Color(0xFF2196F3),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.business,
                                    color: const Color(0xFF2196F3),
                                    size: SizeHelper.isMobile(context) ? 24 : 28,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: SizeHelper.isMobile(context) ? 10 : 12),
                  ],
                  // Sponsor Adı ve Açıklama
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Sponsor Adı
                        Text(
                          sponsor.name,
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Açıklama (varsa)
                        if (sponsor.description != null && sponsor.description!.isNotEmpty) ...[
                          SizedBox(height: SizeHelper.isMobile(context) ? 4 : 6),
                          Text(
                            sponsor.description!,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: SizeHelper.clampFontSize(
                                MediaQuery.of(context).size.width,
                                11,
                                12,
                                14,
                              ),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeHelper.isMobile(context) ? 10 : 12),
              // Website linki varsa göster
              if (sponsor.websiteUrl != null && sponsor.websiteUrl!.isNotEmpty) ...[
                SizedBox(height: SizeHelper.isMobile(context) ? 5 : 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.link,
                      color: const Color(0xFF2196F3),
                      size: SizeHelper.isMobile(context) ? 12 : 14,
                    ),
                    SizedBox(width: SizeHelper.isMobile(context) ? 3 : 4),
                    Flexible(
                      child: Text(
                        'Web Sitesi',
                        style: TextStyle(
                          color: const Color(0xFF2196F3),
                          fontSize: SizeHelper.clampFontSize(
                            MediaQuery.of(context).size.width,
                            9,
                            11,
                            13,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
                // Adres varsa harita göster
                if (sponsor.address != null && sponsor.address!.isNotEmpty) ...[
                  SizedBox(height: SizeHelper.isMobile(context) ? 8 : 10),
                  Container(
                    height: SizeHelper.isMobile(context) ? 100 : 120,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF2196F3).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildMapWidget(sponsor.address!),
                    ),
                  ),
                  SizedBox(height: SizeHelper.isMobile(context) ? 4 : 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: const Color(0xFF2196F3),
                        size: SizeHelper.isMobile(context) ? 12 : 14,
                      ),
                      SizedBox(width: SizeHelper.isMobile(context) ? 3 : 4),
                      Flexible(
                        child: Text(
                          sponsor.address!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF2196F3),
                            fontSize: SizeHelper.clampFontSize(
                              MediaQuery.of(context).size.width,
                              9,
                              10,
                              12,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                // Admin butonları - her zaman en altta görünür olmalı
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = _buildCardContent(context);
    
    // Admin modunda InkWell kullanma, normal modda kullan
    if (isAdmin) {
      return cardContent;
    }
    
    return InkWell(
      onTap: sponsor.websiteUrl != null && sponsor.websiteUrl!.isNotEmpty
          ? () {
              html.window.open(sponsor.websiteUrl!, '_blank');
            }
          : null,
      borderRadius: BorderRadius.circular(16),
      child: cardContent,
    );
  }
}

