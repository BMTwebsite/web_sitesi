import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  final List<EventData> events = [
    EventData(
      type: 'Workshop',
      title: 'Yapay Zeka ve Makine Öğrenmesi Workshop',
      date: '15 Aralık 2025',
      time: '14:00',
      location: 'Konferans Salonu A',
      participants: 45,
      color: const Color(0xFF2196F3),
    ),
    EventData(
      type: 'Bootcamp',
      title: 'Web Geliştirme Bootcamp',
      date: '20 Aralık 2025',
      time: '10:00',
      location: 'Bilgisayar Laboratuvarı',
      participants: 60,
      color: const Color(0xFFF44336),
    ),
    EventData(
      type: 'Seminer',
      title: 'Siber Güvenlik Semineri',
      date: '22 Aralık 2025',
      time: '15:30',
      location: 'Amfi 3',
      participants: 80,
      color: const Color(0xFF2196F3),
    ),
    EventData(
      type: 'Workshop',
      title: 'Mobil Uygulama Geliştirme',
      date: '28 Aralık 2025',
      time: '13:00',
      location: 'Laboratuvar B',
      participants: 35,
      color: const Color(0xFFF44336),
    ),
    EventData(
      type: 'Seminer',
      title: 'Blockchain Teknolojileri',
      date: '5 Ocak 2026',
      time: '16:00',
      location: 'Konferans Salonu B',
      participants: 55,
      color: const Color(0xFF2196F3),
    ),
    EventData(
      type: 'Panel',
      title: 'Kariyer Paneli',
      date: '10 Ocak 2026',
      time: '14:00',
      location: 'Amfi 1',
      participants: 100,
      color: const Color(0xFFF44336),
    ),
    EventData(
      type: 'Atölye',
      title: 'UI/UX Tasarım Atölyesi',
      date: '15 Ocak 2026',
      time: '11:00',
      location: 'Tasarım Stüdyosu',
      participants: 40,
      color: const Color(0xFF2196F3),
    ),
    EventData(
      type: 'Workshop',
      title: 'DevOps ve CI/CD',
      date: '20 Ocak 2026',
      time: '13:30',
      location: 'Laboratuvar A',
      participants: 50,
      color: const Color(0xFFF44336),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Etkinlik Takvimi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Yaklaşan etkinliklerimize göz atın ve teknoloji dünyasında bir adım öne geçin',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.75,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return _EventCard(events[index]);
            },
          ),
        ],
      ),
    );
  }
}

class EventData {
  final String type;
  final String title;
  final String date;
  final String time;
  final String location;
  final int participants;
  final Color color;

  EventData({
    required this.type,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.participants,
    required this.color,
  });
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
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top colored section
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
                    color: Colors.white.withOpacity(0.2),
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
          // Content
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
                    width: double.infinity,
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
                      child: const Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

