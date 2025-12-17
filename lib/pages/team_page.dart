import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../widgets/empty_state.dart';
import '../widgets/image_viewer_dialog.dart';
import '../providers/firestore_provider.dart';
import '../utils/size_helper.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

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
              child: const Header(currentRoute: '/team'),
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
                          Icons.groups,
                          color: Color(0xFF2196F3),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Ekip',
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
                    'Ekip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 28, 38, 48),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          SizedBox(height: SizeHelper.isMobile(context) ? 12 : 16),
          Text(
            'Ekibimizi tanıyın ve birlikte neler başardığımızı keşfedin',
            style: TextStyle(
              color: Colors.white70,
              fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 14, 16, 18),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
                  const SizedBox(height: 40),
                  Consumer<FirestoreProvider>(
                    builder: (context, firestoreProvider, _) {
                      return StreamBuilder<List<TeamData>>(
                        stream: firestoreProvider.getTeams(),
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
                                      'Ekipler yüklenirken bir hata oluştu',
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
                              message: 'Henüz ekip eklenmemiş.',
                              icon: Icons.groups,
                            );
                          }

                          final teams = snapshot.data!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...teams.map((team) {
                                return _TeamSection(
                                  team: team,
                                  firestoreProvider: firestoreProvider,
                                );
                              }).toList(),
                              // TeamId null olan üyeleri göster
                              _UnassignedTeamMembersSection(
                                firestoreProvider: firestoreProvider,
                              ),
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
        ],
      ),
    );
  }
}

class _TeamSection extends StatelessWidget {
  final TeamData team;
  final FirestoreProvider firestoreProvider;

  const _TeamSection({
    required this.team,
    required this.firestoreProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          team.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 24, 30, 36),
            fontWeight: FontWeight.bold,
          ),
        ),
        if (team.description != null && team.description!.isNotEmpty) ...[
          SizedBox(height: SizeHelper.isMobile(context) ? 6 : 8),
          Text(
            team.description!,
            style: TextStyle(
              color: Colors.white70,
              fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 13, 15, 16),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 24),
        StreamBuilder<List<TeamMemberData>>(
          stream: firestoreProvider.getTeamMembers(team.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
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
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: SizeHelper.clampFontSize(screenWidth, 24, 30, 32),
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      Text(
                        'Ekip üyeleri yüklenirken bir hata oluştu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeHelper.clampFontSize(screenWidth, 12, 14, 16),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isMobile ? 6 : 8),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: SizeHelper.clampFontSize(screenWidth, 10, 11, 12),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const EmptyState(
                message: 'Bu ekipte henüz üye yok.',
                icon: Icons.person_outline,
                textColor: Colors.white54,
              );
            }

            // Boş isimli üyeleri filtrele
            final allMembers = snapshot.data!;
            final members = allMembers.where((member) => 
              member.name.trim().isNotEmpty
            ).toList();
            
            if (members.isEmpty) {
              return const EmptyState(
                message: 'Bu ekipte henüz üye yok.',
                icon: Icons.person_outline,
                textColor: Colors.white54,
              );
            }
            
            print('📋 StreamBuilder - ${members.length} üye bulundu (${allMembers.length - members.length} boş üye filtrelendi)');
            for (var member in members) {
              print('📋 Üye: ${member.name}, photoUrl: ${member.photoUrl?.substring(0, member.photoUrl!.length > 50 ? 50 : member.photoUrl!.length) ?? "YOK"}...');
            }

            final screenWidth = MediaQuery.of(context).size.width;
            int crossAxisCount;
            double aspectRatio;
            double spacing;
            
            if (screenWidth < 600) {
              crossAxisCount = 1;
              aspectRatio = 0.7;
              spacing = 16;
            } else if (screenWidth < 1024) {
              crossAxisCount = 2;
              aspectRatio = 0.6;
              spacing = 18;
            } else {
              crossAxisCount = screenWidth > 1400 ? 4 : 3;
              aspectRatio = 0.6;
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
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                print('🔄 GridView.builder - Card oluşturuluyor: ${member.name}, photoUrl: ${member.photoUrl?.substring(0, member.photoUrl!.length > 50 ? 50 : member.photoUrl!.length) ?? "YOK"}...');
                return _TeamMemberCard(member: member);
              },
            );
          },
        ),
      ],
    );
  }
}

class _UnassignedTeamMembersSection extends StatelessWidget {
  final FirestoreProvider firestoreProvider;

