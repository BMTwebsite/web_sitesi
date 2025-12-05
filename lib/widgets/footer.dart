import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      color: const Color(0xFF0A1929),
      child: Column(
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
                            'Bilgisayar Mühendisliği Topluluğu',
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
                    const SizedBox(height: 16),
                    const Text(
                      'Teknoloji ve inovasyonun buluşma noktası. Geleceği birlikte kodluyoruz.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      '© 2025 Bilgisayar Mühendisliği Topluluğu. Tüm hakları saklıdır.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Column 2: Contact Info
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
                    _ContactItem(
                      icon: Icons.email,
                      text: 'info@bmt.edu.tr',
                    ),
                    const SizedBox(height: 12),
                    _ContactItem(
                      icon: Icons.phone,
                      text: '+90 (212) 555 0123',
                    ),
                    const SizedBox(height: 12),
                    _ContactItem(
                      icon: Icons.location_on,
                      text: 'Bayburt Üniversitesi',
                    ),
                  ],
                ),
              ),
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
                    Row(
                      children: [
                        _SocialIcon(Icons.facebook),
                        const SizedBox(width: 12),
                        _SocialIcon(Icons.circle, icon: Icons.close), // Twitter placeholder
                        const SizedBox(width: 12),
                        _SocialIcon(Icons.camera_alt), // Instagram placeholder
                        const SizedBox(width: 12),
                        _SocialIcon(Icons.business), // LinkedIn placeholder
                        const SizedBox(width: 12),
                        _SocialIcon(Icons.code), // GitHub placeholder
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Gizlilik Politikası',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(width: 20),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Kullanım Şartları',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData iconData;
  final IconData? icon;

  const _SocialIcon(this.iconData, {this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon ?? iconData,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

