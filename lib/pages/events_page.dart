import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/header_widget.dart';
import '../widgets/footer_widget.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      body: Column(
        children: [
          const HeaderWidget(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _EventsContent(),
                  const FooterWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsContent extends StatelessWidget {
  final _firestoreService = FirestoreService();

  _EventsContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yaklaşan Etkinlikler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Yaklaşan etkinliklerimize göz atın',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
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

              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1200
                      ? 4
                      : constraints.maxWidth > 800
                          ? 3
                          : constraints.maxWidth > 600
                              ? 2
                              : 1;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.75,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  _EventInfo(icon: Icons.calendar_today, text: event.date),
                  const SizedBox(height: 8),
                  _EventInfo(icon: Icons.access_time, text: event.time),
                  const SizedBox(height: 8),
                  _EventInfo(icon: Icons.location_on, text: event.location),
                  const Spacer(),
                  _EventInfo(
                    icon: Icons.people,
                    text: '${event.participants} Katılımcı',
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
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

