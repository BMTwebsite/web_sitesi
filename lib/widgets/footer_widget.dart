import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 50),
      color: const Color(0xFF0A1929),
      child: Column(
        children: [
          const Text(
            '© 2025 Bilgisayar Mühendisliği Topluluğu. Tüm hakları saklıdır.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

