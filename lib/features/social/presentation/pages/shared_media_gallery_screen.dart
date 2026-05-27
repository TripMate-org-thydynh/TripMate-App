import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SharedMediaGalleryScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const SharedMediaGalleryScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<SharedMediaGalleryScreen> createState() => _SharedMediaGalleryScreenState();
}

class _SharedMediaGalleryScreenState extends State<SharedMediaGalleryScreen> {
  int _activeTab = 0; // 0: Photos & Videos, 1: Links, 2: Voice Snaps

  final List<String> _mediaItems = [
    'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=500', // Kyoto Temple
    'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=500', // Bamboo
    'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=500', // Tokyo neon
    'https://images.unsplash.com/photo-1528164344705-47542687000d?w=500', // Gion Walk
    'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=500', // Ramen
    'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=500', // Coffee Cafe
  ];

  final List<Map<String, String>> _links = [
    {
      'title': 'Ryokan Koto Kyoto Booking',
      'url': 'https://booking.com/ryokan-koto',
      'sender': '@alex_escapes',
      'icon': '🏨',
    },
    {
      'title': 'The Hill Station Dalat Review',
      'url': 'https://tripadvisor.com/the-hill-station',
      'sender': '@sarah_wander',
      'icon': '🥞',
    },
    {
      'title': 'KIX Express Train Schedules',
      'url': 'https://westjr.co.jp/haruka',
      'sender': '@minh_nhat',
      'icon': '🚄',
    },
    {
      'title': 'Gion District Walk Route Map',
      'url': 'https://google.com/maps/gion',
      'sender': '@nam_trung',
      'icon': '🗺️',
    }
  ];

  final List<Map<String, dynamic>> _voiceSnaps = [
    {
      'title': 'Minh\'s crazy coffee speech.mp3',
      'duration': '0:42',
      'sender': '@minh_nhat',
      'isPlaying': false,
    },
    {
      'title': 'Gion noise and street market.mp3',
      'duration': '1:15',
      'sender': '@thao_ly',
      'isPlaying': false,
    },
    {
      'title': 'Ryokan key guide instructions.mp3',
      'duration': '0:28',
      'sender': '@alex_escapes',
      'isPlaying': false,
    }
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgGradStart = isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final bgGradEnd = isDark ? const Color(0xFF151926) : const Color(0xFFF3EFE9);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradStart, bgGradEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Settings Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Media Gallery',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        color: textPrimary,
                      ),
                      onPressed: widget.onThemeToggle,
                    ),
                  ],
                ),
              ),

              // Segmented Tab Selector
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cardBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                  ),
                ),
                child: Row(
                  children: [
                    _buildTabItem(0, '🖼️ Media'),
                    _buildTabItem(1, '🔗 Links'),
                    _buildTabItem(2, '🎙️ Voice'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Active Tab Contents
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _activeTab == 0
                        ? _buildPhotosTab(isDark, cardBg, textPrimary, textSecondary, primaryColor)
                        : _activeTab == 1
                            ? _buildLinksTab(isDark, cardBg, textPrimary, textSecondary, primaryColor)
                            : _buildVoiceTab(isDark, cardBg, textPrimary, textSecondary, primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _activeTab == index;
    final isDark = widget.isDarkMode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // PHOTOS & VIDEOS TAB
  Widget _buildPhotosTab(
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color themeColor,
  ) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: _mediaItems.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: cardBg,
            child: Image.network(
              _mediaItems[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.broken_image));
              },
            ),
          ),
        );
      },
    );
  }

  // LINKS TAB
  Widget _buildLinksTab(
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color themeColor,
  ) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _links.length,
      itemBuilder: (context, index) {
        final link = _links[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  link['icon']!,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link['title']!,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      link['url']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Shared by ${link['sender']}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // VOICE SNAPS TAB
  Widget _buildVoiceTab(
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color themeColor,
  ) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _voiceSnaps.length,
      itemBuilder: (context, index) {
        final snap = _voiceSnaps[index];
        final isPlaying = snap['isPlaying'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: themeColor,
                  size: 36,
                ),
                onPressed: () {
                  setState(() {
                    _voiceSnaps[index]['isPlaying'] = !isPlaying;
                  });
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snap['title'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Waveform simulation
                    Row(
                      children: List.generate(15, (waveIdx) {
                        final waveHeights = [8, 12, 24, 18, 6, 14, 28, 20, 10, 16, 24, 8, 12, 14, 6];
                        final h = waveHeights[waveIdx];
                        return Container(
                          width: 3,
                          height: (isPlaying ? (h * 1.2) : h).toDouble(),
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            color: isPlaying ? themeColor : textSecondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sender: ${snap['sender']}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: textSecondary,
                          ),
                        ),
                        Text(
                          snap['duration'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
