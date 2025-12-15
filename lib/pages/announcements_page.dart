import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Header(currentRoute: '/announcements'),
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
      padding: SizeHelper.safePadding(
        context: context,
        horizontal: 60,
        vertical: 60,
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
                  Icons.notifications,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Duyurular',
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
            'Duyurular',
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeHelper.safeFontSize(context, preferredSize: 48),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bölüm, etkinlik ve topluluk duyurularına buradan ulaşabilirsiniz',
            style: TextStyle(
              color: Colors.white70,
              fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
            ),
          ),
          const SizedBox(height: 40),
          // Filter buttons
          Row(
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
          const SizedBox(height: 30),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Duyurular yüklenirken bir hata oluştu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeHelper.safeFontSize(context, preferredSize: 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              if (errorMessage.contains('index')) ...[
                const SizedBox(height: 16),
                const Text(
                  'Firebase Console\'da gerekli index\'i oluşturmanız gerekiyor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'Henüz duyuru eklenmemiş.',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ),
      );
    }

    final announcements = snapshot.data!;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: SizeHelper.safeCrossAxisCount(context, preferredCount: 3),
        crossAxisSpacing: SizeHelper.safeSize(value: 20, min: 10, max: 40, context: 'Grid spacing'),
        mainAxisSpacing: SizeHelper.safeSize(value: 20, min: 10, max: 40, context: 'Grid spacing'),
        childAspectRatio: SizeHelper.safeSize(value: 0.7, min: 0.5, max: 1.0, context: 'Grid aspect ratio'),
      ),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        return _AnnouncementCard(announcements[index]);
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeHelper.safeSize(value: 20, min: 10, max: 40, context: 'Filter button padding horizontal'),
          vertical: SizeHelper.safeSize(value: 10, min: 5, max: 20, context: 'Filter button padding vertical'),
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
            fontSize: SizeHelper.safeFontSize(context, preferredSize: 14),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementData announcement;

  const _AnnouncementCard(this.announcement);

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
          // Poster image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            child: Container(
              height: SizeHelper.safeSize(value: 200, min: 100, max: 400, context: 'Announcement poster height'),
              width: SizeHelper.safeInfinity(context, isWidth: true),
              color: const Color(0xFF1A2332),
              child: announcement.posterUrl.isNotEmpty
                  ? Image.network(
                      announcement.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: announcement.color.withOpacity(0.2),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.white54,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: announcement.color.withOpacity(0.2),
                      child: const Center(
                        child: Icon(
                          Icons.campaign,
                          color: Colors.white54,
                          size: 48,
                        ),
                      ),
                    ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeHelper.safeSize(value: 10, min: 5, max: 20, context: 'Badge padding horizontal'),
                      vertical: SizeHelper.safeSize(value: 4, min: 2, max: 8, context: 'Badge padding vertical'),
                    ),
                    decoration: BoxDecoration(
                      color: announcement.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getTypeDisplayName(announcement.type),
                      style: TextStyle(
                        color: announcement.color,
                        fontSize: SizeHelper.safeFontSize(context, preferredSize: 11),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Event name
                  Text(
                    announcement.eventName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          announcement.date,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          announcement.address,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

