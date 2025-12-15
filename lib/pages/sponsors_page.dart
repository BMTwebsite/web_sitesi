import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../providers/firestore_provider.dart';
import '../utils/size_helper.dart';
import 'dart:html' as html;

class SponsorsPage extends StatelessWidget {
  const SponsorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Header(currentRoute: '/sponsor'),
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
              padding: SizeHelper.safePadding(
                context: context,
                horizontal: 60,
                vertical: 60,
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
                      fontSize: SizeHelper.safeFontSize(context, preferredSize: 48),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bizi destekleyen değerli sponsorlarımıza teşekkür ederiz',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
                    ),
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
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Sponsorlar yüklenirken bir hata oluştu',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: SizeHelper.safeFontSize(context, preferredSize: 20),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      errorMessage,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                    if (errorMessage.contains('index')) ...[
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Firebase Console\'da gerekli index\'i oluşturmanız gerekiyor.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Text(
                                  'Henüz sponsor eklenmemiş.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
                                  ),
                                ),
                              ),
                            );
                          }

                          final sponsors = snapshot.data!;
                          
                          // Sponsorları tier'a göre grupla
                          final platinumSponsors = sponsors.where((s) => s.tier.toLowerCase() == 'platinum').toList();
                          final goldSponsors = sponsors.where((s) => s.tier.toLowerCase() == 'gold').toList();
                          final silverSponsors = sponsors.where((s) => s.tier.toLowerCase() == 'silver').toList();
                          final bronzeSponsors = sponsors.where((s) => s.tier.toLowerCase() == 'bronze').toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (platinumSponsors.isNotEmpty) ...[
                                _SponsorTierSection(
                                  title: 'Platin Sponsorlar',
                                  sponsors: platinumSponsors,
                                  tierColor: const Color(0xFFE5E4E2),
                                ),
                                const SizedBox(height: 40),
                              ],
                              if (goldSponsors.isNotEmpty) ...[
                                _SponsorTierSection(
                                  title: 'Altın Sponsorlar',
                                  sponsors: goldSponsors,
                                  tierColor: const Color(0xFFFFD700),
                                ),
                                const SizedBox(height: 40),
                              ],
                              if (silverSponsors.isNotEmpty) ...[
                                _SponsorTierSection(
                                  title: 'Gümüş Sponsorlar',
                                  sponsors: silverSponsors,
                                  tierColor: const Color(0xFFC0C0C0),
                                ),
                                const SizedBox(height: 40),
                              ],
                              if (bronzeSponsors.isNotEmpty) ...[
                                _SponsorTierSection(
                                  title: 'Bronz Sponsorlar',
                                  sponsors: bronzeSponsors,
                                  tierColor: const Color(0xFFCD7F32),
                                ),
                              ],
                            ],
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
    );
  }
}

class _SponsorTierSection extends StatelessWidget {
  final String title;
  final List<SponsorData> sponsors;
  final Color tierColor;

  const _SponsorTierSection({
    required this.title,
    required this.sponsors,
    required this.tierColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 30,
              decoration: BoxDecoration(
                color: tierColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeHelper.safeFontSize(context, preferredSize: 28),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: SizeHelper.safeCrossAxisCount(context, preferredCount: 4),
            crossAxisSpacing: SizeHelper.safeSize(value: 20, min: 10, max: 40, context: 'Grid spacing'),
            mainAxisSpacing: SizeHelper.safeSize(value: 20, min: 10, max: 40, context: 'Grid spacing'),
            childAspectRatio: SizeHelper.safeSize(value: 1.2, min: 0.8, max: 1.5, context: 'Grid aspect ratio'),
          ),
          itemCount: sponsors.length,
          itemBuilder: (context, index) {
            return _SponsorCard(sponsor: sponsors[index], tierColor: tierColor);
          },
        ),
      ],
    );
  }
}

class _SponsorCard extends StatelessWidget {
  final SponsorData sponsor;
  final Color tierColor;

  const _SponsorCard({
    required this.sponsor,
    required this.tierColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: sponsor.websiteUrl != null && sponsor.websiteUrl!.isNotEmpty
          ? () {
              html.window.open(sponsor.websiteUrl!, '_blank');
            }
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E17),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: tierColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: tierColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Expanded(
                child: Container(
                  width: SizeHelper.safeInfinity(context, isWidth: true),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: sponsor.logoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            sponsor.logoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                child: Icon(
                                  Icons.business,
                                  color: tierColor,
                                  size: 60,
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(20),
                          child: Icon(
                            Icons.business,
                            color: tierColor,
                            size: 60,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Sponsor Adı
              Text(
                sponsor.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Açıklama (varsa)
              if (sponsor.description != null && sponsor.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  sponsor.description!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 12),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // Website linki varsa göster
              if (sponsor.websiteUrl != null && sponsor.websiteUrl!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.link,
                      color: tierColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Web Sitesi',
                      style: TextStyle(
                        color: tierColor,
                        fontSize: SizeHelper.safeFontSize(context, preferredSize: 12),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

