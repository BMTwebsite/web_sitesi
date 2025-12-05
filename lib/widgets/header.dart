import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class Header extends StatelessWidget {
  final String currentRoute;

  const Header({super.key, this.currentRoute = '/home'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.memory,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'BMT',
                  style: TextStyle(
                    color: Color(0xFF0A1929),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Navigation
          Row(
            children: [
              _NavItem(
                text: 'Ana Sayfa',
                route: '/home',
                isActive: currentRoute == '/home',
                onTap: () => Navigator.pushNamed(context, '/home'),
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Hakkımızda',
                route: '/about',
                isActive: currentRoute == '/about',
                onTap: () {},
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Etkinlik',
                route: '/events',
                isActive: currentRoute == '/events',
                onTap: () => Navigator.pushNamed(context, '/events'),
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Ekip',
                route: '/team',
                isActive: currentRoute == '/team',
                onTap: () {},
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Sponsor',
                route: '/sponsor',
                isActive: currentRoute == '/sponsor',
                onTap: () {},
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'İletişim',
                route: '/contact',
                isActive: currentRoute == '/contact',
                onTap: () {},
              ),
              const SizedBox(width: 30),
              // Admin Button
              StreamBuilder(
                stream: AuthService().authStateChanges,
                builder: (context, snapshot) {
                  final isLoggedIn = snapshot.hasData && 
                      AuthService().isAdmin();
                  
                  if (isLoggedIn) {
                    return OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/admin'),
                      icon: const Icon(Icons.admin_panel_settings, size: 18),
                      label: const Text('Admin Paneli'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF2196F3)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    );
                  } else {
                    return OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/admin-login'),
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('Admin Girişi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String text;
  final String route;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.text,
    required this.route,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          decoration: isActive ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}

