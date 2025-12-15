import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/size_helper.dart';

class Header extends StatelessWidget {
  final String currentRoute;

  const Header({super.key, this.currentRoute = '/home'});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E17),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: SizeHelper.safePadding(
        context: context,
        horizontal: 40,
        vertical: 20,
      ),
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
                  width: SizeHelper.safeSize(value: 40, min: 20, max: 60, context: 'Logo width'),
                  height: SizeHelper.safeSize(value: 40, min: 20, max: 60, context: 'Logo height'),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.memory,
                    color: Colors.white,
                    size: SizeHelper.safeSize(value: 24, min: 16, max: 32, context: 'Logo icon size'),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'BMT',
                  style: TextStyle(
                    color: const Color(0xFF0A1929),
                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 24),
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
                onTap: () => Navigator.pushNamed(context, '/about'),
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
                text: 'Duyurular',
                route: '/announcements',
                isActive: currentRoute == '/announcements',
                onTap: () => Navigator.pushNamed(context, '/announcements'),
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Ekip',
                route: '/team',
                isActive: currentRoute == '/team',
                onTap: () => Navigator.pushNamed(context, '/team'),
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Sponsor',
                route: '/sponsor',
                isActive: currentRoute == '/sponsor',
                onTap: () => Navigator.pushNamed(context, '/sponsor'),
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'İletişim',
                route: '/contact',
                isActive: currentRoute == '/contact',
                onTap: () => Navigator.pushNamed(context, '/contact'),
              ),
              const SizedBox(width: 30),
              // Admin Button
              StreamBuilder(
                stream: AuthService().authStateChanges,
                builder: (context, authSnapshot) {
                  if (!authSnapshot.hasData) {
                    return OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/admin-login'),
                      icon: Icon(Icons.login, size: SizeHelper.safeSize(value: 18, min: 12, max: 24, context: 'Button icon size')),
                      label: const Text('Admin Girişi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeHelper.safeSize(value: 16, min: 8, max: 32, context: 'Button padding horizontal'),
                          vertical: SizeHelper.safeSize(value: 8, min: 4, max: 16, context: 'Button padding vertical'),
                        ),
                      ),
                    );
                  }
                  
                  return FutureBuilder<bool>(
                    future: AuthService().isAdmin(),
                    builder: (context, adminSnapshot) {
                      final isAdmin = adminSnapshot.data ?? false;
                      
                      if (isAdmin) {
                        return OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/admin-panel'),
                          icon: Icon(Icons.admin_panel_settings, size: SizeHelper.safeSize(value: 18, min: 12, max: 24, context: 'Button icon size')),
                          label: const Text('Admin Paneli'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF2196F3)),
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeHelper.safeSize(value: 16, min: 8, max: 32, context: 'Button padding horizontal'),
                              vertical: SizeHelper.safeSize(value: 8, min: 4, max: 16, context: 'Button padding vertical'),
                            ),
                          ),
                        );
                      } else {
                        return OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/admin-login'),
                          icon: Icon(Icons.login, size: SizeHelper.safeSize(value: 18, min: 12, max: 24, context: 'Button icon size')),
                          label: const Text('Admin Girişi'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeHelper.safeSize(value: 16, min: 8, max: 32, context: 'Button padding horizontal'),
                              vertical: SizeHelper.safeSize(value: 8, min: 4, max: 16, context: 'Button padding vertical'),
                            ),
                          ),
                        );
                      }
                    },
                  );
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
          fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          decoration: isActive ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}

