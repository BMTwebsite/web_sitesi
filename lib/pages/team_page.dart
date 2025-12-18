import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../widgets/empty_state.dart';
import '../widgets/team_member_card.dart';
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
              aspectRatio = 0.85;
              spacing = 16;
            } else if (screenWidth < 1024) {
              crossAxisCount = 2;
              aspectRatio = 0.75;
              spacing = 18;
            } else {
              crossAxisCount = screenWidth > 1400 ? 4 : 3;
              aspectRatio = 0.75;
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
                return TeamMemberCard(
                  member: member,
                  isAdmin: false,
                );
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
                  aspectRatio = 0.85;
                  spacing = 16;
                } else if (screenWidth < 1024) {
                  crossAxisCount = 2;
                  aspectRatio = 0.75;
                  spacing = 18;
                } else {
                  crossAxisCount = screenWidth > 1400 ? 4 : 3;
                  aspectRatio = 0.75;
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
                    return TeamMemberCard(
                      member: member,
                      isAdmin: false,
                    );
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

// _TeamMemberCard removed - using shared TeamMemberCard widget

