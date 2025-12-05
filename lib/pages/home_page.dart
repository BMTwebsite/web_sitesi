import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Header(currentRoute: '/home'),
            _HeroSection(),
            const Footer(),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Section - Text Content
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2332),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cable,
                        color: const Color(0xFF2196F3),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Bilgisayar Mühendisliği Topluluğu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Headlines
                const Text(
                  'Kodla Geleceği',
                  style: TextStyle(
                    color: Color(0xFF2196F3),
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const Text(
                  'Tasarla Yarını',
                  style: TextStyle(
                    color: Color(0xFFF44336),
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const Text(
                  'Birlikte Başaralım',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 30),
                // Description
                const Text(
                  'Bilgisayar Mühendisliği Topluluğu olarak, teknolojiye tutkulu öğrencileri bir araya getiriyor, bilgi paylaşımını ve inovasyonu destekliyoruz.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                // CTA Buttons
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bize Katıl',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/events');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Etkinlikleri Gör',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                // Statistics
                Row(
                  children: [
                    _StatCard('500+', 'Üye'),
                    const SizedBox(width: 20),
                    _StatCard('150+', 'Etkinlik'),
                    const SizedBox(width: 20),
                    _StatCard('50+', 'Proje'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          // Right Section - Image
          Expanded(
            flex: 1,
            child: Container(
              height: 600,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF1A2332),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String label;

  const _StatCard(this.number, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

