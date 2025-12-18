import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/firestore_provider.dart';
import '../utils/size_helper.dart';
import 'circular_logo_widget.dart';

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
      padding: EdgeInsets.symmetric(
        horizontal: SizeHelper.isMobile(context) ? 12 : (SizeHelper.isTablet(context) ? 24 : 40),
        vertical: SizeHelper.isMobile(context) ? 10 : (SizeHelper.isTablet(context) ? 16 : 20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo - tıklanınca admin girişi açılır
              Consumer<FirestoreProvider>(
                builder: (context, firestoreProvider, _) => StreamBuilder<Map<String, dynamic>>(
                  stream: firestoreProvider.getSiteSettingsStream(),
                  builder: (context, snapshot) {
                    final logoUrl = snapshot.data?['logoUrl'] ?? '';
                    final logoSize = SizeHelper.isMobile(context) ? 50.0 : (SizeHelper.isTablet(context) ? 60.0 : 70.0);
                    
                    return GestureDetector(
                      onTap: () {
                        // Logo'ya tıklanınca admin giriş sayfasına yönlendir
                        Navigator.pushNamed(context, '/admin-login');
                      },
                      child: Container(
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
                                color: const Color(0xFF0A1929),
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
                      ),
                    );
                  },
                ),
              ),
              // Navigation - Yatay kaydırılabilir
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NavItem(
                        text: 'Ana Sayfa',
                        route: '/home',
                        isActive: currentRoute == '/home' || currentRoute == '/',
                        onTap: () => Navigator.pushNamed(context, '/'),
                      ),
                      SizedBox(width: SizeHelper.isMobile(context) ? 12 : (SizeHelper.isTablet(context) ? 20 : 30)),
                      _NavItem(
                        text: 'Duyurular',
                        route: '/announcements',
                        isActive: currentRoute == '/announcements',
                        onTap: () => Navigator.pushNamed(context, '/announcements'),
                      ),
                      SizedBox(width: SizeHelper.isMobile(context) ? 12 : (SizeHelper.isTablet(context) ? 20 : 30)),
                      _NavItem(
                        text: 'Etkinlik',
                        route: '/events',
                        isActive: currentRoute == '/events',
                        onTap: () => Navigator.pushNamed(context, '/events'),
                      ),
                      SizedBox(width: SizeHelper.isMobile(context) ? 12 : (SizeHelper.isTablet(context) ? 20 : 30)),
                      _NavItem(
                        text: 'Ekip',
                        route: '/team',
                        isActive: currentRoute == '/team',
                        onTap: () => Navigator.pushNamed(context, '/team'),
                      ),
                      SizedBox(width: SizeHelper.isMobile(context) ? 12 : (SizeHelper.isTablet(context) ? 20 : 30)),
                      _NavItem(
                        text: 'Sponsor',
                        route: '/sponsor',
                        isActive: currentRoute == '/sponsor',
                        onTap: () => Navigator.pushNamed(context, '/sponsor'),
                      ),
                      SizedBox(width: SizeHelper.isMobile(context) ? 12 : (SizeHelper.isTablet(context) ? 20 : 30)),
                      _NavItem(
                        text: 'Hakkımızda',
                        route: '/about',
                        isActive: currentRoute == '/about',
                        onTap: () => Navigator.pushNamed(context, '/about'),
                      ),
                      SizedBox(width: SizeHelper.isMobile(context) ? 12 : (SizeHelper.isTablet(context) ? 20 : 30)),
                      _NavItem(
                        text: 'İletişim',
                        route: '/contact',
                        isActive: currentRoute == '/contact',
                        onTap: () => Navigator.pushNamed(context, '/contact'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Admin Paneli Butonu - İletişim linkinin altında
          StreamBuilder(
            stream: AuthService().authStateChanges,
            builder: (context, authSnapshot) {
              if (authSnapshot.hasData) {
                return FutureBuilder<bool>(
                  future: AuthService().isAdmin(),
                  builder: (context, adminSnapshot) {
                    final isAdmin = adminSnapshot.data ?? false;
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isSmallScreen = screenWidth < 768;
                    
                    if (isAdmin) {
                      return Padding(
                        padding: EdgeInsets.only(
                          top: SizeHelper.isMobile(context) ? 8 : 12,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/admin-panel'),
                            icon: Icon(
                              Icons.admin_panel_settings,
                              size: SizeHelper.clampFontSize(screenWidth, 14, 16, 18),
                            ),
                            label: Text(
                              'Admin Paneli',
                              style: TextStyle(
                                fontSize: SizeHelper.clampFontSize(screenWidth, 11, 13, 15),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF2196F3)),
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 16,
                                vertical: isSmallScreen ? 6 : 8,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              }
              return const SizedBox.shrink();
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
    final screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: SizeHelper.clampFontSize(screenWidth, 12, 14, 16),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          decoration: isActive ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}

// SliverPersistentHeader için delegate
class HeaderSliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final BuildContext context;

  HeaderSliverDelegate({
    required this.child,
    required this.context,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent {
    // Header'ın gerçek yüksekliğini hesapla
    final isMobile = SizeHelper.isMobile(context);
    final isTablet = SizeHelper.isTablet(context);
    
    // Logo yüksekliği + logo padding + vertical padding
    final logoHeight = isMobile ? 50.0 : (isTablet ? 60.0 : 70.0);
    final logoPadding = isMobile ? 6.0 * 2 : 10.0 * 2;
    final verticalPadding = isMobile ? 10.0 * 2 : (isTablet ? 16.0 * 2 : 20.0 * 2);
    // Admin paneli butonu için ekstra alan (alt satır)
    final adminButtonHeight = isMobile ? 36.0 : 40.0; // Buton yüksekliği + padding
    final adminButtonTopPadding = isMobile ? 8.0 : 12.0;
    final totalHeight = verticalPadding + logoHeight + logoPadding + adminButtonHeight + adminButtonTopPadding;
    
    return totalHeight;
  }

  @override
  double get minExtent => maxExtent;

  @override
  bool shouldRebuild(HeaderSliverDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}


