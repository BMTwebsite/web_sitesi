import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../providers/firestore_provider.dart';
import '../utils/size_helper.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Header(currentRoute: '/team'),
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
                      fontSize: SizeHelper.safeFontSize(context, preferredSize: 48),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ekibimizi tanıyın ve birlikte neler başardığımızı keşfedin',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
                    ),
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
                                      'Ekipler yüklenirken bir hata oluştu',
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
                                  'Henüz ekip eklenmemiş.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
                                  ),
                                ),
                              ),
                            );
                          }

                          final teams = snapshot.data!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: teams.map((team) {
                              return _TeamSection(
                                team: team,
                                firestoreProvider: firestoreProvider,
                              );
                            }).toList(),
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
            fontSize: SizeHelper.safeFontSize(context, preferredSize: 36),
            fontWeight: FontWeight.bold,
          ),
        ),
        if (team.description != null && team.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            team.description!,
            style: TextStyle(
              color: Colors.white70,
              fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
            ),
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ekip üyeleri yüklenirken bir hata oluştu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Bu ekipte henüz üye yok.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 14),
                  ),
                ),
              );
            }

            final members = snapshot.data!;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: SizeHelper.isMobile(context) ? 1 : SizeHelper.isTablet(context) ? 2 : 4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.7,
              ),
              itemCount: members.length,
              itemBuilder: (context, index) {
                return _TeamMemberCard(member: members[index]);
              },
            );
          },
        ),
      ],
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final TeamMemberData member;

  const _TeamMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Fotoğraf
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: member.photoUrl != null && member.photoUrl!.isNotEmpty
                ? Image.network(
                    member.photoUrl!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2332),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF2196F3),
                          size: 60,
                        ),
                      );
                    },
                  )
                : Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF2196F3),
                      size: 60,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          // İsim
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              member.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          // Ünvan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              member.title,
              style: TextStyle(
                color: const Color(0xFF2196F3),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          // Bölüm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              member.department,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Sınıf (varsa)
          if (member.className != null && member.className!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                member.className!,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const Spacer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

