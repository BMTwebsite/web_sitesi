import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../services/firestore_service.dart';
import '../utils/size_helper.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Header(currentRoute: '/events'),
            _EventsContent(),
            const Footer(),
          ],
        ),
      ),
    );
  }
}

class _EventsContent extends StatelessWidget {
  final _firestoreService = FirestoreService();

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
              fontSize: SizeHelper.safeFontSize(context, preferredSize: 48),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Yaklaşan etkinliklerimize göz atın ve teknoloji dünyasında bir adım öne geçin',
            style: TextStyle(
              color: Colors.white70,
              fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
            ),
          ),
          const SizedBox(height: 40),
          StreamBuilder<List<EventData>>(
            stream: _firestoreService.getEvents(),
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'Etkinlikler yüklenirken bir hata oluştu: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'Henüz etkinlik eklenmemiş.',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ),
                );
              }

              final events = snapshot.data!;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: SizeHelper.safeCrossAxisCount(context, preferredCount: 4),
                  crossAxisSpacing: SizeHelper.safeSize(value: 20, min: 10, max: 40, context: 'Grid spacing'),
                  mainAxisSpacing: SizeHelper.safeSize(value: 20, min: 10, max: 40, context: 'Grid spacing'),
                  childAspectRatio: SizeHelper.safeSize(value: 0.75, min: 0.5, max: 1.0, context: 'Grid aspect ratio'),
                ),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return _EventCard(events[index]);
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
          // Type badge at top
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
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
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    event.type,
                    style: TextStyle(
                      color: event.color,
                      fontSize: SizeHelper.safeFontSize(context, preferredSize: 12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  _EventInfo(
                    icon: Icons.calendar_today,
                    text: event.date,
                  ),
                  const SizedBox(height: 8),
                  _EventInfo(
                    icon: Icons.access_time,
                    text: event.time,
                  ),
                  const SizedBox(height: 8),
                  _EventInfo(
                    icon: Icons.location_on,
                    text: event.location,
                  ),
                  const Spacer(),
                  _EventInfo(
                    icon: Icons.people,
                    text: '${event.participants} Katılımcı',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: SizeHelper.safeInfinity(context, isWidth: true),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: event.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          fontSize: SizeHelper.safeFontSize(context, preferredSize: 14),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white70,
              fontSize: SizeHelper.safeFontSize(context, preferredSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}

