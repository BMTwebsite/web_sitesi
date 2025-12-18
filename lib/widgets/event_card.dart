import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'dart:html' as html;
import 'dart:ui_web' as ui_web show platformViewRegistry;
import '../services/firestore_service.dart';
import '../utils/size_helper.dart';
import 'image_viewer_dialog.dart';

class EventCard extends StatefulWidget {
  final EventData event;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPosterImage(String imageUrl, double screenWidth, double imageSize, Color fallbackColor, BuildContext context) {
    if (kIsWeb) {
      // Web için HTML img elementi kullan (CORS sorunlarını daha iyi yönetir)
      final imageId = 'event_img_${widget.event.id ?? DateTime.now().millisecondsSinceEpoch}_${imageUrl.hashCode}';
      
      // HTML img elementi oluştur
      final imgElement = html.ImageElement()
        ..src = imageUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain'
        ..style.cursor = 'pointer'
        ..crossOrigin = 'anonymous' // CORS için
        ..onError.listen((_) {
          if (kDebugMode) {
            print('❌ Event Card - HTML img yükleme hatası: $imageUrl');
            print('❌ Bu genellikle CORS veya Firebase Storage ayarları ile ilgilidir.');
          }
        })
        ..onLoad.listen((_) {
          if (kDebugMode) {
            print('✅ Event Card - HTML img yüklendi: $imageUrl');
          }
        });
      
      // Platform view registry'ye kaydet
      try {
        ui_web.platformViewRegistry.registerViewFactory(
          imageId,
          (int viewId) => imgElement,
        );
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Platform view registry hatası: $e');
        }
      }
      
      return GestureDetector(
        onTap: () {
          ImageViewerDialog.show(context, imageUrl, title: widget.event.title);
        },
        child: HtmlElementView(viewType: imageId),
      );
    } else {
      // Mobile için normal Image.network kullan
      return GestureDetector(
        onTap: () {
          ImageViewerDialog.show(context, imageUrl, title: widget.event.title);
        },
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: const Color(0xFF1A2332),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: fallbackColor,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: fallbackColor.withOpacity(0.2),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      color: Colors.white54,
                      size: SizeHelper.clampFontSize(screenWidth, 32, 40, 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tekrar Dene',
                      style: TextStyle(
                        color: fallbackColor,
                        fontSize: SizeHelper.clampFontSize(screenWidth, 12, 14, 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildImageCarousel(double screenWidth, double posterHeight, Color fallbackColor) {
    if (widget.event.images.isEmpty) {
      return Container(
        height: posterHeight,
        width: double.infinity,
        color: fallbackColor.withOpacity(0.2),
        child: Center(
          child: Icon(
            Icons.event,
            color: Colors.white54,
            size: SizeHelper.clampFontSize(screenWidth, 32, 40, 48),
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Image carousel
        SizedBox(
          height: posterHeight,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: widget.event.images.length,
            itemBuilder: (context, index) {
              return _buildPosterImage(
                widget.event.images[index],
                screenWidth,
                posterHeight,
                fallbackColor,
                context,
              );
            },
          ),
        ),
        // Navigation arrows
        if (widget.event.images.length > 1) ...[
          // Left arrow
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_currentImageIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _pageController.jumpToPage(widget.event.images.length - 1);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: SizeHelper.clampFontSize(screenWidth, 20, 24, 28),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Right arrow
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_currentImageIndex < widget.event.images.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _pageController.jumpToPage(0);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: SizeHelper.clampFontSize(screenWidth, 20, 24, 28),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Pagination dots
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.event.images.length,
                (index) => GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.event.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poster image carousel
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            child: Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                double posterHeight;
                if (screenWidth < 600) {
                  posterHeight = 140; // Mobil
                } else if (screenWidth < 1024) {
                  posterHeight = 160; // Tablet
                } else {
                  posterHeight = 180; // Desktop
                }

                return Container(
                  height: posterHeight,
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: posterHeight,
                    minHeight: 100,
                  ),
                  color: const Color(0xFF1A2332),
                  child: _buildImageCarousel(screenWidth, posterHeight, widget.event.color),
                );
              },
            ),
          ),
          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Type badge
                  Padding(
                    padding: EdgeInsets.all(SizeHelper.isMobile(context) ? 12 : 16),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeHelper.isMobile(context) ? 10 : 12,
                        vertical: SizeHelper.isMobile(context) ? 5 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.event.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: widget.event.color,
                            size: SizeHelper.isMobile(context) ? 14 : 16,
                          ),
                          SizedBox(width: SizeHelper.isMobile(context) ? 5 : 6),
                          Text(
                            widget.event.type,
                            style: TextStyle(
                              color: widget.event.color,
                              fontSize: SizeHelper.clampFontSize(
                                MediaQuery.of(context).size.width,
                                10,
                                12,
                                14,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(SizeHelper.isMobile(context) ? 12 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.event.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeHelper.clampFontSize(
                              MediaQuery.of(context).size.width,
                              14,
                              16,
                              18,
                            ),
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: SizeHelper.isMobile(context) ? 12 : 16),
                        _EventInfo(
                          icon: Icons.calendar_today,
                          text: widget.event.date,
                        ),
                        SizedBox(height: SizeHelper.isMobile(context) ? 6 : 8),
                        _EventInfo(
                          icon: Icons.access_time,
                          text: widget.event.time,
                        ),
                        SizedBox(height: SizeHelper.isMobile(context) ? 6 : 8),
                        GestureDetector(
                          onTap: () {
                            if (widget.event.locationCoordinates != null) {
                              final lat = widget.event.locationCoordinates!['latitude'];
                              final lng = widget.event.locationCoordinates!['longitude'];
                              final uri = Uri.parse(
                                'https://www.google.com/maps?q=$lat,$lng',
                              );
                              html.window.open(uri.toString(), '_blank');
                            } else if (widget.event.location.isNotEmpty) {
                              final uri = Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.event.location)}',
                              );
                              html.window.open(uri.toString(), '_blank');
                            }
                          },
                          child: _EventInfo(
                            icon: Icons.location_on,
                            text: widget.event.location,
                          ),
                        ),
                        SizedBox(height: SizeHelper.isMobile(context) ? 8 : 10),
                        _EventInfo(
                          icon: Icons.people,
                          text: '${widget.event.participants} Katılımcı',
                        ),
                        if (widget.event.registrationFormLink != null && widget.event.registrationFormLink!.isNotEmpty) ...[
                          SizedBox(height: SizeHelper.isMobile(context) ? 12 : 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final uri = Uri.parse(widget.event.registrationFormLink!);
                                html.window.open(uri.toString(), '_blank');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.event.color,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: SizeHelper.isMobile(context) ? 10 : 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Kayıt Ol',
                                style: TextStyle(
                                  fontSize: SizeHelper.clampFontSize(
                                    MediaQuery.of(context).size.width,
                                    12,
                                    14,
                                    16,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        // Admin butonları
                        if (widget.isAdmin && (widget.onEdit != null || widget.onDelete != null)) ...[
                          SizedBox(height: SizeHelper.isMobile(context) ? 12 : 16),
                          Row(
                            children: [
                              if (widget.onEdit != null) ...[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: widget.onEdit,
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
                              if (widget.onEdit != null && widget.onDelete != null)
                                SizedBox(width: SizeHelper.isMobile(context) ? 8 : 12),
                              if (widget.onDelete != null) ...[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: widget.onDelete,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EventInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: SizeHelper.isMobile(context) ? 14 : 16,
        ),
        SizedBox(width: SizeHelper.isMobile(context) ? 6 : 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white70,
              fontSize: SizeHelper.clampFontSize(
                MediaQuery.of(context).size.width,
                11,
                13,
                15,
              ),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

