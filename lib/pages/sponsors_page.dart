import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../widgets/empty_state.dart';
import '../widgets/sponsor_card.dart';
import '../providers/firestore_provider.dart';
import '../utils/size_helper.dart';

class SponsorsPage extends StatelessWidget {
  const SponsorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: HeaderSliverDelegate(
              child: const Header(currentRoute: '/sponsor'),
              context: context,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A0E17),
                    const Color(0xFF1A2332).withOpacity(0.3),
                    const Color(0xFF0A0E17),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: SizeHelper.isMobile(context) ? 16 : (SizeHelper.isTablet(context) ? 32 : 60),
                vertical: SizeHelper.isMobile(context) ? 40 : (SizeHelper.isTablet(context) ? 50 : 60),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2196F3).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.business,
                          color: Color(0xFF2196F3),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Sponsorlar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Sponsorlarımız',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeHelper.clampFontSize(
                        MediaQuery.of(context).size.width,
                        28,
                        38,
                        48,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: SizeHelper.isMobile(context) ? 12 : 16),
                  Text(
                    'Bizi destekleyen değerli sponsorlarımıza teşekkür ederiz',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: SizeHelper.clampFontSize(
                        MediaQuery.of(context).size.width,
                        14,
                        16,
                        18,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 40),
                  Consumer<FirestoreProvider>(
                    builder: (context, firestoreProvider, _) {
                      return StreamBuilder<List<SponsorData>>(
                        stream: firestoreProvider.getSponsors(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            final errorMessage = snapshot.error.toString();
                            final screenWidth = MediaQuery.of(context).size.width;
                            final isMobile = SizeHelper.isMobile(context);
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(isMobile ? 20 : 40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: SizeHelper.clampFontSize(screenWidth, 32, 40, 48),
                                    ),
                                    SizedBox(height: isMobile ? 12 : 16),
                                    Text(
                                      'Sponsorlar yüklenirken bir hata oluştu',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: SizeHelper.clampFontSize(screenWidth, 14, 16, 18),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: isMobile ? 8 : 12),
                                    Text(
                                      errorMessage,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: SizeHelper.clampFontSize(screenWidth, 11, 13, 15),
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (errorMessage.contains('index')) ...[
                                      SizedBox(height: isMobile ? 12 : 16),
                                      Text(
                                        'Firebase Console\'da gerekli index\'i oluşturmanız gerekiyor.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: SizeHelper.clampFontSize(screenWidth, 11, 13, 15),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const EmptyState(
                              message: 'Henüz sponsor eklenmemiş.',
                              icon: Icons.business_center,
                            );
                          }

                          final sponsors = snapshot.data!;

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final screenWidth = MediaQuery.of(context).size.width;
                              int crossAxisCount;
                              double aspectRatio;
                              double spacing;
                              
                              if (screenWidth < 600) {
                                crossAxisCount = 1;
                                aspectRatio = 0.9;
                                spacing = 16;
                              } else if (screenWidth < 1024) {
                                crossAxisCount = 2;
                                aspectRatio = 1.0;
                                spacing = 18;
                              } else {
                                crossAxisCount = screenWidth > 1400 ? 4 : 3;
                                aspectRatio = 1.0;
                                spacing = 20;
                              }
                              
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: spacing,
                                  mainAxisSpacing: spacing,
                                  childAspectRatio: aspectRatio,
                                ),
                                itemCount: sponsors.length,
                                itemBuilder: (context, index) {
                                  return SponsorCard(
                                    sponsor: sponsors[index],
                                    isAdmin: false,
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
                const Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// _SponsorCard removed - using shared SponsorCard widget

