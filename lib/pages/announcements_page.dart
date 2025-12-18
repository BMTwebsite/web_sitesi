import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../widgets/empty_state.dart';
import '../widgets/announcement_card.dart';
import '../services/firestore_service.dart';
import '../utils/size_helper.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
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

  const _AnnouncementsContent({
    required this.firestoreService,
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
            'Tüm duyurulara buradan ulaşabilirsiniz',
            style: TextStyle(
              color: Colors.white70,
              fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 14, 16, 18),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: SizeHelper.isMobile(context) ? 24 : (SizeHelper.isTablet(context) ? 32 : 40)),
          // Announcements list
          _buildAnnouncementsList(),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    // Combine announcements and future events
    return StreamBuilder<List<AnnouncementData>>(
      stream: firestoreService.getAnnouncements(),
      builder: (context, announcementsSnapshot) {
        return StreamBuilder<List<EventData>>(
          stream: firestoreService.getEvents(),
          builder: (context, eventsSnapshot) {
            // Combine both streams
            if (announcementsSnapshot.connectionState == ConnectionState.waiting ||
                eventsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Get announcements
            final announcements = announcementsSnapshot.hasData 
                ? announcementsSnapshot.data! 
                : <AnnouncementData>[];

            // Get future events and convert to announcements
            final futureEventAnnouncements = eventsSnapshot.hasData
                ? _convertFutureEventsToAnnouncements(eventsSnapshot.data!)
                : <AnnouncementData>[];

            // Combine and sort by date (descending)
            final allAnnouncements = <AnnouncementData>[
              ...announcements,
              ...futureEventAnnouncements,
            ]..sort((a, b) {
                final dateA = _parseDate(a.date);
                final dateB = _parseDate(b.date);
                if (dateA == null && dateB == null) return 0;
                if (dateA == null) return 1;
                if (dateB == null) return -1;
                return dateB.compareTo(dateA); // Descending order
              });

            // Create a combined snapshot using withData
            final connectionState = announcementsSnapshot.connectionState == ConnectionState.waiting ||
                    eventsSnapshot.connectionState == ConnectionState.waiting
                ? ConnectionState.waiting
                : ConnectionState.done;
            
            final error = announcementsSnapshot.error ?? eventsSnapshot.error;
            
            final combinedSnapshot = error != null
                ? AsyncSnapshot<List<AnnouncementData>>.withError(connectionState, error)
                : AsyncSnapshot<List<AnnouncementData>>.withData(connectionState, allAnnouncements);

            return _buildAnnouncementsGrid(context, combinedSnapshot);
          },
        );
      },
    );
  }

  // Helper function to parse date string to DateTime
  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      // Try common date formats
      final formats = [
        'dd.MM.yyyy',
        'dd/MM/yyyy',
        'yyyy-MM-dd',
        'dd-MM-yyyy',
      ];
      for (final format in formats) {
        try {
          return DateFormat(format).parse(dateString);
        } catch (_) {}
      }
      // Try default DateTime parsing
      return DateTime.tryParse(dateString);
    } catch (_) {
      return null;
    }
  }

  // Convert future events to announcements
  List<AnnouncementData> _convertFutureEventsToAnnouncements(List<EventData> events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return events
        .where((event) {
          final eventDate = _parseDate(event.date);
          if (eventDate == null) return false;
          final eventDateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);
          return eventDateOnly.isAfter(today) || eventDateOnly.isAtSameMomentAs(today);
        })
        .map((event) {
          return AnnouncementData(
            id: event.id,
            type: 'etkinlik',
            eventName: event.title,
            posterUrl: event.images.isNotEmpty ? event.images[0] : '',
            date: event.date,
            address: event.location,
            description: null,
            link: 'internal:/events', // Etkinlikler sayfasına yönlendirme için özel işaret
            colorHex: event.colorHex,
          );
        })
        .toList();
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
          aspectRatio = 0.75; // Mobil: daha küçük kartlar
        } else if (screenWidth < 1024) {
          crossAxisCount = 2;
          aspectRatio = 0.8; // Tablet: 2 sütun, daha küçük kartlar
        } else {
          crossAxisCount = screenWidth > 1400 ? 4 : 3;
          aspectRatio = 0.75; // Desktop: 3-4 sütun, daha küçük kartlar
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
            return AnnouncementCard(
              announcement: announcements[index],
              isAdmin: false,
            );
          },
        );
      },
    );
  }
}

