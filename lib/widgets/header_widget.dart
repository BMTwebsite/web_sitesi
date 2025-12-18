import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  final _authService = AuthService();
  String _currentRoute = '/';

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    if (_currentRoute != currentRoute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentRoute = currentRoute);
        }
      });
    }

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
          // Logo
          InkWell(
            onTap: () {
              setState(() => _currentRoute = '/');
              Navigator.pushNamed(context, '/');
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
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
          // Navigation Menu
          Row(
            children: [
              _NavItem(
                text: 'Ana Sayfa',
                route: '/',
                isActive: _currentRoute == '/',
                onTap: () {
                  setState(() => _currentRoute = '/');
                  Navigator.pushNamed(context, '/');
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Duyurular',
                route: '/announcements',
                isActive: _currentRoute == '/announcements',
                onTap: () {
                  setState(() => _currentRoute = '/announcements');
                  Navigator.pushNamed(context, '/announcements');
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Etkinlik',
                route: '/events',
                isActive: _currentRoute == '/events',
                onTap: () {
                  setState(() => _currentRoute = '/events');
                  Navigator.pushNamed(context, '/events');
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Ekip',
                route: '/team',
                isActive: _currentRoute == '/team',
                onTap: () {
                  setState(() => _currentRoute = '/team');
                  Navigator.pushNamed(context, '/team');
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Sponsor',
                route: '/sponsor',
                isActive: _currentRoute == '/sponsor',
                onTap: () {
                  setState(() => _currentRoute = '/sponsor');
                  Navigator.pushNamed(context, '/sponsor');
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Hakkımızda',
                route: '/about',
                isActive: _currentRoute == '/about',
                onTap: () {
                  setState(() => _currentRoute = '/about');
                  Navigator.pushNamed(context, '/about');
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'İletişim',
                route: '/contact',
                isActive: _currentRoute == '/contact',
                onTap: () {
                  setState(() => _currentRoute = '/contact');
                  Navigator.pushNamed(context, '/contact');
                },
              ),
            ],
          ),
          // Giriş Butonu
          StreamBuilder(
            stream: _authService.authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              final isLoggedIn = snapshot.hasData;

              if (isLoggedIn) {
                return FutureBuilder<bool>(
                  future: _authService.isAdmin(),
                  builder: (context, adminSnapshot) {
                    if (adminSnapshot.data == true) {
                      return Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/admin-panel');
                            },
                            icon: const Icon(Icons.admin_panel_settings, size: 18),
                            label: const Text('Admin Paneli'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await _authService.signOut();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Çıkış yapıldı'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.logout, size: 18),
                            label: const Text('Çıkış'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/admin-login');
                      },
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('Giriş Yap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    );
                  },
                );
              }

              return ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/admin-login');
                },
                icon: const Icon(Icons.login, size: 18),
                label: const Text('Giriş Yap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              );
            },
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