  const _UnassignedTeamMembersSection({
    required this.firestoreProvider,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TeamMemberData>>(
      stream: firestoreProvider.getAllTeamMembers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        // TeamId null olan üyeleri filtrele
        final unassignedMembers = snapshot.data!
            .where((member) => member.teamId == null || member.teamId!.isEmpty)
            .where((member) => member.name.trim().isNotEmpty)
            .toList();

        if (unassignedMembers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              'Diğer Üyeler',
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 24, 30, 36),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder<List<TeamMemberData>>(
              stream: firestoreProvider.getAllTeamMembers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                final allMembers = snapshot.data!;
                final members = allMembers
                    .where((member) => member.teamId == null || member.teamId!.isEmpty)
                    .where((member) => member.name.trim().isNotEmpty)
                    .toList();

                if (members.isEmpty) {
                  return const SizedBox.shrink();
                }

                final screenWidth = MediaQuery.of(context).size.width;
                int crossAxisCount;
                double aspectRatio;
                double spacing;

                if (screenWidth < 600) {
                  crossAxisCount = 1;
                  aspectRatio = 0.7;
                  spacing = 16;
                } else if (screenWidth < 1024) {
                  crossAxisCount = 2;
                  aspectRatio = 0.6;
                  spacing = 18;
                } else {
                  crossAxisCount = screenWidth > 1400 ? 4 : 3;
                  aspectRatio = 0.6;
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
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return _TeamMemberCard(member: member);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final TeamMemberData member;

  const _TeamMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    print('🏗️ _TeamMemberCard.build çağrıldı - ${member.name}');
    print('🏗️ photoUrl: ${member.photoUrl?.substring(0, member.photoUrl!.length > 50 ? 50 : member.photoUrl!.length) ?? "YOK"}...');
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2196F3).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: SizeHelper.isMobile(context) ? 16 : 20),
          // Fotoğraf
          Builder(
            builder: (context) {
              final photoUrl = member.photoUrl;
              final screenWidth = MediaQuery.of(context).size.width;
              final imageSize = screenWidth < 600 ? 80.0 : (screenWidth < 1024 ? 90.0 : 100.0);
              
              print('🖼️ Fotoğraf gösteriliyor - member: ${member.name}, photoUrl: $photoUrl');
              
              if (photoUrl != null && photoUrl.isNotEmpty) {
                // URL'i normalize et
                String normalizedUrl = photoUrl;
                try {
                  // URL'i parse et ve tekrar oluştur (encoding sorunlarını çözer)
                  final uri = Uri.parse(photoUrl);
                  normalizedUrl = uri.toString();
                  print('🔄 Normalized URL: $normalizedUrl');
                } catch (e) {
                  print('⚠️ URL parse hatası: $e, orijinal URL kullanılıyor');
                }
                
                // Flutter web'de CORS sorununu çözmek için HTML img elementi kullan
                if (kIsWeb) {
                  // Unique ID oluştur
                  final imageId = 'team_img_${member.id ?? DateTime.now().millisecondsSinceEpoch}';
                  
                  // HTML img elementi oluştur
                  final imgElement = html.ImageElement()
                    ..src = normalizedUrl
                    ..style.width = '${imageSize}px'
                    ..style.height = '${imageSize}px'
                    ..style.objectFit = 'cover'
                    ..style.borderRadius = '12px'
                    ..style.cursor = 'pointer'
                    ..onError.listen((_) {
                      print('❌ Team Page - HTML img yükleme hatası: $normalizedUrl');
                    })
                    ..onLoad.listen((_) {
                      print('✅ Team Page - HTML img yüklendi: $normalizedUrl');
                    });
                  
                  // Platform view registry'ye kaydet
                  ui_web.platformViewRegistry.registerViewFactory(
                    imageId,
                    (int viewId) => imgElement,
                  );
                  
                  return GestureDetector(
                    onTap: () {
                      ImageViewerDialog.show(context, normalizedUrl, title: member.name);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: HtmlElementView(viewType: imageId),
                      ),
                    ),
                  );
                } else {
                  // Mobile için normal Image.network kullan
                  return GestureDetector(
                    onTap: () {
                      ImageViewerDialog.show(context, normalizedUrl, title: member.name);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        normalizedUrl,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          print('✅ Fotoğraf yüklendi: $photoUrl');
                          return child;
                        }
                        return Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A2332),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: const Color(0xFF2196F3),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ Fotoğraf yükleme hatası: $error');
                        return Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A2332),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person,
                            color: const Color(0xFF2196F3),
                            size: imageSize * 0.5,
                          ),
                        );
                      },
                      ),
                    ),
                  );
                }
              } else {
                print('⚠️ Fotoğraf URL yok - member: ${member.name}');
                final imageSize = MediaQuery.of(context).size.width < 600 ? 80.0 : (MediaQuery.of(context).size.width < 1024 ? 90.0 : 100.0);
                return Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2332),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person,
                    color: const Color(0xFF2196F3),
                    size: imageSize * 0.5,
                  ),
                );
              }
            },
          ),
          SizedBox(height: SizeHelper.isMobile(context) ? 10 : 12),
          // İsim
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeHelper.isMobile(context) ? 10 : 12),
            child: Text(
              member.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeHelper.clampFontSize(
                  MediaQuery.of(context).size.width,
                  14,
                  16,
                  18,
                ),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: SizeHelper.isMobile(context) ? 5 : 6),
          // Ünvan
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeHelper.isMobile(context) ? 10 : 12),
            child: Text(
              member.title,
              style: TextStyle(
                color: const Color(0xFF2196F3),
                fontSize: SizeHelper.clampFontSize(
                  MediaQuery.of(context).size.width,
                  11,
                  13,
                  15,
                ),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: SizeHelper.isMobile(context) ? 5 : 6),
          // Bölüm
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeHelper.isMobile(context) ? 10 : 12),
            child: Text(
              member.department,
              style: TextStyle(
                color: Colors.white70,
                fontSize: SizeHelper.clampFontSize(
                  MediaQuery.of(context).size.width,
                  10,
                  12,
                  14,
                ),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Sınıf (varsa)
          if (member.className != null && member.className!.isNotEmpty) ...[
            SizedBox(height: SizeHelper.isMobile(context) ? 3 : 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeHelper.isMobile(context) ? 10 : 12),
              child: Text(
                member.className!,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: SizeHelper.clampFontSize(
                    MediaQuery.of(context).size.width,
                    9,
                    11,
                    13,
                  ),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          SizedBox(height: SizeHelper.isMobile(context) ? 16 : 20),
        ],
      ),
    );
  }
}

