import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  // 0: Hakkımızda, 1: Ekipler
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Header(currentRoute: '/about'),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- ÜST SEKMELER (TABS) ---
                  _buildTabHeader(),
                  
                  const SizedBox(height: 60),

                  // --- DEĞİŞEN İÇERİK ALANI ---
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _selectedIndex == 0 
                        ? _buildAboutContent() 
                        : _buildTeamsContent(),
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

  // Üstteki "Hakkımızda | Ekipler" Seçim Alanı
  Widget _buildTabHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2332),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabButton(0, 'Hakkımızda'),
              const SizedBox(width: 8),
              _buildTabButton(1, 'Ekipler'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _selectedIndex == 0 
              ? 'Biz Kimiz & Ne Yapıyoruz?' 
              : 'Gücümüzü Aldığımız Ekiplerimiz',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String text) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  // --- İÇERİK 1: HAKKIMIZDA ---
  Widget _buildAboutContent() {
    return Column(
      key: const ValueKey('About'),
      children: [
        const SizedBox(
          width: 600,
          child: Text(
            'Teknoloji tutkumuzu akademik bilgiyle birleştiriyor, Bandırma\'dan dünyaya açılan projeler geliştiriyoruz.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 18, height: 1.6),
          ),
        ),
        const SizedBox(height: 80),
        _InfoSection(
          title: 'Bandırma Onyedi Eylül Üniversitesi',
          subtitle: 'Geleceğe Açılan Kapı',
          description: 'Bandırma Onyedi Eylül Üniversitesi, "Geleceğe Açılan Köprü" sloganıyla, bilimsel araştırmaları ve kaliteli eğitimi hedefleyen dinamik bir üniversitedir.\n\nMarmara Denizi\'nin incisi Bandırma\'da yer alan kampüsümüz, öğrencilere sadece akademik bilgi değil, aynı zamanda sosyal ve kültürel gelişim imkanları da sunmaktadır.',
          imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=800&h=600&fit=crop',
          isImageRight: true,
          accentColor: const Color(0xFF2196F3),
        ),
        const SizedBox(height: 60),
        _InfoSection(
          title: 'Bilgisayar Mühendisliği',
          subtitle: 'Algoritmaların Gücü',
          description: 'Bilgisayar Mühendisliği bölümü olarak amacımız; analitik düşünebilen, problem çözme yeteneği gelişmiş ve teknolojiyi insanlık yararına kullanabilen mühendisler yetiştirmektir.\n\nYazılım geliştirme, yapay zeka ve siber güvenlik alanlarında sunduğumuz kapsamlı müfredat ile öğrencilerimizi endüstri 4.0\'a hazırlıyoruz.',
          imageUrl: 'https://images.unsplash.com/photo-1571171637578-41bc2dd41cd2?w=800&h=600&fit=crop',
          isImageRight: false,
          accentColor: const Color(0xFFF44336),
        ),
      ],
    );
  }

  // --- İÇERİK 2: EKİPLER (Genişleyen Reyonlar - Statik Tasarım) ---
  Widget _buildTeamsContent() {
    // Örnek Veri Oluşturucu
    List<_Member> generateMembers(int count, String rolePrefix) {
      return List.generate(count, (index) => _Member(
        name: 'Üye Adı ${index + 1}',
        role: '$rolePrefix Uzmanı',
        imageUrl: 'https://i.pravatar.cc/150?u=${rolePrefix}_$index', 
        linkedinUrl: '#',
        githubUrl: '#',
      ));
    }

    return Column(
      key: const ValueKey('Teams'),
      children: [
        const SizedBox(
          width: 700,
          child: Text(
            'Topluluğumuzun kalbi burada atıyor. Ekipleri incelemek için üzerlerine tıklayın.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 18, height: 1.6),
          ),
        ),
        const SizedBox(height: 60),
        
        // 1. Eğitim & Organizasyon
        _ExpandableTeamStrip(
          title: 'Eğitim & Organizasyon',
          description: 'Workshoplar, hackathonlar ve haftalık derslerin planlanması.',
          icon: Icons.school_rounded,
          accentColor: const Color(0xFF2196F3),
          memberCount: '12 Üye',
          members: generateMembers(12, 'Eğitim'),
        ),
        const SizedBox(height: 20),
        
        // 2. Sponsorluk & Dış İlişkiler
        _ExpandableTeamStrip(
          title: 'Sponsorluk & Dış İlişkiler',
          description: 'Sektör devleriyle iletişim ve kaynak yaratımı.',
          icon: Icons.handshake_rounded,
          accentColor: const Color(0xFFF44336),
          memberCount: '8 Üye',
          members: generateMembers(8, 'İletişim'),
        ),
        const SizedBox(height: 20),
        
        // 3. Sosyal Medya & Tasarım
        _ExpandableTeamStrip(
          title: 'Sosyal Medya & Tasarım',
          description: 'Topluluğun dijital yüzü ve yaratıcı içerikler.',
          icon: Icons.brush_rounded,
          accentColor: const Color(0xFF4CAF50),
          memberCount: '15 Üye',
          members: generateMembers(15, 'Tasarım'),
        ),
      ],
    );
  }
}

