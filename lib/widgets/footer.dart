import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firestore_provider.dart';
import '../utils/size_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E17),
      ),
      padding: SizeHelper.safePadding(
        context: context,
        horizontal: 30,
        vertical: 50,
      ),
      child: const _FooterContent(),
    );
  }
}

class _FooterContent extends StatelessWidget {
  const _FooterContent();

  @override
  Widget build(BuildContext context) {
    final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
    
    return StreamBuilder<Map<String, dynamic>>(
      stream: firestoreProvider.getSiteSettingsStream(),
      builder: (context, snapshot) {
        final siteSettings = snapshot.data ?? {};
        final siteName = siteSettings['siteName'] ?? '';
        final siteDescription = siteSettings['siteDescription'] ?? '';
        final email = siteSettings['email'] ?? '';
        final phone = siteSettings['phone'] ?? '';
        final address = siteSettings['address'] ?? '';
        final copyright = siteSettings['copyright'] ?? '';
        
        return StreamBuilder<Map<String, dynamic>>(
          stream: firestoreProvider.getContactSettingsStream(),
          builder: (context, contactSnapshot) {
            final contactSettings = contactSnapshot.data ?? {};
            final socialMedia = contactSettings['socialMedia'] as List<dynamic>? ?? [];
            
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Column 1: Community Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              Flexible(
                                child: Text(
                                  siteName.isNotEmpty ? siteName : 'Site Adı',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                          if (siteDescription.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              siteDescription,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          if (copyright.isNotEmpty) ...[
                            const SizedBox(height: 30),
                            Text(
                              copyright,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Column 2: Contact Info
                    if (email.isNotEmpty || phone.isNotEmpty || address.isNotEmpty)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'İletişim Bilgileri',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (email.isNotEmpty)
                              _ContactItem(
                                icon: Icons.email,
                                text: email,
                                onTap: () async {
                                  final Uri emailUri = Uri(
                                    scheme: 'mailto',
                                    path: email,
                                  );
                                  if (await canLaunchUrl(emailUri)) {
                                    await launchUrl(emailUri);
                                  }
                                },
                              ),
                            if (email.isNotEmpty && phone.isNotEmpty) const SizedBox(height: 12),
                            if (phone.isNotEmpty)
                              _ContactItem(
                                icon: Icons.phone,
                                text: phone,
                                onTap: () async {
                                  final Uri phoneUri = Uri(
                                    scheme: 'tel',
                                    path: phone,
                                  );
                                  if (await canLaunchUrl(phoneUri)) {
                                    await launchUrl(phoneUri);
                                  }
                                },
                              ),
                            if (phone.isNotEmpty && address.isNotEmpty) const SizedBox(height: 12),
                            if (address.isNotEmpty)
                              _ContactItem(
                                icon: Icons.location_on,
                                text: address,
                              ),
                          ],
                        ),
                      ),
                    if (socialMedia.isNotEmpty) ...[
                      const SizedBox(width: 20),
                      // Column 3: Social Media
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bizi Takip Edin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: socialMedia.map((item) {
                                final data = item as Map<String, dynamic>;
                                final url = data['url'] as String? ?? '';
                                final iconName = data['icon'] as String? ?? 'link';
                                final colorHex = data['color'] as String? ?? '#2196F3';
                                
                                return GestureDetector(
                                  onTap: url.isNotEmpty ? () async {
                                    final Uri uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  } : null,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color(int.parse(colorHex.replaceFirst('#', '0xFF'))),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      _getIconData(iconName),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'instagram':
      case 'camera_alt':
        return Icons.camera_alt;
      case 'linkedin':
      case 'business':
        return Icons.business;
      case 'youtube':
      case 'play_circle_filled':
        return Icons.play_circle_filled;
      case 'tiktok':
      case 'music_note':
        return Icons.music_note;
      case 'whatsapp':
        return Icons.chat;
      case 'link':
        return Icons.link;
      case 'facebook':
        return Icons.facebook;
      case 'language':
        return Icons.language;
      default:
        return Icons.link;
    }
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _ContactItem({
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: onTap != null ? Colors.white : Colors.white70,
                fontSize: 14,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

