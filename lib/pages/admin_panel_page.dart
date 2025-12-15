import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import '../providers/auth_provider.dart';
import '../providers/firestore_provider.dart';
import '../services/storage_service.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
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
                        'Admin Paneli',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
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
                          const SizedBox(width: 12),
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
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Tab Bar
                  Row(
                    children: [
                      _TabButton(
                        label: 'Etkinlikler',
                        isSelected: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                      const SizedBox(width: 16),
                      _TabButton(
                        label: 'Site Ayarları',
                        isSelected: _selectedTab == 1,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                      const SizedBox(width: 16),
                      _TabButton(
                        label: 'İletişim Ayarları',
                        isSelected: _selectedTab == 2,
                        onTap: () => setState(() => _selectedTab = 2),
                      ),
                      const SizedBox(width: 16),
                      _TabButton(
                        label: 'Duyurular',
                        isSelected: _selectedTab == 3,
                        onTap: () => setState(() => _selectedTab = 3),
                      ),
                      const SizedBox(width: 16),
                      _TabButton(
                        label: 'Ekip',
                        isSelected: _selectedTab == 4,
                        onTap: () => setState(() => _selectedTab = 4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Tab Content
                  if (_selectedTab == 0) _buildEventsTab(),
                  if (_selectedTab == 1) _buildSiteSettingsTab(),
                  if (_selectedTab == 2) _buildContactSettingsTab(),
                  if (_selectedTab == 3) _buildAnnouncementsTab(),
                  if (_selectedTab == 4) _buildTeamsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
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
        ),
      ],
    );
  }

  Widget _buildSiteSettingsTab() {
    return Consumer<FirestoreProvider>(
      builder: (context, firestoreProvider, _) => StreamBuilder<Map<String, dynamic>>(
        stream: firestoreProvider.getSiteSettingsStream(),
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
          return _SiteSettingsEditor(settings: settings);
        },
      ),
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
                  childAspectRatio: 0.7,
                ),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  return _AdminAnnouncementCard(
                    announcement: announcements[index],
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
    
    String selectedColor = event?.colorHex ?? '#2196F3';
    final colorOptions = ['#2196F3', '#F44336', '#4CAF50', '#FF9800', '#9C27B0'];
    
    // Image state
    List<html.File> selectedFiles = [];
    List<String> existingImageUrls = event?.images ?? [];
    List<String> imageUrlsToDelete = [];
    Map<html.File, String> fileObjectUrls = {};

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
                        labelText: 'Etkinlik Adı',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A1929),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Etkinlik adı gerekli' : null,
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
                                        color: const Color(0xFF0A1929),
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
                                            color: const Color(0xFF0A1929),
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
                                          html.Url.revokeObjectUrl(objectUrl);
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
                        final input = html.FileUploadInputElement()
                          ..accept = 'image/*'
                          ..multiple = true;
                        input.click();
                        input.onChange.listen((e) {
                          final files = input.files;
                          if (files != null) {
                            setState(() {
                              final remainingSlots = 5 - 
                                  (existingImageUrls.length - imageUrlsToDelete.length) - 
                                  selectedFiles.length;
                              final filesToAdd = files.length > remainingSlots
                                  ? files.sublist(0, remainingSlots)
                                  : files;
                              for (final file in filesToAdd) {
                                selectedFiles.add(file);
                                fileObjectUrls[file] = html.Url.createObjectUrl(file);
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
                        );
                        final docRef = await firestoreProvider.addEventAndGetRef(tempEventData);
                        eventId = docRef.id;
                      }
                      
                      final uploadedUrls = await storageService.uploadImages(selectedFiles, eventId);
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
    
    String selectedType = announcement?.type ?? 'bölüm';
    final typeOptions = ['bölüm', 'etkinlik', 'topluluk'];
    
    String selectedColor = announcement?.colorHex ?? '#2196F3';
    final colorOptions = ['#2196F3', '#F44336', '#4CAF50', '#FF9800', '#9C27B0'];
    
    // Image state
    html.File? selectedFile;
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
                        fillColor: Color(0xFF0A1929),
                      ),
                      dropdownColor: const Color(0xFF0A1929),
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
                        labelText: 'Etkinlik Adı',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A1929),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Etkinlik adı gerekli' : null,
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
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adres',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A1929),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Adres gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama (Opsiyonel)',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF0A1929),
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
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
                                    color: const Color(0xFF0A1929),
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
                                    html.Url.revokeObjectUrl(selectedFileUrl!);
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
                      onPressed: () {
                        final input = html.FileUploadInputElement()
                          ..accept = 'image/*';
                        input.click();
                        input.onChange.listen((e) {
                          final files = input.files;
                          if (files != null && files.isNotEmpty) {
                            setState(() {
                              selectedFile = files[0];
                              deleteExistingPoster = false;
                            });
                          }
                        });
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
                    String? finalPosterUrl;
                    String announcementId = announcement?.id ?? '';
                    
                    // Handle poster upload/deletion
                    if (selectedFile != null) {
                      // Upload new poster
                      announcementId = announcement?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
                      if (!isEditing) {
                        final tempAnnouncement = AnnouncementData(
                          type: selectedType,
                          eventName: eventNameController.text,
                          posterUrl: '',
                          date: dateController.text,
                          address: addressController.text,
                          description: descriptionController.text.isEmpty ? null : descriptionController.text,
                          colorHex: selectedColor,
                        );
                        final docRef = await firestoreProvider.addAnnouncementAndGetRef(tempAnnouncement);
                        announcementId = docRef.id;
                      }
                      final uploadedUrls = await storageService.uploadImages([selectedFile!], announcementId);
                      if (uploadedUrls.isNotEmpty) {
                        finalPosterUrl = uploadedUrls.first;
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
                      posterUrl: finalPosterUrl ?? '',
                      date: dateController.text,
                      address: addressController.text,
                      description: descriptionController.text.isEmpty ? null : descriptionController.text,
                      colorHex: selectedColor,
                    );

                    if (isEditing && announcement.id != null) {
                      await firestoreProvider.updateAnnouncement(announcement.id!, announcementData);
                    } else {
                      if (!isEditing && selectedFile != null && announcementId.isNotEmpty) {
                        await firestoreProvider.updateAnnouncement(announcementId, announcementData);
                      } else {
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

  Widget _buildTeamsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                      fillColor: Color(0xFF0A1929),
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
                      fillColor: Color(0xFF0A1929),
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
                        fillColor: Color(0xFF0A1929),
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
                        fillColor: Color(0xFF0A1929),
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
                        fillColor: Color(0xFF0A1929),
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
                        fillColor: Color(0xFF0A1929),
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
                    String? finalPhotoUrl;
                    String memberId = member?.id ?? '';
                    
                    // Handle photo upload/deletion
                    if (selectedFile != null) {
                      // Upload new photo
                      memberId = member?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
                      if (!isEditing) {
                        final tempMember = TeamMemberData(
                          teamId: teamId!,
                          name: nameController.text,
                          department: departmentController.text,
                          className: classNameController.text.isEmpty ? null : classNameController.text,
                          title: titleController.text,
                          photoUrl: '',
                        );
                        final docRef = await firestoreProvider.addTeamMemberAndGetRef(tempMember);
                        memberId = docRef.id;
                      }
                      finalPhotoUrl = await storageService.uploadTeamMemberPhoto(selectedFile!, memberId);
                    } else if (deleteExistingPhoto && existingPhotoUrl != null && existingPhotoUrl.isNotEmpty) {
                      // Delete existing photo
                      await storageService.deleteImage(existingPhotoUrl);
                      finalPhotoUrl = '';
                    } else {
                      // Keep existing photo
                      finalPhotoUrl = existingPhotoUrl ?? '';
                    }
                    
                    final memberData = TeamMemberData(
                      id: member?.id,
                      teamId: teamId ?? member!.teamId,
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
                            color: const Color(0xFF0A1929),
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
              child: PageView.builder(
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
                            color: const Color(0xFF0A1929),
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
                                    color: const Color(0xFF0A1929),
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
                        childAspectRatio: 0.75,
                      ),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        return _AdminTeamMemberCard(
                          member: members[index],
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

class _AdminTeamMemberCard extends StatelessWidget {
  final TeamMemberData member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminTeamMemberCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1929),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Fotoğraf
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: member.photoUrl != null && member.photoUrl!.isNotEmpty
                ? Image.network(
                    member.photoUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
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
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: const Color(0xFF2A3441),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white54,
                      size: 40,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          // İsim
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              member.name,
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
              member.title,
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
              member.department,
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
                    onPressed: onEdit,
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
                    onPressed: onDelete,
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
              color: const Color(0xFF0A1929),
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
                              size: 32,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: announcement.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      announcement.type,
                      style: TextStyle(
                        color: announcement.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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
                          fillColor: const Color(0xFF0A1929),
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
      await firestoreProvider.updateContactSettings({
        'email': _emailController.text.trim(),
        'socialMedia': _platformConfigs
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
            .whereType<Map<String, String>>()
            .toList(),
      });

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
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _copyrightController;
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
  }

  @override
  void dispose() {
    _siteNameController.dispose();
    _siteDescriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _copyrightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
      await firestoreProvider.updateSiteSettings({
        'siteName': _siteNameController.text.trim(),
        'siteDescription': _siteDescriptionController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'copyright': _copyrightController.text.trim(),
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

