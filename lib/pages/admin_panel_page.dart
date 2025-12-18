import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:async';
// Conditional imports for web-specific features
import 'dart:html' as html;
import 'dart:ui_web' as ui_web show platformViewRegistry;
import '../providers/auth_provider.dart';
import '../providers/firestore_provider.dart';
import '../services/storage_service.dart';
import '../utils/size_helper.dart';
import '../widgets/address_picker_dialog.dart';
import '../widgets/announcement_card.dart';
import '../widgets/event_card.dart';
import '../widgets/team_member_card.dart';
import '../widgets/sponsor_card.dart';
import '../widgets/circular_logo_widget.dart';

class AdminPanelPage extends StatefulWidget {
  final int? initialTab;
  
  const AdminPanelPage({super.key, this.initialTab});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  late int _selectedTab;
  
  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab ?? 0;
  }

  // Helper function to create object URL from blob (web only)
  String _createObjectUrlFromBlob(html.Blob blob) {
    if (kIsWeb) {
      try {
        // ignore: avoid_web_libraries_in_flutter
        return html.Url.createObjectUrlFromBlob(blob);
      } catch (e) {
        print('Error creating object URL from blob: $e');
        return '';
      }
    }
    return '';
  }

  // Helper function to create object URL for preview (web only)
  String _createObjectUrl(PlatformFile file) {
    if (kIsWeb && file.bytes != null) {
      try {
        // ignore: avoid_web_libraries_in_flutter
        final blob = html.Blob([file.bytes!]);
        // ignore: avoid_web_libraries_in_flutter
        return _createObjectUrlFromBlob(blob);
      } catch (e) {
        print('Error creating object URL: $e');
        return '';
      }
    }
    // For mobile, return empty string - we'll use file.path or bytes directly
    return '';
  }


  // Helper function to revoke object URL (web only)
  void _revokeObjectUrl(String url) {
    if (kIsWeb && url.isNotEmpty) {
      try {
        // ignore: avoid_web_libraries_in_flutter
        html.Url.revokeObjectUrl(url);
      } catch (e) {
        print('Error revoking object URL: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = SizeHelper.isMobile(context);
    final isTablet = SizeHelper.isTablet(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Header(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 24 : 60),
                vertical: isMobile ? 20 : (isTablet ? 30 : 40),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Action Buttons
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = constraints.maxWidth < 900;
                      
                      if (isSmallScreen) {
                        // Küçük ekranlar için column layout
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Paneli',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeHelper.clampFontSize(
                                  MediaQuery.of(context).size.width,
                                  24,
                                  32,
                                  48,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _clearPendingAdmins(context),
                                  icon: const Icon(Icons.delete_sweep),
                                  label: Text(
                                    isMobile ? 'Sıfırla' : 'Bekleyen Onay Maillerini Sıfırla',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                    side: const BorderSide(color: Colors.orange),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 12 : 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                    await authProvider.signOut();
                                    if (mounted) {
                                      Navigator.pushReplacementNamed(context, '/');
                                    }
                                  },
                                  icon: const Icon(Icons.logout),
                                  label: const Text('Çıkış Yap'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white54),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 12 : 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      
                      // Büyük ekranlar için row layout
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              'Admin Paneli',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeHelper.clampFontSize(
                                  MediaQuery.of(context).size.width,
                                  32,
                                  40,
                                  48,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Wrap(
                              spacing: 12,
                              alignment: WrapAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _clearPendingAdmins(context),
                                  icon: const Icon(Icons.delete_sweep),
                                  label: const Text('Bekleyen Onay Maillerini Sıfırla'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                    side: const BorderSide(color: Colors.orange),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                    await authProvider.signOut();
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
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: isMobile ? 20 : 30),
                  // Tab Bar - Yatay kaydırılabilir
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TabButton(
                          label: 'Ana Sayfa',
                          isSelected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                        const SizedBox(width: 16),
                        _TabButton(
                          label: 'Duyurular',
                          isSelected: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                        const SizedBox(width: 16),
                        _TabButton(
                          label: 'Etkinlikler',
                          isSelected: _selectedTab == 2,
                          onTap: () => setState(() => _selectedTab = 2),
                        ),
                        const SizedBox(width: 16),
                        _TabButton(
                          label: 'Ekip',
                          isSelected: _selectedTab == 3,
                          onTap: () => setState(() => _selectedTab = 3),
                        ),
                        const SizedBox(width: 16),
                        _TabButton(
                          label: 'Sponsorlar',
                          isSelected: _selectedTab == 4,
                          onTap: () => setState(() => _selectedTab = 4),
                        ),
                        const SizedBox(width: 16),
                        _TabButton(
                          label: 'Hakkımızda',
                          isSelected: _selectedTab == 5,
                          onTap: () => setState(() => _selectedTab = 5),
                        ),
                        const SizedBox(width: 16),
                        _TabButton(
                          label: 'İletişim',
                          isSelected: _selectedTab == 6,
                          onTap: () => setState(() => _selectedTab = 6),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 20 : 30),
                  // Tab Content
                  if (_selectedTab == 0) _buildHomeTab(),
                  if (_selectedTab == 1) _buildAnnouncementsTab(),
                  if (_selectedTab == 2) _buildEventsTab(),
                  if (_selectedTab == 3) _buildTeamsTab(),
                  if (_selectedTab == 4) _buildSponsorsTab(),
                  if (_selectedTab == 5) _buildAboutTab(),
                  if (_selectedTab == 6) _buildContactSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHomeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showAddHomeSectionDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Yeni Bölüm Ekle'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Consumer<FirestoreProvider>(
          builder: (context, firestoreProvider, _) => StreamBuilder<List<HomeSectionData>>(
            stream: firestoreProvider.getHomeSections(),
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
                    'Henüz bölüm eklenmemiş.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              final sections = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  return _AdminHomeSectionCard(
                    section: sections[index],
                    onEdit: () => _showEditHomeSectionDialog(context, sections[index]),
                    onDelete: () => _deleteHomeSection(sections[index].id!),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 20),
        Consumer<FirestoreProvider>(
          builder: (context, firestoreProvider, _) => StreamBuilder<List<EventData>>(
            stream: firestoreProvider.getEvents(),
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
                childAspectRatio: 0.6,
              ),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return EventCard(
                  event: events[index],
                  isAdmin: true,
                  onEdit: () => _showEditEventDialog(context, events[index]),
                  onDelete: () => _deleteEvent(events[index].id!),
                );
              },
            );
          },
          ),
        ),
      ],
    );
  }

  Widget _buildAboutTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hakkımızda Açıklaması Düzenleme Bölümü
        Consumer<FirestoreProvider>(
          builder: (context, firestoreProvider, _) => StreamBuilder<Map<String, dynamic>>(
            stream: firestoreProvider.getSiteSettingsStream(),
            builder: (context, settingsSnapshot) {
              if (settingsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final settings = settingsSnapshot.data ?? {};
              final aboutDescription = settings['aboutDescription'] ?? 
                  'Teknoloji tutkumuzu akademik bilgiyle birleştiriyor, Bandırma\'dan dünyaya açılan projeler geliştiriyoruz.';
              
              return _AboutDescriptionEditor(
                initialDescription: aboutDescription,
                onSave: (newDescription) async {
                  try {
                    await firestoreProvider.updateSiteSettings({
                      'aboutDescription': newDescription,
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hakkımızda açıklaması başarıyla güncellendi'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hata: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(height: 30),
        const Divider(color: Colors.white24),
        const SizedBox(height: 30),
        const Text(
          'Hakkımızda Bölümleri',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _showAddAboutSectionDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Yeni Bölüm Ekle'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Consumer<FirestoreProvider>(
          builder: (context, firestoreProvider, _) => StreamBuilder<List<AboutSectionData>>(
            stream: firestoreProvider.getAboutSections(),
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
                    'Henüz bölüm eklenmemiş.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              final sections = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  return _AdminAboutSectionCard(
                    section: sections[index],
                    onEdit: () => _showEditAboutSectionDialog(context, sections[index]),
                    onDelete: () => _deleteAboutSection(sections[index].id!),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactSettingsTab() {
    return Consumer<FirestoreProvider>(
      builder: (context, firestoreProvider, _) => StreamBuilder<Map<String, dynamic>>(
        stream: firestoreProvider.getContactSettingsStream(),
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

        final settings = snapshot.data ?? {};
        return _ContactSettingsEditor(settings: settings);
      },
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showAddAnnouncementDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Yeni Duyuru Ekle'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Consumer<FirestoreProvider>(
          builder: (context, firestoreProvider, _) => StreamBuilder<List<AnnouncementData>>(
            stream: firestoreProvider.getAnnouncements(),
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
                    'Henüz duyuru eklenmemiş.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              final announcements = snapshot.data!;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.6,
                ),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  return AnnouncementCard(
                    announcement: announcements[index],
                    isAdmin: true,
                    onEdit: () => _showEditAnnouncementDialog(context, announcements[index]),
                    onDelete: () => _deleteAnnouncement(announcements[index].id!),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddEventDialog(BuildContext context) {
    _showEventDialog(context);
  }

  void _showEditEventDialog(BuildContext context, EventData event) {
    _showEventDialog(context, event: event);
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

  // Helper function to format DateTime to Turkish format
  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  // Helper function to parse time string
  TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    try {
      // Try HH:mm format
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
      // Try other common formats
      return TimeOfDay.fromDateTime(DateTime.parse('2000-01-01 $timeString'));
    } catch (_) {
      return null;
    }
  }

  // Helper function to format TimeOfDay to HH:mm format
  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showEventDialog(BuildContext context, {EventData? event}) {
    final isEditing = event != null;
    final formKey = GlobalKey<FormState>();
    final storageService = StorageService();
    
    final typeController = TextEditingController(text: event?.type ?? '');
    final titleController = TextEditingController(text: event?.title ?? '');
    final dateController = TextEditingController(text: event?.date ?? '');
    final timeController = TextEditingController(text: event?.time ?? '');
    final locationController = TextEditingController(text: event?.location ?? '');
    final participantsController = TextEditingController(
      text: event?.participants.toString() ?? '0',
    );
    final registrationFormLinkController = TextEditingController(
      text: event?.registrationFormLink ?? '',
    );
    
    String selectedColor = event?.colorHex ?? '#2196F3';
    final colorOptions = ['#2196F3', '#F44336', '#4CAF50', '#FF9800', '#9C27B0'];
    
    // Image state
    List<PlatformFile> selectedFiles = [];
    List<String> existingImageUrls = event?.images ?? [];
    List<String> imageUrlsToDelete = [];
    Map<PlatformFile, String> fileObjectUrls = {};

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
            width: 600,
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
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Tür gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Etkinlik Adı',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Etkinlik adı gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    // Date picker field
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Tarih',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF0A0E17),
                        suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Tarih gerekli' : null,
                      onTap: () async {
                        final initialDate = _parseDate(dateController.text) ?? DateTime.now();
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFF2196F3),
                                  onPrimary: Colors.white,
                                  surface: Color(0xFF1A2332),
                                  onSurface: Colors.white,
                                ),
                                dialogBackgroundColor: const Color(0xFF1A2332),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          dateController.text = _formatDate(pickedDate);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Time picker field
                    TextFormField(
                      controller: timeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Saat',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF0A0E17),
                        suffixIcon: const Icon(Icons.access_time, color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Saat gerekli' : null,
                      onTap: () async {
                        final initialTime = _parseTime(timeController.text) ?? TimeOfDay.now();
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: initialTime,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFF2196F3),
                                  onPrimary: Colors.white,
                                  surface: Color(0xFF1A2332),
                                  onSurface: Colors.white,
                                ),
                                dialogBackgroundColor: const Color(0xFF1A2332),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime != null) {
                          timeController.text = _formatTime(pickedTime);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: locationController,
                            decoration: const InputDecoration(
                              labelText: 'Konum (İsteğe Bağlı)',
                              labelStyle: TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Color(0xFF0A0E17),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.map, color: Color(0xFF2196F3)),
                          tooltip: 'Haritadan Seç',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddressPickerDialog(
                                initialAddress: locationController.text,
                                onAddressSelected: (address, latitude, longitude) {
                                  setState(() {
                                    locationController.text = address;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: registrationFormLinkController,
                      decoration: const InputDecoration(
                        labelText: 'Katılım Formu Linki (İsteğe Bağlı)',
                        hintText: 'https://forms.google.com/...',
                        labelStyle: TextStyle(color: Colors.white70),
                        hintStyle: TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: participantsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Katılımcı Sayısı',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
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
                    const SizedBox(height: 24),
                    const Text(
                      'Fotoğraflar (En fazla 5 adet)',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Existing images
                    if (existingImageUrls.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: existingImageUrls.map((url) {
                          final isMarkedForDelete = imageUrlsToDelete.contains(url);
                          return Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isMarkedForDelete
                                        ? Colors.red
                                        : Colors.white54,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFF0A0E17),
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.white54,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isMarkedForDelete) {
                                        imageUrlsToDelete.remove(url);
                                      } else {
                                        imageUrlsToDelete.add(url);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isMarkedForDelete
                                          ? Colors.red
                                          : Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isMarkedForDelete
                                          ? Icons.close
                                          : Icons.delete,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    // Selected files preview
                    if (selectedFiles.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedFiles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final file = entry.value;
                            return Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white54,
                                      width: 2,
                                    ),
                                  ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        fileObjectUrls[file] ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: const Color(0xFF0A0E17),
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.white54,
                                              size: 24,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        final objectUrl = fileObjectUrls[file];
                                        if (objectUrl != null) {
                                          _revokeObjectUrl(objectUrl);
                                          fileObjectUrls.remove(file);
                                        }
                                        selectedFiles.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        if (selectedFiles.length + existingImageUrls.length - imageUrlsToDelete.length >= 5) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('En fazla 5 fotoğraf ekleyebilirsiniz'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: true,
                        ).then((result) {
                          if (result != null && result.files.isNotEmpty) {
                            setState(() {
                              final remainingSlots = 5 - 
                                  (existingImageUrls.length - imageUrlsToDelete.length) - 
                                  selectedFiles.length;
                              final filesToAdd = result.files.length > remainingSlots
                                  ? result.files.sublist(0, remainingSlots)
                                  : result.files;
                              for (final file in filesToAdd) {
                                selectedFiles.add(file);
                                fileObjectUrls[file] = _createObjectUrl(file);
                              }
                            });
                          }
                        });
                      },
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Fotoğraf Ekle'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                    ),
                    if (selectedFiles.length + existingImageUrls.length - imageUrlsToDelete.length > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${selectedFiles.length + existingImageUrls.length - imageUrlsToDelete.length}/5 fotoğraf seçildi',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
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
                  // Show loading dialog
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
                    List<String> finalImageUrls = [];
                    String eventId = event?.id ?? '';
                    
                    // Keep existing images that are not marked for deletion
                    finalImageUrls.addAll(
                      existingImageUrls.where((url) => !imageUrlsToDelete.contains(url)),
                    );
                    
                    // Upload new images if any
                    if (selectedFiles.isNotEmpty) {
                      // Generate temporary event ID for new events
                      eventId = event?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
                      
                      // If editing, use existing ID; if new, we'll get the ID after adding
                      if (!isEditing) {
                        // For new events, we need to add the event first to get an ID
                        // But we can't do that without images. So we'll upload with temp ID
                        // and then update the event with the actual ID
                        final tempEventData = EventData(
                          type: typeController.text,
                          title: titleController.text,
                          date: dateController.text,
                          time: timeController.text,
                          location: locationController.text,
                          participants: int.parse(participantsController.text),
                          colorHex: selectedColor,
                          images: [],
                          registrationFormLink: registrationFormLinkController.text.isNotEmpty 
                              ? registrationFormLinkController.text 
                              : null,
                        );
                        final docRef = await firestoreProvider.addEventAndGetRef(tempEventData);
                        eventId = docRef.id;
                      }
                      
                      final uploadedUrls = await storageService.uploadImagesFromPlatformFiles(selectedFiles, eventId);
                      finalImageUrls.addAll(uploadedUrls);
                      
                      // Delete images marked for deletion
                      if (imageUrlsToDelete.isNotEmpty) {
                        await storageService.deleteImages(imageUrlsToDelete);
                      }
                    } else if (imageUrlsToDelete.isNotEmpty) {
                      // Only deletions, no new uploads
                      await storageService.deleteImages(imageUrlsToDelete);
                    }
                    
                    // Ensure we don't exceed 5 images
                    if (finalImageUrls.length > 5) {
                      finalImageUrls = finalImageUrls.sublist(0, 5);
                    }
                    
                    final eventData = EventData(
                      id: event?.id,
                      type: typeController.text,
                      title: titleController.text,
                      date: dateController.text,
                      time: timeController.text,
                      location: locationController.text,
                      participants: int.parse(participantsController.text),
                      colorHex: selectedColor,
                      images: finalImageUrls,
                      registrationFormLink: registrationFormLinkController.text.isNotEmpty 
                          ? registrationFormLinkController.text 
                          : null,
                    );

                    if (isEditing && event.id != null) {
                      await firestoreProvider.updateEvent(event.id!, eventData);
                    } else if (eventId.isNotEmpty && !isEditing) {
                      // Event was already created for image upload, update it
                      await firestoreProvider.updateEvent(eventId, eventData);
                    } else {
                      // No images, just create the event normally
                      await firestoreProvider.addEvent(eventData);
                    }
                    
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
                      Navigator.pop(context); // Close form dialog
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
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
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

  Future<void> _clearPendingAdmins(BuildContext context) async {
    // Loading dialogu göster
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
      final deletedCount = await firestoreProvider.deleteAllPendingAdmins();
      
      if (!context.mounted) return;
      Navigator.pop(context); // Loading dialogunu kapat
      
      // Başarı dialogu göster
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A2332),
          title: const Text(
            'Başarılı',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            '$deletedCount adet bekleyen onay talebi silindi.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
              ),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Loading dialogunu kapat
      
      // Hata dialogu göster
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A2332),
          title: const Text(
            'Hata',
            style: TextStyle(color: Colors.red),
          ),
          content: Text(
            'Onay talepleri temizlenirken bir hata oluştu: ${e.toString()}',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
              ),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }

  void _showAddAnnouncementDialog(BuildContext context) {
    _showAnnouncementDialog(context);
  }

  void _showEditAnnouncementDialog(BuildContext context, AnnouncementData announcement) {
    _showAnnouncementDialog(context, announcement: announcement);
  }

  void _showAnnouncementDialog(BuildContext context, {AnnouncementData? announcement}) {
    final isEditing = announcement != null;
    final formKey = GlobalKey<FormState>();
    final storageService = StorageService();
    
    final eventNameController = TextEditingController(text: announcement?.eventName ?? '');
    final dateController = TextEditingController(text: announcement?.date ?? '');
    final addressController = TextEditingController(text: announcement?.address ?? '');
    final descriptionController = TextEditingController(text: announcement?.description ?? '');
    final linkController = TextEditingController(text: announcement?.link ?? '');
    
    String selectedType = announcement?.type ?? 'bölüm';
    final typeOptions = ['bölüm', 'etkinlik', 'topluluk'];
    
    String selectedColor = announcement?.colorHex ?? '#2196F3';
    final colorOptions = ['#2196F3', '#F44336', '#4CAF50', '#FF9800', '#9C27B0'];
    
    // Image state
    PlatformFile? selectedFile;
    String? selectedFileUrl;
    String? existingPosterUrl = announcement?.posterUrl;
    bool deleteExistingPoster = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A2332),
          title: Text(
            isEditing ? 'Duyuru Düzenle' : 'Yeni Duyuru Ekle',
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 600,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Type dropdown
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Duyuru Türü',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      dropdownColor: const Color(0xFF0A0E17),
                      style: const TextStyle(color: Colors.white),
                      items: typeOptions.map((type) {
                        String displayName;
                        switch (type) {
                          case 'bölüm':
                            displayName = 'Bölüm Duyuruları';
                            break;
                          case 'etkinlik':
                            displayName = 'Etkinlik Duyuruları';
                            break;
                          case 'topluluk':
                            displayName = 'Topluluk Duyuruları';
                            break;
                          default:
                            displayName = type;
                        }
                        return DropdownMenuItem(
                          value: type,
                          child: Text(displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                      validator: (value) => value == null ? 'Tür seçiniz' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: eventNameController,
                      decoration: const InputDecoration(
                        labelText: 'Duyuru Adı',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Duyuru adı gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    // Date picker field
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Tarih (Opsiyonel)',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF0A0E17),
                        suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onTap: () async {
                        final initialDate = _parseDate(dateController.text) ?? DateTime.now();
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFF2196F3),
                                  onPrimary: Colors.white,
                                  surface: Color(0xFF1A2332),
                                  onSurface: Colors.white,
                                ),
                                dialogBackgroundColor: const Color(0xFF1A2332),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          dateController.text = _formatDate(pickedDate);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adres (Opsiyonel)',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama (Opsiyonel)',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: linkController,
                      decoration: const InputDecoration(
                        labelText: 'Link (Opsiyonel)',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                        hintText: 'https://example.com',
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                      style: const TextStyle(color: Colors.white),
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
                    const SizedBox(height: 24),
                    const Text(
                      'Afiş (Poster)',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Existing poster
                    if (existingPosterUrl != null && existingPosterUrl.isNotEmpty && !deleteExistingPoster)
                      Stack(
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white54,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                existingPosterUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFF0A0E17),
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.white54,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  deleteExistingPoster = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    // Selected file preview
                    if (selectedFile != null)
                      Stack(
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white54,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: selectedFileUrl != null
                                  ? Image.network(
                                      selectedFileUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.image, color: Colors.white54);
                                      },
                                    )
                                  : const Icon(Icons.image, color: Colors.white54),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedFileUrl != null) {
                                    _revokeObjectUrl(selectedFileUrl!);
                                  }
                                  selectedFile = null;
                                  selectedFileUrl = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: false,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          final file = result.files.first;
                          final fileUrl = _createObjectUrl(file);
                          setState(() {
                            selectedFile = file;
                            selectedFileUrl = fileUrl;
                            deleteExistingPoster = false;
                          });
                        }
                      },
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Afiş Seç'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
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
                  // Show loading dialog
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
                    String finalPosterUrl = '';
                    String announcementId = announcement?.id ?? '';
                    
                    // Handle poster upload/deletion
                    if (selectedFile != null) {
                      // Upload new poster
                      if (isEditing && announcement.id != null) {
                        // For editing, use existing ID
                        announcementId = announcement.id!;
                        finalPosterUrl = await storageService.uploadAnnouncementPoster(selectedFile!, announcementId);
                      } else {
                        // For new announcement, create temp announcement first to get ID
                        final tempAnnouncement = AnnouncementData(
                          type: selectedType,
                          eventName: eventNameController.text,
                          posterUrl: '',
                          date: dateController.text,
                          address: addressController.text,
                          description: descriptionController.text.isEmpty ? null : descriptionController.text,
                          link: linkController.text.isEmpty ? null : linkController.text,
                          colorHex: selectedColor,
                        );
                        final docRef = await firestoreProvider.addAnnouncementAndGetRef(tempAnnouncement);
                        announcementId = docRef.id;
                        // Upload poster with the new ID
                        finalPosterUrl = await storageService.uploadAnnouncementPoster(selectedFile!, announcementId);
                      }
                    } else if (deleteExistingPoster && existingPosterUrl != null && existingPosterUrl.isNotEmpty) {
                      // Delete existing poster
                      await storageService.deleteImages([existingPosterUrl]);
                      finalPosterUrl = '';
                    } else {
                      // Keep existing poster
                      finalPosterUrl = existingPosterUrl ?? '';
                    }
                    
                    final announcementData = AnnouncementData(
                      id: announcement?.id,
                      type: selectedType,
                      eventName: eventNameController.text,
                      posterUrl: finalPosterUrl,
                      date: dateController.text,
                      address: addressController.text,
                      description: descriptionController.text.isEmpty ? null : descriptionController.text,
                      link: linkController.text.isEmpty ? null : linkController.text,
                      colorHex: selectedColor,
                    );

                    if (isEditing && announcement.id != null) {
                      await firestoreProvider.updateAnnouncement(announcement.id!, announcementData);
                    } else {
                      if (selectedFile != null && announcementId.isNotEmpty) {
                        // Update the temp announcement with the poster URL
                        await firestoreProvider.updateAnnouncement(announcementId, announcementData);
                      } else {
                        // No poster, just add the announcement
                        await firestoreProvider.addAnnouncement(announcementData);
                      }
                    }
                    
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
                      Navigator.pop(context); // Close form dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Duyuru güncellendi'
                                : 'Duyuru eklendi',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
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

  Future<void> _deleteAnnouncement(String announcementId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        title: const Text(
          'Duyuruyu Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bu duyuruyu silmek istediğinizden emin misiniz?',
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
        final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
        await firestoreProvider.deleteAnnouncement(announcementId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Duyuru silindi'),
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

  void _showAddAboutSectionDialog(BuildContext context) {
    _showAboutSectionDialog(context);
  }

  void _showEditAboutSectionDialog(BuildContext context, AboutSectionData section) {
    _showAboutSectionDialog(context, section: section);
  }

  void _showAboutSectionDialog(BuildContext context, {AboutSectionData? section}) {
    final isEditing = section != null;
    final sectionId = section?.id;
    final formKey = GlobalKey<FormState>();
    
    final titleController = TextEditingController(text: section?.title ?? '');
    final subtitleController = TextEditingController(text: section?.subtitle ?? '');
    final descriptionController = TextEditingController(text: section?.description ?? '');
    
    bool visible = section?.visible ?? true;
    bool isImageRight = section?.isImageRight ?? true;
    PlatformFile? selectedFile;
    String? selectedFileUrl;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A2332),
          title: Text(
            isEditing ? 'Bölüm Düzenle' : 'Yeni Bölüm Ekle',
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 600,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Başlık',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Başlık gerekli';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Alt Başlık',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Alt başlık gerekli';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Açıklama gerekli';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Görsel seçimi
                    Builder(
                      builder: (context) {
                        // ignore: unnecessary_null_comparison, unnecessary_nullable_for_final_variable_declarations, unnecessary_non_null_assertion
                        final imageToShow = selectedFileUrl ?? (isEditing && section != null ? section!.imageUrl ?? '' : '');
                        if (imageToShow.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageToShow,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(Icons.error, color: Colors.red),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: false,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          final file = result.files.first;
                          final fileUrl = _createObjectUrl(file);
                          setState(() {
                            selectedFile = file;
                            selectedFileUrl = fileUrl;
                          });
                        }
                      },
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Fotoğraf Seç'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                    ),
                    if (selectedFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Seçilen: ${selectedFile!.name}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Görsel konumu
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isImageRight = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: !isImageRight ? const Color(0xFF2196F3) : const Color(0xFF0A0E17),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: !isImageRight ? const Color(0xFF2196F3) : Colors.white54,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.arrow_back, color: Colors.white),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Görsel Solda',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isImageRight = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: isImageRight ? const Color(0xFF2196F3) : const Color(0xFF0A0E17),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isImageRight ? const Color(0xFF2196F3) : Colors.white54,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Görsel Sağda',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Switch(
                          value: visible,
                          onChanged: (value) {
                            setState(() {
                              visible = value;
                            });
                          },
                          activeColor: const Color(0xFF2196F3),
                        ),
                        const Text(
                          'Görünür',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
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
                  // Show loading dialog
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
                    final storageService = StorageService();
                    
                    String? imageUrl = section?.imageUrl;
                    
                    // Yeni görsel seçildiyse yükle
                    if (selectedFile != null) {
                      if (isEditing && sectionId != null) {
                        // Düzenleme modunda: görseli yükle ve URL'yi al
                        imageUrl = await storageService.uploadAboutSectionImage(selectedFile!, sectionId);
                      } else {
                        // Yeni bölüm: önce bölümü ekle, sonra görseli yükle
                        final tempSectionData = AboutSectionData(
                          title: titleController.text.trim(),
                          subtitle: subtitleController.text.trim(),
                          description: descriptionController.text.trim(),
                          imageUrl: '', // Geçici olarak boş
                          isImageRight: isImageRight,
                          accentColor: '#2196F3', // Varsayılan renk
                          order: 0, // Varsayılan sıralama
                          visible: visible,
                        );
                        final docRef = await firestoreProvider.addAboutSectionAndGetRef(tempSectionData);
                        imageUrl = await storageService.uploadAboutSectionImage(selectedFile!, docRef.id);
                        
                        // Görsel URL'si ile bölümü güncelle
                        final finalSectionData = tempSectionData.copyWith(
                          id: docRef.id,
                          imageUrl: imageUrl,
                        );
                        await firestoreProvider.updateAboutSection(docRef.id, finalSectionData);
                        
                        if (context.mounted) {
                          Navigator.pop(context); // Close loading dialog
                          Navigator.pop(context); // Close form dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Bölüm eklendi'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                        return;
                      }
                    }
                    
                    // Düzenleme modunda veya görsel seçilmediyse
                    final sectionData = AboutSectionData(
                      id: section?.id,
                      title: titleController.text.trim(),
                      subtitle: subtitleController.text.trim(),
                      description: descriptionController.text.trim(),
                      imageUrl: imageUrl ?? section?.imageUrl ?? '',
                      isImageRight: isImageRight,
                      accentColor: section?.accentColor ?? '#2196F3', // Mevcut veya varsayılan
                      order: section?.order ?? 1, // Mevcut veya varsayılan
                      visible: visible,
                    );

                    if (isEditing && sectionId != null) {
                      await firestoreProvider.updateAboutSection(sectionId, sectionData);
                    } else if (selectedFile == null) {
                      // Görsel seçilmediyse normal ekleme
                      await firestoreProvider.addAboutSection(sectionData);
                    }
                    
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
                      Navigator.pop(context); // Close form dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Bölüm güncellendi'
                                : 'Bölüm eklendi',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
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

  Future<void> _deleteAboutSection(String sectionId) async {
    try {
      final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
      await firestoreProvider.deleteAboutSection(sectionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bölüm silindi'),
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

  // Home Section Methods
  void _showAddHomeSectionDialog(BuildContext context) {
    _showHomeSectionDialog(context);
  }

  void _showEditHomeSectionDialog(BuildContext context, HomeSectionData section) {
    _showHomeSectionDialog(context, section: section);
  }

  void _showHomeSectionDialog(BuildContext context, {HomeSectionData? section}) {
    final isEditing = section != null;
    final sectionId = section?.id;
    final formKey = GlobalKey<FormState>();
    
    final titleController = TextEditingController(text: section?.title ?? '');
    final descriptionController = TextEditingController(text: section?.description ?? '');
    final orderController = TextEditingController(text: (section?.order ?? 1).toString());
    
    String sectionType = section?.type ?? 'both';
    bool visible = section?.visible ?? true;
    List<String> imageUrls = List<String>.from(section?.images ?? []);
    List<PlatformFile>? selectedFiles;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A2332),
          title: Text(
            isEditing ? 'Bölüm Düzenle' : 'Yeni Bölüm Ekle',
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 600,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Section Type Selection
                    const Text(
                      'Bölüm Tipi',
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Yalnızca Görsel', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            value: 'imageOnly',
                            groupValue: sectionType,
                            onChanged: (value) {
                              setDialogState(() {
                                sectionType = value!;
                              });
                            },
                            activeColor: const Color(0xFF2196F3),
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Yalnızca Yazı', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            value: 'textOnly',
                            groupValue: sectionType,
                            onChanged: (value) {
                              setDialogState(() {
                                sectionType = value!;
                              });
                            },
                            activeColor: const Color(0xFF2196F3),
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Hem Görsel Hem Yazı', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            value: 'both',
                            groupValue: sectionType,
                            onChanged: (value) {
                              setDialogState(() {
                                sectionType = value!;
                              });
                            },
                            activeColor: const Color(0xFF2196F3),
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Title (if not imageOnly)
                    if (sectionType != 'imageOnly')
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Başlık (Opsiyonel)',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Color(0xFF0A0E17),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    if (sectionType != 'imageOnly') const SizedBox(height: 16),
                    // Description (if not imageOnly)
                    if (sectionType != 'imageOnly')
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Açıklama (Opsiyonel)',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Color(0xFF0A0E17),
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLines: 5,
                      ),
                    if (sectionType != 'imageOnly') const SizedBox(height: 16),
                    // Images (if not textOnly)
                    if (sectionType != 'textOnly') ...[
                      const Text(
                        'Görseller',
                        style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Image URLs
                      if (imageUrls.isNotEmpty)
                        ...imageUrls.asMap().entries.map((entry) {
                          final index = entry.key;
                          final url = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0E17),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    url,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () {
                                    setDialogState(() {
                                      imageUrls.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      // Add image URL button
                      ElevatedButton.icon(
                        onPressed: () {
                          final urlController = TextEditingController();
                          showDialog(
                            context: context,
                            builder: (urlContext) => AlertDialog(
                              backgroundColor: const Color(0xFF1A2332),
                              title: const Text('Görsel URL Ekle', style: TextStyle(color: Colors.white)),
                              content: TextField(
                                controller: urlController,
                                decoration: const InputDecoration(
                                  labelText: 'Görsel URL',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: Color(0xFF0A0E17),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(urlContext),
                                  child: const Text('İptal', style: TextStyle(color: Colors.white70)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (urlController.text.trim().isNotEmpty) {
                                      setDialogState(() {
                                        imageUrls.add(urlController.text.trim());
                                      });
                                      Navigator.pop(urlContext);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2196F3),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Ekle'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.link, size: 18),
                        label: const Text('URL Ekle', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Upload images button
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                              allowMultiple: true,
                            );
                            if (result != null && result.files.isNotEmpty) {
                              setDialogState(() {
                                selectedFiles = result.files;
                              });
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Dosya seçme hatası: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text('Görsel Yükle', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      if (selectedFiles != null && selectedFiles!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${selectedFiles!.length} dosya seçildi',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                    // Order
                    TextFormField(
                      controller: orderController,
                      decoration: const InputDecoration(
                        labelText: 'Sıralama',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                        hintText: '0',
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Sıralama gerekli';
                        if (int.tryParse(value) == null) return 'Geçerli bir sayı giriniz';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Visible switch
                    Row(
                      children: [
                        Switch(
                          value: visible,
                          onChanged: (value) {
                            setDialogState(() {
                              visible = value;
                            });
                          },
                          activeColor: const Color(0xFF2196F3),
                        ),
                        const Text(
                          'Görünür',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
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
                  // Validate based on section type
                  if (sectionType == 'imageOnly' && imageUrls.isEmpty && (selectedFiles == null || selectedFiles!.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Yalnızca görsel tipi için en az bir görsel gereklidir'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (sectionType == 'textOnly' && titleController.text.trim().isEmpty && descriptionController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Yalnızca yazı tipi için başlık veya açıklama gereklidir'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Show loading dialog
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
                    final storageService = StorageService();
                    
                    // Upload selected files if any
                    List<String> finalImageUrls = List<String>.from(imageUrls);
                    if (selectedFiles != null && selectedFiles!.isNotEmpty) {
                      // Generate a unique ID for this section
                      final tempId = sectionId ?? DateTime.now().millisecondsSinceEpoch.toString();
                      final uploadedUrls = await storageService.uploadHomeSectionImages(
                        selectedFiles!,
                        tempId,
                      );
                      finalImageUrls.addAll(uploadedUrls);
                    }
                    
                    final sectionData = HomeSectionData(
                      id: section?.id,
                      title: sectionType == 'imageOnly' ? null : (titleController.text.trim().isEmpty ? null : titleController.text.trim()),
                      description: sectionType == 'imageOnly' ? null : (descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim()),
                      images: finalImageUrls,
                      order: int.parse(orderController.text),
                      visible: visible,
                      type: sectionType,
                    );

                    if (isEditing && sectionId != null) {
                      await firestoreProvider.updateHomeSection(sectionId, sectionData);
                    } else {
                      await firestoreProvider.addHomeSection(sectionData);
                    }
                    
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
                      Navigator.pop(context); // Close form dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Bölüm güncellendi'
                                : 'Bölüm eklendi',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
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

  Future<void> _deleteHomeSection(String sectionId) async {
    try {
      final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
      await firestoreProvider.deleteHomeSection(sectionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bölüm silindi'),
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

  Widget _buildTeamsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showAddTeamDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Yeni Ekip Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showTeamMemberDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Ekip Üyesi Ekle (Ekip Olmadan)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
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
        const SizedBox(height: 20),
        Consumer<FirestoreProvider>(
          builder: (context, firestoreProvider, _) => StreamBuilder<List<TeamData>>(
            stream: firestoreProvider.getTeams(),
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
                    'Henüz ekip eklenmemiş.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              final teams = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: teams.map((team) {
                  return _AdminTeamCard(
                    team: team,
                    onEdit: () => _showEditTeamDialog(context, team),
                    onDelete: () => _deleteTeam(team.id!),
                    onAddMember: () => _showAddTeamMemberDialog(context, team.id!),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSponsorsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showAddSponsorDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Yeni Sponsor Ekle'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Consumer<FirestoreProvider>(
          builder: (context, firestoreProvider, _) => StreamBuilder<List<SponsorData>>(
            stream: firestoreProvider.getSponsors(),
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
                    'Henüz sponsor eklenmemiş.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              final sponsors = snapshot.data!;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.65,
                ),
                itemCount: sponsors.length,
                itemBuilder: (context, index) {
                  return SponsorCard(
                    sponsor: sponsors[index],
                    isAdmin: true,
                    onEdit: () => _showEditSponsorDialog(context, sponsors[index]),
                    onDelete: () => _deleteSponsor(sponsors[index].id!),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddSponsorDialog(BuildContext context) {
    _showSponsorDialog(context);
  }

  void _showEditSponsorDialog(BuildContext context, SponsorData sponsor) {
    _showSponsorDialog(context, sponsor: sponsor);
  }

  void _showSponsorDialog(BuildContext context, {SponsorData? sponsor}) {
    final isEditing = sponsor != null;
    final formKey = GlobalKey<FormState>();
    final storageService = StorageService();
    
    final nameController = TextEditingController(text: sponsor?.name ?? '');
    final descriptionController = TextEditingController(text: sponsor?.description ?? '');
    final websiteUrlController = TextEditingController(text: sponsor?.websiteUrl ?? '');
    final addressController = TextEditingController(text: sponsor?.address ?? '');
    
    // Logo state
    html.File? selectedFile;
    String? existingLogoUrl = sponsor?.logoUrl;
    bool deleteExistingLogo = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A2332),
          title: Text(
            isEditing ? 'Sponsor Düzenle' : 'Yeni Sponsor Ekle',
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 600,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Sponsor Adı',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Sponsor adı gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama (Opsiyonel)',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: websiteUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Web Sitesi URL (Opsiyonel)',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: addressController,
                            decoration: const InputDecoration(
                              labelText: 'Adres (Opsiyonel - Haritada gösterilecek)',
                              labelStyle: TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Color(0xFF0A0E17),
                              hintText: 'Örn: Bandırma, Balıkesir',
                              hintStyle: TextStyle(color: Colors.white38),
                            ),
                            style: const TextStyle(color: Colors.white),
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: IconButton(
                            icon: const Icon(Icons.map, color: Color(0xFF2196F3)),
                            tooltip: 'Haritadan Seç',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddressPickerDialog(
                                  initialAddress: addressController.text,
                                  onAddressSelected: (address, latitude, longitude) {
                                    setState(() {
                                      addressController.text = address;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Logo',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Existing logo
                    if (existingLogoUrl != null && existingLogoUrl.isNotEmpty && !deleteExistingLogo)
                      Stack(
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                existingLogoUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error, color: Colors.red);
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  deleteExistingLogo = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    // File picker
                    if (selectedFile == null && (existingLogoUrl == null || existingLogoUrl.isEmpty || deleteExistingLogo))
                      ElevatedButton.icon(
                        onPressed: () async {
                          final input = html.FileUploadInputElement()
                            ..accept = 'image/*'
                            ..multiple = false;
                          input.click();
                          input.onChange.listen((e) {
                            final files = input.files;
                            if (files != null && files.isNotEmpty) {
                              setState(() {
                                selectedFile = files[0];
                              });
                            }
                          });
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Logo Yükle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    // Selected file preview
                    if (selectedFile != null)
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Seçilen dosya: ${selectedFile!.name}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedFile = null;
                              });
                            },
                            child: const Text('Dosyayı Kaldır'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
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
                  try {
                    String logoUrl = existingLogoUrl ?? '';
                    
                    // Upload new logo if selected
                    if (selectedFile != null) {
                      final sponsorId = sponsor?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
                      logoUrl = await storageService.uploadSponsorLogo(
                        selectedFile!,
                        sponsorId,
                      );
                    }
                    
                    // If existing logo was deleted and no new file selected
                    if (deleteExistingLogo && selectedFile == null) {
                      logoUrl = '';
                    }
                    
                    final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
                    final sponsorData = SponsorData(
                      id: sponsor?.id,
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                      logoUrl: logoUrl,
                      websiteUrl: websiteUrlController.text.trim().isEmpty
                          ? null
                          : websiteUrlController.text.trim(),
                      address: addressController.text.trim().isEmpty
                          ? null
                          : addressController.text.trim(),
                    );
                    
                    if (isEditing && sponsor.id != null) {
                      await firestoreProvider.updateSponsor(sponsor.id!, sponsorData);
                    } else {
                      await firestoreProvider.addSponsor(sponsorData);
                    }
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Sponsor güncellendi'
                                : 'Sponsor eklendi',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
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

  Future<void> _deleteSponsor(String sponsorId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        title: const Text(
          'Sponsoru Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bu sponsoru silmek istediğinizden emin misiniz?',
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
        final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
        await firestoreProvider.deleteSponsor(sponsorId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sponsor silindi'),
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

  void _showAddTeamDialog(BuildContext context) {
    _showTeamDialog(context);
  }

  void _showEditTeamDialog(BuildContext context, TeamData team) {
    _showTeamDialog(context, team: team);
  }

  void _showTeamDialog(BuildContext context, {TeamData? team}) {
    final isEditing = team != null;
    final formKey = GlobalKey<FormState>();
    
    final nameController = TextEditingController(text: team?.name ?? '');
    final descriptionController = TextEditingController(text: team?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        title: Text(
          isEditing ? 'Ekip Düzenle' : 'Yeni Ekip Ekle',
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
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ekip Adı',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Color(0xFF0A0E17),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Ekip adı gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama (Opsiyonel)',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Color(0xFF0A0E17),
                    ),
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
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
                try {
                  final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
                  final teamData = TeamData(
                    id: team?.id,
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isEmpty 
                        ? null 
                        : descriptionController.text.trim(),
                  );

                  if (isEditing && team.id != null) {
                    await firestoreProvider.updateTeam(team.id!, teamData);
                  } else {
                    await firestoreProvider.addTeam(teamData);
                  }
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? 'Ekip güncellendi'
                              : 'Ekip eklendi',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    final errorMessage = e.toString();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ekip eklenirken bir hata oluştu',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              errorMessage,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                        action: SnackBarAction(
                          label: 'Tamam',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
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
    );
  }

  void _showAddTeamMemberDialog(BuildContext context, String teamId) {
    _showTeamMemberDialog(context, teamId: teamId);
  }

  void _showEditTeamMemberDialog(BuildContext context, TeamMemberData member) {
    _showTeamMemberDialog(context, member: member);
  }

  void _showTeamMemberDialog(BuildContext context, {String? teamId, TeamMemberData? member}) {
    final isEditing = member != null;
    final formKey = GlobalKey<FormState>();
    final storageService = StorageService();
    
    final nameController = TextEditingController(text: member?.name ?? '');
    final departmentController = TextEditingController(text: member?.department ?? '');
    final classNameController = TextEditingController(text: member?.className ?? '');
    final titleController = TextEditingController(text: member?.title ?? '');

    // Image state
    html.File? selectedFile;
    String? existingPhotoUrl = member?.photoUrl;
    bool deleteExistingPhoto = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A2332),
          title: Text(
            isEditing ? 'Ekip Üyesi Düzenle' : 'Yeni Ekip Üyesi Ekle',
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 600,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'İsim',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'İsim gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: departmentController,
                      decoration: const InputDecoration(
                        labelText: 'Bölüm',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Bölüm gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: classNameController,
                      decoration: const InputDecoration(
                        labelText: 'Sınıf (Opsiyonel)',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Ünvan',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A0E17),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Ünvan gerekli' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Fotoğraf',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Existing photo
                    if (existingPhotoUrl != null && existingPhotoUrl.isNotEmpty && !deleteExistingPhoto)
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                existingPhotoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error, color: Colors.red);
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  deleteExistingPhoto = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    // New photo selection
                    if (selectedFile == null && (existingPhotoUrl == null || existingPhotoUrl.isEmpty || deleteExistingPhoto))
                      ElevatedButton.icon(
                        onPressed: () async {
                          final input = html.FileUploadInputElement();
                          input.accept = 'image/*';
                          input.click();
                          
                          input.onChange.listen((e) {
                            final files = input.files;
                            if (files != null && files.isNotEmpty) {
                              setState(() {
                                selectedFile = files[0];
                              });
                            }
                          });
                        },
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Fotoğraf Seç'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (selectedFile != null)
                      Column(
                        children: [
                          Text(
                            selectedFile!.name,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedFile = null;
                              });
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Kaldır'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
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
                  // Show loading dialog
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    
                    // Check authentication before upload
                    final currentUser = authProvider.user;
                    print('🔐 Authentication kontrolü: ${currentUser != null ? "Authenticated (${currentUser.email})" : "NOT AUTHENTICATED"}');
                    
                    if (currentUser == null) {
                      throw Exception('Fotoğraf yüklemek için giriş yapmanız gerekiyor. Lütfen çıkış yapıp tekrar giriş yapın.');
                    }
                    
                    String? finalPhotoUrl;
                    String memberId = member?.id ?? '';
                    
                    // Handle photo upload/deletion
                    if (selectedFile != null) {
                      try {
                        // Upload new photo
                        memberId = member?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
                        if (!isEditing) {
                          final tempMember = TeamMemberData(
                            teamId: teamId,
                            name: nameController.text,
                            department: departmentController.text,
                            className: classNameController.text.isEmpty ? null : classNameController.text,
                            title: titleController.text,
                            photoUrl: '',
                          );
                          final docRef = await firestoreProvider.addTeamMemberAndGetRef(tempMember);
                          memberId = docRef.id;
                        }
                        print('📤 Fotoğraf yükleniyor... memberId: $memberId');
                        finalPhotoUrl = await storageService.uploadTeamMemberPhoto(selectedFile!, memberId);
                        print('✅ Fotoğraf yüklendi. URL: $finalPhotoUrl');
                        
                        if (finalPhotoUrl.isEmpty) {
                          throw Exception('Fotoğraf URL\'si alınamadı');
                        }
                      } catch (uploadError) {
                        print('❌ Fotoğraf yükleme hatası: $uploadError');
                        if (context.mounted) {
                          Navigator.pop(context); // Close loading dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Fotoğraf yüklenirken bir hata oluştu',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    uploadError.toString(),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
                              action: SnackBarAction(
                                label: 'Tamam',
                                textColor: Colors.white,
                                onPressed: () {},
                              ),
                            ),
                          );
                        }
                        return; // Stop execution if upload fails
                      }
                    } else if (deleteExistingPhoto && existingPhotoUrl != null && existingPhotoUrl.isNotEmpty) {
                      // Delete existing photo
                      await storageService.deleteImage(existingPhotoUrl);
                      finalPhotoUrl = '';
                    } else {
                      // Keep existing photo
                      finalPhotoUrl = existingPhotoUrl ?? '';
                    }
                    
                    print('💾 Ekip üyesi kaydediliyor... photoUrl: $finalPhotoUrl');
                    final memberData = TeamMemberData(
                      id: member?.id,
                      teamId: teamId ?? member?.teamId,
                      name: nameController.text.trim(),
                      department: departmentController.text.trim(),
                      className: classNameController.text.trim().isEmpty 
                          ? null 
                          : classNameController.text.trim(),
                      title: titleController.text.trim(),
                      photoUrl: finalPhotoUrl,
                    );

                    if (isEditing && member.id != null) {
                      await firestoreProvider.updateTeamMember(member.id!, memberData);
                    } else {
                      if (!isEditing && selectedFile != null && memberId.isNotEmpty) {
                        await firestoreProvider.updateTeamMember(memberId, memberData);
                      } else {
                        await firestoreProvider.addTeamMember(memberData);
                      }
                    }
                    print('✅ Ekip üyesi başarıyla kaydedildi');
                    
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
                      Navigator.pop(context); // Close form dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Ekip üyesi güncellendi'
                                : 'Ekip üyesi eklendi',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
                      final errorMessage = e.toString();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing
                                    ? 'Ekip üyesi güncellenirken bir hata oluştu'
                                    : 'Ekip üyesi eklenirken bir hata oluştu',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                errorMessage,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 5),
                          action: SnackBarAction(
                            label: 'Tamam',
                            textColor: Colors.white,
                            onPressed: () {},
                          ),
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

  Future<void> _deleteTeam(String teamId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        title: const Text(
          'Ekip Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bu ekibi silmek istediğinizden emin misiniz? Ekip üyeleri de silinecektir.',
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
        final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
        await firestoreProvider.deleteTeam(teamId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ekip silindi'),
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

  Future<void> _deleteTeamMember(String memberId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        title: const Text(
          'Ekip Üyesi Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bu ekip üyesini silmek istediğinizden emin misiniz?',
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
        final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
        await firestoreProvider.deleteTeamMember(memberId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ekip üyesi silindi'),
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
        final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
        await firestoreProvider.deleteEvent(eventId);
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
    final isMobile = SizeHelper.isMobile(context);
    final isTablet = SizeHelper.isTablet(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 24 : 40),
        vertical: isMobile ? 12 : (isTablet ? 16 : 20),
      ),
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
          Consumer<FirestoreProvider>(
            builder: (context, firestoreProvider, _) => StreamBuilder<Map<String, dynamic>>(
              stream: firestoreProvider.getSiteSettingsStream(),
              builder: (context, snapshot) {
                final logoUrl = snapshot.data?['logoUrl'] ?? '';
                final logoSize = SizeHelper.isMobile(context) ? 50.0 : (SizeHelper.isTablet(context) ? 60.0 : 70.0);
                
                return Container(
                  padding: EdgeInsets.all(SizeHelper.isMobile(context) ? 6 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularLogoWidget(
                        size: logoSize,
                        padding: SizeHelper.isMobile(context) ? 4.0 : 6.0,
                        logoUrl: logoUrl.isNotEmpty ? logoUrl : null,
                      ),
                      SizedBox(width: SizeHelper.isMobile(context) ? 6 : 10),
                      Text(
                        'BMT',
                        style: TextStyle(
                          color: const Color(0xFF0A0E17),
                          fontSize: SizeHelper.clampFontSize(
                            MediaQuery.of(context).size.width,
                            14,
                            18,
                            20,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            icon: Icon(
              Icons.home,
              size: isMobile ? 18 : 20,
            ),
            label: Text(
              isMobile ? 'Ana Sayfa' : 'Ana Sayfaya Dön',
              style: TextStyle(
                fontSize: SizeHelper.clampFontSize(
                  MediaQuery.of(context).size.width,
                  12,
                  14,
                  16,
                ),
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 16,
                vertical: isMobile ? 8 : 12,
              ),
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

  void _showImageGallery(BuildContext context, int initialIndex) {
    if (event.images.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => _ImageGalleryDialog(
        images: event.images,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = event.images.isNotEmpty;
    final firstImage = hasImage ? event.images.first : null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: event.color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
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
          ),
          // Image section
          if (hasImage && firstImage != null)
            GestureDetector(
              onTap: () => _showImageGallery(context, 0),
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        firstImage,
                        width: 120,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            color: const Color(0xFF0A0E17),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (event.images.length > 1)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.photo_library,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${event.images.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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

class _ImageGalleryDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImageGalleryDialog({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ImageGalleryDialog> createState() => _ImageGalleryDialogState();
}

class _ImageGalleryDialogState extends State<_ImageGalleryDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Image viewer
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: widget.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 3.0,
                          child: Image.network(
                            widget.images[index],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF0A0E17),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.white54,
                                    size: 64,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  // Sol ok butonu (çoklu görsel varsa)
                  if (widget.images.length > 1)
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final previousIndex = (_currentIndex - 1 + widget.images.length) % widget.images.length;
                              _pageController.animateToPage(
                                previousIndex,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Sağ ok butonu (çoklu görsel varsa)
                  if (widget.images.length > 1)
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final nextIndex = (_currentIndex + 1) % widget.images.length;
                              _pageController.animateToPage(
                                nextIndex,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _currentIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  // Thumbnail strip
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: widget.images.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _currentIndex;
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2196F3)
                                    : Colors.white54,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                widget.images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFF0A0E17),
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.white54,
                                      size: 24,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: _currentIndex < widget.images.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
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

class _AdminTeamCard extends StatelessWidget {
  final TeamData team;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddMember;

  const _AdminTeamCard({
    required this.team,
    required this.onEdit,
    required this.onDelete,
    required this.onAddMember,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (team.description != null && team.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          team.description!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: onAddMember,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Üye Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Düzenle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Sil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Consumer<FirestoreProvider>(
              builder: (context, firestoreProvider, _) {
                return StreamBuilder<List<TeamMemberData>>(
                  stream: firestoreProvider.getTeamMembers(team.id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Hata: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Bu ekipte henüz üye yok.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }

                    final members = snapshot.data!;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        return TeamMemberCard(
                          member: members[index],
                          isAdmin: true,
                          onEdit: () {
                            final adminState = context.findAncestorStateOfType<_AdminPanelPageState>();
                            adminState?._showEditTeamMemberDialog(context, members[index]);
                          },
                          onDelete: () {
                            final adminState = context.findAncestorStateOfType<_AdminPanelPageState>();
                            adminState?._deleteTeamMember(members[index].id!);
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTeamMemberCard extends StatefulWidget {
  final TeamMemberData member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminTeamMemberCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_AdminTeamMemberCard> createState() => _AdminTeamMemberCardState();
}

class _AdminTeamMemberCardState extends State<_AdminTeamMemberCard> {
  static final Set<String> _registeredViewIds = <String>{};

  Widget _buildPhoto() {
    final photoUrl = widget.member.photoUrl;
    print('🖼️ Admin Panel - Fotoğraf gösteriliyor - member: ${widget.member.name}, photoUrl: $photoUrl');
    
    if (photoUrl != null && photoUrl.isNotEmpty) {
      // URL'i normalize et
      String normalizedUrl = photoUrl;
      try {
        // URL'i parse et ve tekrar oluştur (encoding sorunlarını çözer)
        final uri = Uri.parse(photoUrl);
        normalizedUrl = uri.toString();
        print('🔄 Admin Panel - Normalized URL: $normalizedUrl');
      } catch (e) {
        print('⚠️ Admin Panel - URL parse hatası: $e, orijinal URL kullanılıyor');
      }
      
      // Flutter web'de CORS sorununu çözmek için HTML img elementi kullan
      if (kIsWeb) {
        // Unique ID oluştur - member.id ve photoUrl hash'i kullan
        final imageId = 'admin_img_${widget.member.id ?? 'unknown'}_${normalizedUrl.hashCode}';
        
        // View factory'yi sadece bir kez kaydet
        if (!_registeredViewIds.contains(imageId)) {
          // HTML img elementi oluştur
          final imgElement = html.ImageElement()
            ..src = normalizedUrl
            ..style.width = '80px'
            ..style.height = '80px'
            ..style.objectFit = 'cover'
            ..style.borderRadius = '8px'
            ..crossOrigin = 'anonymous'
            ..onError.listen((_) {
              print('❌ Admin Panel - HTML img yükleme hatası: $normalizedUrl');
            })
            ..onLoad.listen((_) {
              print('✅ Admin Panel - HTML img yüklendi: $normalizedUrl');
            });
          
          try {
            // Platform view registry'ye kaydet
            ui_web.platformViewRegistry.registerViewFactory(
              imageId,
              (int viewId) => imgElement,
            );
            _registeredViewIds.add(imageId);
            print('📝 Admin Panel - View factory kaydedildi: $imageId');
          } catch (e) {
            print('⚠️ Admin Panel - View factory kayıt hatası: $e');
          }
        }
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 80,
            height: 80,
            child: HtmlElementView(viewType: imageId),
          ),
        );
      }
      
      // Mobile için normal Image.network kullan
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          normalizedUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              print('✅ Admin Panel - Fotoğraf yüklendi: $normalizedUrl');
              return child;
            }
            return Container(
              width: 80,
              height: 80,
              color: const Color(0xFF2A3441),
              child: Center(
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
            print('❌ Admin Panel - Fotoğraf yükleme hatası: $error');
            return Container(
              width: 80,
              height: 80,
              color: const Color(0xFF2A3441),
              child: const Icon(
                Icons.person,
                color: Colors.white54,
                size: 40,
              ),
            );
          },
        ),
      );
    } else {
      print('⚠️ Admin Panel - Fotoğraf URL yok - member: ${widget.member.name}');
      return Container(
        width: 80,
        height: 80,
        color: const Color(0xFF2A3441),
        child: const Icon(
          Icons.person,
          color: Colors.white54,
          size: 40,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E17),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Fotoğraf
          _buildPhoto(),
          const SizedBox(height: 8),
          // İsim
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.member.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          // Ünvan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.member.title,
              style: const TextStyle(
                color: Color(0xFF2196F3),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          // Bölüm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.member.department,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          // Butonlar
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: const Icon(Icons.edit, size: 14),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: const Icon(Icons.delete, size: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminAnnouncementCard extends StatelessWidget {
  final AnnouncementData announcement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminAnnouncementCard({
    required this.announcement,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildPosterImage(String imageUrl, Color fallbackColor, String? id) {
    if (kIsWeb) {
      // Web için HTML img elementi kullan (CORS sorununu çözer)
      final imageId = 'admin_announcement_img_${id ?? DateTime.now().millisecondsSinceEpoch}';
      
      // HTML img elementi oluştur
      final imgElement = html.ImageElement()
        ..src = imageUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..onError.listen((_) {
          print('❌ Admin Panel - HTML img yükleme hatası: $imageUrl');
        })
        ..onLoad.listen((_) {
          print('✅ Admin Panel - HTML img yüklendi: $imageUrl');
        });
      
      // Platform view registry'ye kaydet
      ui_web.platformViewRegistry.registerViewFactory(
        imageId,
        (int viewId) => imgElement,
      );
      
      return HtmlElementView(viewType: imageId);
    } else {
      // Mobile için normal Image.network kullan
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: fallbackColor.withOpacity(0.2),
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.white54,
                size: 32,
              ),
            ),
          );
        },
      );
    }
  }

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
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              height: 150,
              width: double.infinity,
              color: const Color(0xFF0A0E17),
              child: announcement.posterUrl.isNotEmpty
                  ? _buildPosterImage(
                      announcement.posterUrl,
                      announcement.color,
                      announcement.id,
                    )
                  : Container(
                      color: announcement.color.withOpacity(0.2),
                      child: const Center(
                        child: Icon(
                          Icons.campaign,
                          color: Colors.white54,
                          size: 32,
                        ),
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeHelper.isMobile(context) ? 10 : 12,
                      vertical: SizeHelper.isMobile(context) ? 5 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: announcement.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.campaign,
                          color: announcement.color,
                          size: SizeHelper.isMobile(context) ? 14 : 16,
                        ),
                        SizedBox(width: SizeHelper.isMobile(context) ? 5 : 6),
                        Flexible(
                          child: Text(
                            announcement.type,
                            style: TextStyle(
                              color: announcement.color,
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
                  const SizedBox(height: 8),
                  Text(
                    announcement.eventName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          announcement.date,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onEdit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text('Düzenle', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onDelete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text('Sil', style: TextStyle(fontSize: 11)),
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

class _AdminSponsorCard extends StatelessWidget {
  final SponsorData sponsor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminSponsorCard({
    required this.sponsor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tierNames = {
      'platinum': 'Platin',
      'gold': 'Altın',
      'silver': 'Gümüş',
      'bronze': 'Bronz',
    };

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sponsor.tierColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            child: Container(
              height: 150,
              width: double.infinity,
              color: const Color(0xFF0A0E17),
              child: sponsor.logoUrl.isNotEmpty
                  ? Image.network(
                      sponsor.logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.business,
                            color: sponsor.tierColor,
                            size: 48,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.business,
                        color: sponsor.tierColor,
                        size: 48,
                      ),
                    ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tier badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeHelper.isMobile(context) ? 10 : 12,
                    vertical: SizeHelper.isMobile(context) ? 5 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: sponsor.tierColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: sponsor.tierColor,
                        size: SizeHelper.isMobile(context) ? 14 : 16,
                      ),
                      SizedBox(width: SizeHelper.isMobile(context) ? 5 : 6),
                      Flexible(
                        child: Text(
                          tierNames[sponsor.tier.toLowerCase()] ?? sponsor.tier,
                          style: TextStyle(
                            color: sponsor.tierColor,
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
                const SizedBox(height: 12),
                // Sponsor name
                Text(
                  sponsor.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (sponsor.description != null && sponsor.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    sponsor.description!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (sponsor.websiteUrl != null && sponsor.websiteUrl!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.link, color: Colors.white70, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Web Sitesi',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                        child: const Text('Düzenle', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                        child: const Text('Sil', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _AdminAboutSectionCard extends StatelessWidget {
  final AboutSectionData section;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminAboutSectionCard({
    required this.section,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color accentColor;
    try {
      accentColor = Color(int.parse(section.accentColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      accentColor = const Color(0xFF2196F3);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Image preview
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 120,
                height: 120,
                color: const Color(0xFF0A0E17),
                child: ((section.imageUrl?.isNotEmpty ?? false))
                    ? Image.network(
                        section.imageUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF0A0E17),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.white54,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.image,
                          color: Colors.white54,
                          size: 32,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 20),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.subtitle.toUpperCase(),
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    section.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section.description.length > 100
                        ? '${section.description.substring(0, 100)}...'
                        : section.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              section.accentColor,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        section.isImageRight ? Icons.arrow_forward : Icons.arrow_back,
                        color: Colors.white54,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        section.isImageRight ? 'Görsel Sağda' : 'Görsel Solda',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        section.visible ? Icons.visibility : Icons.visibility_off,
                        color: section.visible ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        section.visible ? 'Görünür' : 'Gizli',
                        style: TextStyle(
                          color: section.visible ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Sıra: ${section.order}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Buttons
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Düzenle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Sil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminHomeSectionCard extends StatefulWidget {
  final HomeSectionData section;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminHomeSectionCard({
    required this.section,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_AdminHomeSectionCard> createState() => _AdminHomeSectionCardState();
}

class _AdminHomeSectionCardState extends State<_AdminHomeSectionCard> {
  PageController? _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.section.images.isNotEmpty) {
      _pageController = PageController();
      // 10 saniyede bir otomatik geçiş
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (mounted && widget.section.images.isNotEmpty && _pageController != null) {
          final nextIndex = (_currentIndex + 1) % widget.section.images.length;
          _pageController!.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'imageOnly':
        return 'Yalnızca Görsel';
      case 'textOnly':
        return 'Yalnızca Yazı';
      case 'both':
        return 'Hem Görsel Hem Yazı';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image slider (if has images)
            if (widget.section.images.isNotEmpty) ...[
              Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF0A0E17),
                ),
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController!,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemCount: widget.section.images.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.section.images[index],
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFF0A0E17),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: const Color(0xFF2196F3),
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF0A0E17),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white54,
                                    size: 64,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    // İndikatörler
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.section.images.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Sol ok butonu (çoklu görsel varsa)
                    if (widget.section.images.length > 1)
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (_pageController != null && widget.section.images.length > 1) {
                                  final previousIndex = (_currentIndex - 1 + widget.section.images.length) % widget.section.images.length;
                                  _pageController!.animateToPage(
                                    previousIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Sağ ok butonu (çoklu görsel varsa)
                    if (widget.section.images.length > 1)
                      Positioned(
                        right: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (_pageController != null && widget.section.images.length > 1) {
                                  final nextIndex = (_currentIndex + 1) % widget.section.images.length;
                                  _pageController!.animateToPage(
                                    nextIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Content
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getTypeDisplayName(widget.section.type),
                          style: const TextStyle(
                            color: Color(0xFF2196F3),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.section.title != null && widget.section.title!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.section.title!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      if (widget.section.description != null && widget.section.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.section.description!.length > 100
                              ? '${widget.section.description!.substring(0, 100)}...'
                              : widget.section.description!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (widget.section.images.isNotEmpty) ...[
                            const Icon(
                              Icons.image,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.section.images.length} görsel',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Icon(
                            widget.section.visible ? Icons.visibility : Icons.visibility_off,
                            color: widget.section.visible ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.section.visible ? 'Görünür' : 'Gizli',
                            style: TextStyle(
                              color: widget.section.visible ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sıra: ${widget.section.order}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Buttons
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Düzenle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Sil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactSettingsEditor extends StatefulWidget {
  final Map<String, dynamic> settings;

  const _ContactSettingsEditor({required this.settings});

  @override
  State<_ContactSettingsEditor> createState() => _ContactSettingsEditorState();
}

class _ContactSettingsEditorState extends State<_ContactSettingsEditor> {
  late TextEditingController _emailController;
  late TextEditingController _instagramController;
  late TextEditingController _tiktokController;
  late TextEditingController _linkedinController;
  late TextEditingController _youtubeController;
  late TextEditingController _whatsappController;
  bool _isSaving = false;

  final List<Map<String, String>> _platformConfigs = const [
    {
      'name': 'Instagram',
      'icon': 'instagram',
      'color': '#E4405F',
    },
    {
      'name': 'TikTok',
      'icon': 'tiktok',
      'color': '#000000',
    },
    {
      'name': 'LinkedIn',
      'icon': 'linkedin',
      'color': '#0077B5',
    },
    {
      'name': 'YouTube',
      'icon': 'youtube',
      'color': '#FF0000',
    },
    {
      'name': 'WhatsApp',
      'icon': 'whatsapp',
      'color': '#25D366',
    },
  ];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: widget.settings['email'] ?? '',
    );
    final socialMediaList = List<Map<String, dynamic>>.from(
      widget.settings['socialMedia'] ?? [],
    );

    _instagramController = TextEditingController(
      text: _findUrl(socialMediaList, 'Instagram'),
    );
    _tiktokController = TextEditingController(
      text: _findUrl(socialMediaList, 'TikTok'),
    );
    _linkedinController = TextEditingController(
      text: _findUrl(socialMediaList, 'LinkedIn'),
    );
    _youtubeController = TextEditingController(
      text: _findUrl(socialMediaList, 'YouTube'),
    );
    _whatsappController = TextEditingController(
      text: _findUrl(socialMediaList, 'WhatsApp'),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _linkedinController.dispose();
    _youtubeController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  String _findUrl(List<Map<String, dynamic>> list, String platformName) {
    for (final item in list) {
      final name = (item['name'] as String? ?? '').toLowerCase();
      if (name == platformName.toLowerCase()) {
        return item['url'] as String? ?? '';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'E-posta Adresi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'E-posta',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF1A2332),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white54),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white54),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sosyal Medya Hesapları',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Instagram, TikTok, LinkedIn, YouTube ve WhatsApp için bağlantıları ekleyin. Boş bıraktıklarınız sitede görünmez.',
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 20),
        ..._platformConfigs.map((platform) {
          final controller = _controllerFor(platform['name']!);
          final icon = _getIconData(platform['icon']!);
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white54.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(int.parse(platform['color']!.replaceFirst('#', '0xFF'))).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Color(int.parse(platform['color']!.replaceFirst('#', '0xFF')))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        platform['name']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: '${platform['name']} linki',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'https://...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF0A0E17),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF2196F3),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Ayarları Kaydet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  TextEditingController _controllerFor(String platformName) {
    switch (platformName) {
      case 'Instagram':
        return _instagramController;
      case 'TikTok':
        return _tiktokController;
      case 'LinkedIn':
        return _linkedinController;
      case 'YouTube':
        return _youtubeController;
      case 'WhatsApp':
        return _whatsappController;
      default:
        return _instagramController;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'instagram':
      case 'camera_alt':
        return Icons.camera_alt;
      case 'tiktok':
      case 'music_note':
        return Icons.music_note;
      case 'linkedin':
      case 'business':
        return Icons.business;
      case 'youtube':
      case 'play_circle_filled':
        return Icons.play_circle_filled;
      case 'whatsapp':
        return Icons.chat;
      case 'link':
        return Icons.link;
      default:
        return Icons.link;
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
      final socialMediaList = _platformConfigs
          .map((platform) {
            final controller = _controllerFor(platform['name']!);
            final url = controller.text.trim();
            if (url.isEmpty) return null;
            return {
              'name': platform['name'],
              'icon': platform['icon'],
              'url': url,
              'color': platform['color'],
            };
          })
          .where((item) => item != null)
          .cast<Map<String, dynamic>>()
          .toList();
      
      print('📱 Sosyal medya listesi kaydediliyor: ${socialMediaList.length} öğe');
      for (var item in socialMediaList) {
        print('  - ${item['name']}: ${item['url']}');
      }
      
      final settingsToSave = {
        'email': _emailController.text.trim(),
        'socialMedia': socialMediaList,
      };
      
      print('💾 Ayarlar kaydediliyor: $settingsToSave');
      
      await firestoreProvider.updateContactSettings(settingsToSave);
      
      print('✅ Ayarlar başarıyla kaydedildi');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ayarlar başarıyla kaydedildi'),
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
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _SiteSettingsEditor extends StatefulWidget {
  final Map<String, dynamic> settings;

  const _SiteSettingsEditor({required this.settings});

  @override
  State<_SiteSettingsEditor> createState() => _SiteSettingsEditorState();
}

class _SiteSettingsEditorState extends State<_SiteSettingsEditor> {
  late TextEditingController _siteNameController;
  late TextEditingController _siteDescriptionController;
  late TextEditingController _aboutDescriptionController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _copyrightController;
  late TextEditingController _memberCountController;
  late TextEditingController _eventCountController;
  late TextEditingController _projectCountController;
  late TextEditingController _workshopCountController;
  bool _memberCountVisible = true;
  bool _eventCountVisible = true;
  bool _projectCountVisible = true;
  bool _workshopCountVisible = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _siteNameController = TextEditingController(
      text: widget.settings['siteName'] ?? '',
    );
    _siteDescriptionController = TextEditingController(
      text: widget.settings['siteDescription'] ?? '',
    );
    _aboutDescriptionController = TextEditingController(
      text: widget.settings['aboutDescription'] ?? 'Teknoloji tutkumuzu akademik bilgiyle birleştiriyor, Bandırma\'dan dünyaya açılan projeler geliştiriyoruz.',
    );
    _emailController = TextEditingController(
      text: widget.settings['email'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.settings['phone'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.settings['address'] ?? '',
    );
    _copyrightController = TextEditingController(
      text: widget.settings['copyright'] ?? '',
    );
    // Statistics controllers - load from statistics document
    _memberCountController = TextEditingController(text: '0');
    _eventCountController = TextEditingController(text: '0');
    _projectCountController = TextEditingController(text: '0');
    _workshopCountController = TextEditingController(text: '0');
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
      final statistics = await firestoreProvider.getStatistics();
      setState(() {
        _memberCountController.text = (statistics['memberCount'] ?? 0).toString();
        _eventCountController.text = (statistics['eventCount'] ?? 0).toString();
        _projectCountController.text = (statistics['projectCount'] ?? 0).toString();
        _workshopCountController.text = (statistics['workshopCount'] ?? 0).toString();
        _memberCountVisible = statistics['memberCountVisible'] ?? true;
        _eventCountVisible = statistics['eventCountVisible'] ?? true;
        _projectCountVisible = statistics['projectCountVisible'] ?? true;
        _workshopCountVisible = statistics['workshopCountVisible'] ?? true;
      });
    } catch (e) {
      print('İstatistikler yüklenirken hata: $e');
    }
  }

  @override
  void dispose() {
    _siteNameController.dispose();
    _siteDescriptionController.dispose();
    _aboutDescriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _copyrightController.dispose();
    _memberCountController.dispose();
    _eventCountController.dispose();
    _projectCountController.dispose();
    _workshopCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Topluluk Logosu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Header\'da BMT yazısının yanında gösterilecek logo',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<FirestoreProvider>(
            builder: (context, firestoreProvider, _) => StreamBuilder<Map<String, dynamic>>(
              stream: firestoreProvider.getSiteSettingsStream(),
              builder: (context, snapshot) {
                final logoUrl = snapshot.data?['logoUrl'] ?? '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (logoUrl.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2332),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white54),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                logoUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.broken_image, color: Colors.white54),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mevcut Logo',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    logoUrl.length > 50 ? '${logoUrl.substring(0, 50)}...' : logoUrl,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 10,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: () => _uploadLogo(context),
                      icon: const Icon(Icons.upload),
                      label: Text(logoUrl.isEmpty ? 'Logo Yükle' : 'Logoyu Değiştir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          const Divider(color: Colors.white24),
          const SizedBox(height: 30),
          const Text(
            'Site Adı',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _siteNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Site Adı',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1A2332),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Site Açıklaması',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _siteDescriptionController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Site Açıklaması',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1A2332),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Hakkımızda Sayfası Açıklaması',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '"Biz Kimiz & Ne Yapıyoruz?" başlığının altında gösterilecek açıklama metni',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aboutDescriptionController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Hakkımızda Açıklaması',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1A2332),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'İletişim Bilgileri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'E-posta',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1A2332),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Telefon',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1A2332),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Adres',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1A2332),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Telif Hakkı',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _copyrightController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Telif Hakkı Metni (örn: © 2025 BMT. Tüm hakları saklıdır.)',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1A2332),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(color: Colors.white24),
          const SizedBox(height: 30),
          const Text(
            'İstatistikler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ana sayfada gösterilecek sayısal veriler',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _memberCountVisible,
                          onChanged: (value) {
                            setState(() {
                              _memberCountVisible = value ?? true;
                            });
                          },
                          activeColor: const Color(0xFF2196F3),
                        ),
                        const Text(
                          'Üye Sayısı',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _memberCountController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Üye Sayısı',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF1A2332),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _eventCountVisible,
                          onChanged: (value) {
                            setState(() {
                              _eventCountVisible = value ?? true;
                            });
                          },
                          activeColor: const Color(0xFFF44336),
                        ),
                        const Text(
                          'Etkinlik Sayısı',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _eventCountController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Etkinlik Sayısı',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF1A2332),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFF44336), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _projectCountVisible,
                          onChanged: (value) {
                            setState(() {
                              _projectCountVisible = value ?? true;
                            });
                          },
                          activeColor: const Color(0xFF4CAF50),
                        ),
                        const Text(
                          'Proje Sayısı',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _projectCountController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Proje Sayısı',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF1A2332),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _workshopCountVisible,
                          onChanged: (value) {
                            setState(() {
                              _workshopCountVisible = value ?? true;
                            });
                          },
                          activeColor: const Color(0xFFFF9800),
                        ),
                        const Text(
                          'Workshop Sayısı',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _workshopCountController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Workshop Sayısı',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF1A2332),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Ayarları Kaydet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadLogo(BuildContext context) async {
    try {
      // Create file input element
      final input = html.FileUploadInputElement();
      input.accept = 'image/*';
      input.click();

      await input.onChange.first;

      if (input.files == null || input.files!.isEmpty) {
        return;
      }

      final file = input.files!.first;

      // Validate file size (max 5MB)
      if (file.size > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dosya boyutu 5MB\'dan küçük olmalıdır'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final storageService = StorageService();
        final logoUrl = await storageService.uploadCommunityLogo(file);

        final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
        await firestoreProvider.updateSiteSettings({
          'logoUrl': logoUrl,
        });

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logo başarıyla yüklendi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logo yükleme hatası: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Logo yükleme hatası: $e');
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
      await firestoreProvider.updateSiteSettings({
        'siteName': _siteNameController.text.trim(),
        'siteDescription': _siteDescriptionController.text.trim(),
        'aboutDescription': _aboutDescriptionController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'copyright': _copyrightController.text.trim(),
      });

      // Save statistics
      await firestoreProvider.updateStatistics({
        'memberCount': int.tryParse(_memberCountController.text.trim()) ?? 0,
        'eventCount': int.tryParse(_eventCountController.text.trim()) ?? 0,
        'projectCount': int.tryParse(_projectCountController.text.trim()) ?? 0,
        'workshopCount': int.tryParse(_workshopCountController.text.trim()) ?? 0,
        'memberCountVisible': _memberCountVisible,
        'eventCountVisible': _eventCountVisible,
        'projectCountVisible': _projectCountVisible,
        'workshopCountVisible': _workshopCountVisible,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Site ayarları başarıyla kaydedildi'),
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
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _AboutDescriptionEditor extends StatefulWidget {
  final String initialDescription;
  final Future<void> Function(String) onSave;

  const _AboutDescriptionEditor({
    required this.initialDescription,
    required this.onSave,
  });

  @override
  State<_AboutDescriptionEditor> createState() => _AboutDescriptionEditorState();
}

class _AboutDescriptionEditorState extends State<_AboutDescriptionEditor> {
  late TextEditingController _descriptionController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.initialDescription);
  }

  @override
  void didUpdateWidget(_AboutDescriptionEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDescription != widget.initialDescription) {
      _descriptionController.text = widget.initialDescription;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    try {
      await widget.onSave(_descriptionController.text.trim());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hakkımızda Açıklaması',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '"Biz Kimiz & Ne Yapıyoruz?" başlığının altında gösterilecek açıklama metni',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Hakkımızda Açıklaması',
              hintText: 'Teknoloji tutkumuzu akademik bilgiyle birleştiriyor...',
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF0A0E17),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Kaydediliyor...' : 'Kaydet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                disabledBackgroundColor: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

