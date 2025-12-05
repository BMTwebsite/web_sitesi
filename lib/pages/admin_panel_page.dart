import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Header(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Admin Paneli - İçerik Yönetimi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showAddEventDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Yeni Etkinlik Ekle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await _authService.signOut();
                              if (mounted) {
                                Navigator.pushReplacementNamed(context, '/');
                              }
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('Çıkış Yap'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  StreamBuilder<List<EventData>>(
                    stream: _firestoreService.getEvents(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Hata: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'Henüz etkinlik eklenmemiş.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      final events = snapshot.data!;

                      return GridView.builder(
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
                          return _AdminEventCard(
                            event: events[index],
                            onEdit: () => _showEditEventDialog(context, events[index]),
                            onDelete: () => _deleteEvent(events[index].id!),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    _showEventDialog(context);
  }

  void _showEditEventDialog(BuildContext context, EventData event) {
    _showEventDialog(context, event: event);
  }

  void _showEventDialog(BuildContext context, {EventData? event}) {
    final isEditing = event != null;
    final formKey = GlobalKey<FormState>();
    
    final typeController = TextEditingController(text: event?.type ?? '');
    final titleController = TextEditingController(text: event?.title ?? '');
    final dateController = TextEditingController(text: event?.date ?? '');
    final timeController = TextEditingController(text: event?.time ?? '');
    final locationController = TextEditingController(text: event?.location ?? '');
    final participantsController = TextEditingController(
      text: event?.participants.toString() ?? '0',
    );
    
    String selectedColor = event?.colorHex ?? '#2196F3';
    final colorOptions = ['#2196F3', '#F44336', '#4CAF50', '#FF9800', '#9C27B0'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A2332),
          title: Text(
            isEditing ? 'Etkinlik Düzenle' : 'Yeni Etkinlik Ekle',
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: typeController,
                      decoration: const InputDecoration(
                        labelText: 'Etkinlik Türü',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A1929),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Tür gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Başlık',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A1929),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Başlık gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'Tarih',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A1929),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Tarih gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Saat',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A1929),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Saat gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Konum',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A1929),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Konum gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: participantsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Katılımcı Sayısı',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A1929),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Katılımcı sayısı gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Renk Seçimi',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: colorOptions.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final eventData = EventData(
                    id: event?.id,
                    type: typeController.text,
                    title: titleController.text,
                    date: dateController.text,
                    time: timeController.text,
                    location: locationController.text,
                    participants: int.parse(participantsController.text),
                    colorHex: selectedColor,
                  );

                  try {
                    if (isEditing && event.id != null) {
                      await _firestoreService.updateEvent(event.id!, eventData);
                    } else {
                      await _firestoreService.addEvent(eventData);
                    }
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Etkinlik güncellendi'
                                : 'Etkinlik eklendi',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hata: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Güncelle' : 'Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEvent(String eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        title: const Text(
          'Etkinliği Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bu etkinliği silmek istediğinizden emin misiniz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteEvent(eventId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Etkinlik silindi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.memory,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'BMT - Admin Paneli',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            icon: const Icon(Icons.home),
            label: const Text('Ana Sayfaya Dön'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminEventCard extends StatelessWidget {
  final EventData event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminEventCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

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
                const Icon(Icons.calendar_today, color: Colors.white, size: 20),
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onEdit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text('Düzenle', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onDelete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text('Sil', style: TextStyle(fontSize: 12)),
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

