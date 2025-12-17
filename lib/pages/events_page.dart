import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../widgets/empty_state.dart';
import '../widgets/image_viewer_dialog.dart';
import '../services/firestore_service.dart';
import '../utils/size_helper.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: HeaderSliverDelegate(
              child: const Header(currentRoute: '/events'),
              context: context,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _EventsContent(),
                const Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsContent extends StatelessWidget {
  final _firestoreService = FirestoreService();

  // AnnouncementData'yı EventData'ya dönüştür
  EventData _announcementToEvent(AnnouncementData announcement) {
    return EventData(
      id: announcement.id,
      type: announcement.type,
      title: announcement.eventName,
      date: announcement.date,
      time: 'Belirtilmemiş', // AnnouncementData'da time yok
      location: announcement.address,
      participants: 0, // AnnouncementData'da participants yok
      colorHex: announcement.colorHex,
      images: announcement.posterUrl.isNotEmpty ? [announcement.posterUrl] : [],
    );
  }

  // İki stream'i birleştir
  Stream<List<EventData>> _getCombinedEvents() {
    final eventsStream = _firestoreService.getEvents();
    final announcementsStream = _firestoreService.getAnnouncementsByType('etkinlik');

    // İki stream'i birleştirmek için bir controller kullan
    final controller = StreamController<List<EventData>>();
    List<EventData> events = [];
    List<AnnouncementData> announcements = [];

    void emitCombined() {
      // AnnouncementData'ları EventData'ya dönüştür
      final eventAnnouncements = announcements.map(_announcementToEvent).toList();

      // İki listeyi birleştir
      final combined = <EventData>[...events, ...eventAnnouncements];

      // Tarihe göre sırala (en yakın tarih önce)
      combined.sort((a, b) => a.date.compareTo(b.date));

      controller.add(combined);
    }

    final eventsSubscription = eventsStream.listen(
      (data) {
        events = data;
        emitCombined();
      },
      onError: (error) => controller.addError(error),
    );

    final announcementsSubscription = announcementsStream.listen(
      (data) {
        announcements = data;
        emitCombined();
      },
      onError: (error) => controller.addError(error),
    );

    // Controller kapandığında subscription'ları iptal et
    controller.onCancel = () {
      eventsSubscription.cancel();
      announcementsSubscription.cancel();
    };

    return controller.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0E17),
            const Color(0xFF1A2332).withOpacity(0.3),
            const Color(0xFF0A0E17),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: SizeHelper.isMobile(context) ? 16 : (SizeHelper.isTablet(context) ? 32 : 60),
        vertical: SizeHelper.isMobile(context) ? 40 : (SizeHelper.isTablet(context) ? 50 : 60),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2196F3).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.event,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Etkinlikler',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Etkinlik Takvimi',
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 28, 38, 48),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: SizeHelper.isMobile(context) ? 12 : 16),
          Text(
            'Yaklaşan etkinliklerimize göz atın ve teknoloji dünyasında bir adım öne geçin',
            style: TextStyle(
              color: Colors.white70,
              fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 14, 16, 18),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 40),
          StreamBuilder<List<EventData>>(
            stream: _getCombinedEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isMobile = SizeHelper.isMobile(context);
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 20 : 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: SizeHelper.clampFontSize(screenWidth, 32, 40, 48),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        Text(
                          'Etkinlikler yüklenirken bir hata oluştu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeHelper.clampFontSize(screenWidth, 14, 16, 18),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isMobile ? 8 : 12),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: SizeHelper.clampFontSize(screenWidth, 11, 13, 15),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const EmptyState(
                  message: 'Henüz etkinlik eklenmemiş.',
                  icon: Icons.event,
                );
              }

              final events = snapshot.data!;

              return LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive grid: mobile 1, tablet 2, desktop 3-4
                  final screenWidth = MediaQuery.of(context).size.width;
                  int crossAxisCount;
                  double aspectRatio;
                  
                  if (screenWidth < 600) {
                    crossAxisCount = 1;
                    aspectRatio = 0.85; // Mobil: daha uzun kartlar
                  } else if (screenWidth < 1024) {
                    crossAxisCount = 2;
                    aspectRatio = 0.75; // Tablet: 2 sütun
                  } else {
                    crossAxisCount = screenWidth > 1400 ? 4 : 3;
                    aspectRatio = 0.7; // Desktop: 3-4 sütun
                  }
                  
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: screenWidth < 600 ? 12 : (screenWidth < 1024 ? 16 : 20),
                      mainAxisSpacing: screenWidth < 600 ? 12 : (screenWidth < 1024 ? 16 : 20),
                      childAspectRatio: aspectRatio,
                    ),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return _EventCard(events[index]);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventData event;

  const _EventCard(this.event);

  Widget _buildPosterImage(String imageUrl, double screenWidth, double imageSize, Color fallbackColor, BuildContext context) {
    if (kIsWeb) {
      // Web için HTML img elementi kullan (CORS sorununu çözer)
      final imageId = 'event_img_${event.id ?? DateTime.now().millisecondsSinceEpoch}';
      
      // HTML img elementi oluştur
      final imgElement = html.ImageElement()
        ..src = imageUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain'
        ..style.cursor = 'pointer'
        ..onError.listen((_) {
          print('❌ Event Page - HTML img yükleme hatası: $imageUrl');
        })
        ..onLoad.listen((_) {
          print('✅ Event Page - HTML img yüklendi: $imageUrl');
        });
      
      // Platform view registry'ye kaydet
      ui_web.platformViewRegistry.registerViewFactory(
        imageId,
        (int viewId) => imgElement,
      );
      
      return GestureDetector(
        onTap: () {
          ImageViewerDialog.show(context, imageUrl, title: event.title);
        },
        child: HtmlElementView(viewType: imageId),
      );
    } else {
      // Mobile için normal Image.network kullan
      return GestureDetector(
        onTap: () {
          ImageViewerDialog.show(context, imageUrl, title: event.title);
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
              child: Icon(
                Icons.image_not_supported,
                color: Colors.white54,
                size: SizeHelper.clampFontSize(screenWidth, 32, 40, 48),
              ),
            ),
          );
        },
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
          color: event.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster image
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

                final posterUrl = event.images.isNotEmpty ? event.images.first : '';

                return Container(
                  height: posterHeight,
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: posterHeight,
                    minHeight: 100,
                  ),
                  color: const Color(0xFF1A2332),
                  child: posterUrl.isNotEmpty
                      ? _buildPosterImage(posterUrl, screenWidth, posterHeight, event.color, context)
                      : Container(
                          color: event.color.withOpacity(0.2),
                          child: Center(
                            child: Icon(
                              Icons.event,
                              color: Colors.white54,
                              size: SizeHelper.clampFontSize(screenWidth, 32, 40, 48),
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
          // Type badge
          Padding(
            padding: EdgeInsets.all(SizeHelper.isMobile(context) ? 12 : 16),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeHelper.isMobile(context) ? 10 : 12,
                vertical: SizeHelper.isMobile(context) ? 5 : 6,
              ),
              decoration: BoxDecoration(
                color: event.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: event.color,
                    size: SizeHelper.isMobile(context) ? 14 : 16,
                  ),
                  SizedBox(width: SizeHelper.isMobile(context) ? 5 : 6),
                  Flexible(
                    child: Text(
                      event.type,
                      style: TextStyle(
                        color: event.color,
                        fontSize: SizeHelper.clampFontSize(
                          MediaQuery.of(context).size.width,
                          10,
                          12,
                          14,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                  event.title,
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
                  text: event.date,
                ),
                SizedBox(height: SizeHelper.isMobile(context) ? 6 : 8),
                _EventInfo(
                  icon: Icons.access_time,
                  text: event.time,
                ),
                SizedBox(height: SizeHelper.isMobile(context) ? 6 : 8),
                GestureDetector(
                  onTap: () {
                    if (event.locationCoordinates != null) {
                      final lat = event.locationCoordinates!['latitude'];
                      final lng = event.locationCoordinates!['longitude'];
                      final uri = Uri.parse(
                        'https://www.google.com/maps?q=$lat,$lng',
                      );
                      html.window.open(uri.toString(), '_blank');
                    } else if (event.location.isNotEmpty) {
                      final uri = Uri.parse(
                        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(event.location)}',
                      );
                      html.window.open(uri.toString(), '_blank');
                    }
                  },
                  child: _EventInfo(
                    icon: Icons.location_on,
                    text: event.location,
                  ),
                ),
                SizedBox(height: SizeHelper.isMobile(context) ? 8 : 10),
                _EventInfo(
                  icon: Icons.people,
                  text: '${event.participants} Katılımcı',
                ),
                if (event.registrationFormLink != null && event.registrationFormLink!.isNotEmpty) ...[
                  SizedBox(height: SizeHelper.isMobile(context) ? 12 : 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final uri = Uri.parse(event.registrationFormLink!);
                        html.window.open(uri.toString(), '_blank');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: event.color,
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
              ],
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