// --- ÜYE MODELİ ---
class _Member {
  final String name;
  final String role;
  final String imageUrl;
  final String? linkedinUrl;
  final String? githubUrl;

  _Member({
    required this.name,
    required this.role,
    required this.imageUrl,
    this.linkedinUrl,
    this.githubUrl,
  });
}

// --- GENİŞLEYEBİLEN TAKIM ŞERİDİ (Clean Design) ---
class _ExpandableTeamStrip extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String memberCount;
  final List<_Member> members;

  const _ExpandableTeamStrip({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.memberCount,
    required this.members,
  });

  @override
  State<_ExpandableTeamStrip> createState() => _ExpandableTeamStripState();
}

class _ExpandableTeamStripState extends State<_ExpandableTeamStrip> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded 
              ? widget.accentColor.withValues(alpha: 0.5) 
              : Colors.white.withValues(alpha: 0.05)
        ),
        boxShadow: _isExpanded ? [
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ] : [],
      ),
      child: Column(
        children: [
          // --- HEADER (Tıklanabilir Alan) ---
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                children: [
                  // İkon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.accentColor, size: 30),
                  ),
                  const SizedBox(width: 24),
                  
                  // Metin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Üye Sayısı & Ok
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.memberCount,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0, 
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                  ),
                ],
              ),
            ),
          ),

          // --- GENİŞLEYEN ÜYE LİSTESİ ALANI ---
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isExpanded 
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: _buildMembersGrid(),
                )
              : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersGrid() {
    // Animasyon: İçerik sağa doğru kayarak gelir
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset((1 - value) * -50, 0), // Soldan (-50px) başlar
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          double cardWidth = 160; 
          
          return Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.start,
            children: widget.members.map((member) {
              return _MemberCard(member: member, width: cardWidth, accentColor: widget.accentColor);
            }).toList(),
          );
        },
      ),
    );
  }
}

// --- TEKİL ÜYE KARTI ---
class _MemberCard extends StatelessWidget {
  final _Member member;
  final double width;
  final Color accentColor;

  const _MemberCard({
    required this.member,
    required this.width,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fotoğraf
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 2),
              image: DecorationImage(
                image: NetworkImage(member.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // İsim
          Text(
            member.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          // Rol
          Text(
            member.role,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          
          // Sosyal Medya İkonları
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIcon(
                icon: Icons.code, // Github temsili
                url: member.githubUrl,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              _SocialIcon(
                icon: Icons.link, // LinkedIn temsili
                url: member.linkedinUrl,
                color: const Color(0xFF0077B5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String? url;
  final Color color;

  const _SocialIcon({required this.icon, this.url, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// --- BİLGİ KARTI (Sabit İçerik) ---
class _InfoSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final bool isImageRight;
  final Color accentColor;

  const _InfoSection({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.isImageRight,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Expanded(
        flex: 1,
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2332),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle.toUpperCase(),
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 40),
      Expanded(
        flex: 1,
        child: Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ];

    if (!isImageRight) {
      children = children.reversed.toList();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}