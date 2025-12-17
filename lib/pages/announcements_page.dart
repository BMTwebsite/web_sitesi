import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../widgets/empty_state.dart';
import '../widgets/image_viewer_dialog.dart';
import '../services/firestore_service.dart';
import '../utils/size_helper.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final _firestoreService = FirestoreService();
  String _selectedType = 'Tümü'; // 'Tümü', 'Bölüm', 'Etkinlik', 'Topluluk'

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
              child: const Header(currentRoute: '/announcements'),
              context: context,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _AnnouncementsContent(
                  firestoreService: _firestoreService,
                  selectedType: _selectedType,
                  onTypeChanged: (type) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                ),
                const Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementsContent extends StatelessWidget {
  final FirestoreService firestoreService;
  final String selectedType;
  final Function(String) onTypeChanged;

  const _AnnouncementsContent({
    required this.firestoreService,
    required this.selectedType,
    required this.onTypeChanged,
  });

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
            padding: EdgeInsets.symmetric(
              horizontal: SizeHelper.isMobile(context) ? 12 : 20,
              vertical: SizeHelper.isMobile(context) ? 8 : 10,
            ),
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
                Icon(
                  Icons.notifications,
                  color: const Color(0xFF2196F3),
                  size: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 16, 18, 20),
                ),
                SizedBox(width: SizeHelper.isMobile(context) ? 6 : 8),
                Text(
                  'Duyurular',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 12, 13, 14),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Duyurular',
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 28, 38, 48),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: SizeHelper.isMobile(context) ? 12 : 16),
          Text(
            'Bölüm, etkinlik ve topluluk duyurularına buradan ulaşabilirsiniz',
            style: TextStyle(
              color: Colors.white70,
              fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 14, 16, 18),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: SizeHelper.isMobile(context) ? 24 : (SizeHelper.isTablet(context) ? 32 : 40)),
          // Filter buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
              _FilterButton(
                label: 'Tümü',
                isSelected: selectedType == 'Tümü',
                onTap: () => onTypeChanged('Tümü'),
              ),
              const SizedBox(width: 12),
              _FilterButton(
                label: 'Bölüm Duyuruları',
                isSelected: selectedType == 'Bölüm',
                onTap: () => onTypeChanged('Bölüm'),
              ),
              const SizedBox(width: 12),
              _FilterButton(
                label: 'Etkinlik Duyuruları',
                isSelected: selectedType == 'Etkinlik',
                onTap: () => onTypeChanged('Etkinlik'),
              ),
              const SizedBox(width: 12),
              _FilterButton(
                label: 'Topluluk Duyuruları',
                isSelected: selectedType == 'Topluluk',
                onTap: () => onTypeChanged('Topluluk'),
              ),
            ],
            ),
          ),
          SizedBox(height: SizeHelper.isMobile(context) ? 20 : 30),
          // Announcements list
          _buildAnnouncementsList(),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    if (selectedType == 'Tümü') {
      return StreamBuilder<List<AnnouncementData>>(
        stream: firestoreService.getAnnouncements(),
        builder: (context, snapshot) {
          return _buildAnnouncementsGrid(context, snapshot);
        },
      );
    } else {
      return StreamBuilder<List<AnnouncementData>>(
        stream: firestoreService.getAnnouncementsByType(selectedType.toLowerCase()),
        builder: (context, snapshot) {
          return _buildAnnouncementsGrid(context, snapshot);
        },
      );
    }
  }

  Widget _buildAnnouncementsGrid(BuildContext context, AsyncSnapshot<List<AnnouncementData>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (snapshot.hasError) {
      final errorMessage = snapshot.error.toString();
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
                'Duyurular yüklenirken bir hata oluştu',
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
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: SizeHelper.clampFontSize(screenWidth, 11, 13, 15),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (errorMessage.contains('index')) ...[
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'Firebase Console\'da gerekli index\'i oluşturmanız gerekiyor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: SizeHelper.clampFontSize(screenWidth, 11, 13, 15),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const EmptyState(
        message: 'Henüz duyuru eklenmemiş.',
        icon: Icons.notifications_none,
      );
    }

    final announcements = snapshot.data!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        // Responsive aspect ratio ve grid
        double aspectRatio;
        int crossAxisCount;
        
        if (screenWidth < 600) {
          crossAxisCount = 1;
          aspectRatio = 0.7; // Mobil: daha kompakt kartlar
        } else if (screenWidth < 1024) {
          crossAxisCount = 2;
          aspectRatio = 0.65; // Tablet: 2 sütun
        } else {
          crossAxisCount = screenWidth > 1400 ? 4 : 3;
          aspectRatio = 0.55; // Desktop: 3-4 sütun - daha kompakt
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
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            return _AnnouncementCard(announcements[index]);
          },
        );
      },
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = SizeHelper.isMobile(context);
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : (screenWidth < 1024 ? 16 : 20),
          vertical: isMobile ? 6 : (screenWidth < 1024 ? 8 : 10),
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : Colors.white54,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: SizeHelper.clampFontSize(screenWidth, 11, 13, 14),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementData announcement;

  const _AnnouncementCard(this.announcement);

  Widget _buildPosterImage(String imageUrl, double screenWidth, double imageSize, Color fallbackColor, String? id, BuildContext context, String eventName) {
    if (kIsWeb) {
      // Web için HTML img elementi kullan (CORS sorununu çözer)
      final imageId = 'announcement_img_${id ?? DateTime.now().millisecondsSinceEpoch}';
      
      // HTML img elementi oluştur
      final imgElement = html.ImageElement()
        ..src = imageUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain'
        ..style.cursor = 'pointer'
        ..onError.listen((_) {
          print('❌ Announcement Page - HTML img yükleme hatası: $imageUrl');
        })
        ..onLoad.listen((_) {
          print('✅ Announcement Page - HTML img yüklendi: $imageUrl');
        });
      
      // Platform view registry'ye kaydet
      ui_web.platformViewRegistry.registerViewFactory(
        imageId,
        (int viewId) => imgElement,
      );
      
      return GestureDetector(
        onTap: () {
          ImageViewerDialog.show(context, imageUrl, title: eventName);
        },
        child: HtmlElementView(viewType: imageId),
      );
    } else {
      // Mobile için normal Image.network kullan
      return GestureDetector(
        onTap: () {
          ImageViewerDialog.show(context, imageUrl, title: eventName);
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

  String _getTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'bölüm':
        return 'Bölüm Duyuruları';
      case 'etkinlik':
        return 'Etkinlik Duyuruları';
      case 'topluluk':
        return 'Topluluk Duyuruları';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: announcement.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster image - sadece varsa göster
          if (announcement.posterUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              child: Builder(
                builder: (context) {
                  // Responsive poster yüksekliği - daha küçük
                  final screenWidth = MediaQuery.of(context).size.width;
                  double posterHeight;
                  if (screenWidth < 600) {
                    posterHeight = 120; // Mobil
                  } else if (screenWidth < 1024) {
                    posterHeight = 130; // Tablet
                  } else {
                    posterHeight = 140; // Desktop
                  }

                  return Container(
                    height: posterHeight,
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: posterHeight,
                      minHeight: 100,
                    ),
                    color: const Color(0xFF1A2332),
                    child: _buildPosterImage(
                      announcement.posterUrl,
                      screenWidth,
                      posterHeight,
                      announcement.color,
                      announcement.id,
                      context,
                      announcement.eventName,
                    ),
                  );
                },
              ),
            ),
          // Content - responsive padding ve spacing - daha kompakt
          Padding(
            padding: EdgeInsets.all(SizeHelper.isMobile(context) ? 8 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Type badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeHelper.isMobile(context) ? 6 : 8,
                    vertical: SizeHelper.isMobile(context) ? 2 : 3,
                  ),
                  decoration: BoxDecoration(
                    color: announcement.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    _getTypeDisplayName(announcement.type),
                    style: TextStyle(
                      color: announcement.color,
                      fontSize: SizeHelper.clampFontSize(
                        MediaQuery.of(context).size.width,
                        8,
                        10,
                        12,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: SizeHelper.isMobile(context) ? 8 : 10),
                // Event name
                Text(
                  announcement.eventName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeHelper.clampFontSize(
                      MediaQuery.of(context).size.width,
                      12,
                      14,
                      16,
                    ),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: SizeHelper.isMobile(context) ? 8 : 10),
                // Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                      size: SizeHelper.isMobile(context) ? 12 : 14,
                    ),
                    SizedBox(width: SizeHelper.isMobile(context) ? 4 : 5),
                    Expanded(
                      child: Text(
                        announcement.date,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: SizeHelper.clampFontSize(
                            MediaQuery.of(context).size.width,
                            10,
                            12,
                            14,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeHelper.isMobile(context) ? 5 : 6),
                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: SizeHelper.isMobile(context) ? 12 : 14,
                    ),
                    SizedBox(width: SizeHelper.isMobile(context) ? 4 : 5),
                    Expanded(
                      child: Text(
                        announcement.address,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: SizeHelper.clampFontSize(
                            MediaQuery.of(context).size.width,
                            10,
                            12,
                            14,
                          ),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Link (if exists)
                if (announcement.link != null && announcement.link!.isNotEmpty) ...[
                  SizedBox(height: SizeHelper.isMobile(context) ? 5 : 6),
                  InkWell(
                    onTap: () {
                      html.window.open(announcement.link!, '_blank');
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.link,
                          color: announcement.color,
                          size: SizeHelper.isMobile(context) ? 12 : 14,
                        ),
                        SizedBox(width: SizeHelper.isMobile(context) ? 4 : 5),
                        Expanded(
                          child: Text(
                            'Linke Git',
                            style: TextStyle(
                              color: announcement.color,
                              fontSize: SizeHelper.clampFontSize(
                                MediaQuery.of(context).size.width,
                                10,
                                12,
                                14,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

