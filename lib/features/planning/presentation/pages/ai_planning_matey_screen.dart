import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AIPlanningMateyScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const AIPlanningMateyScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<AIPlanningMateyScreen> createState() => _AIPlanningMateyScreenState();
}

class _AIPlanningMateyScreenState extends State<AIPlanningMateyScreen> with SingleTickerProviderStateMixin {
  bool _isGenerating = true;
  final List<String> _selectedParams = ['3-Day Weekend Trip', 'Deep Chill', 'Nature Focus'];

  final List<Map<String, String>> _allParams = [
    {'name': '3-Day Weekend Trip', 'emoji': '📅'},
    {'name': 'Deep Chill', 'emoji': '🌿'},
    {'name': 'High Energy', 'emoji': '🔥'},
    {'name': 'Nature Focus', 'emoji': '🏕'},
    {'name': 'City Exploration', 'emoji': '🌃'},
  ];

  final List<Map<String, dynamic>> _suggestions = [
    {
      'time': '09:00 AM',
      'title': 'Still Cafe',
      'desc': 'Japanese-style wooden house with quiet gardens.',
      'tag': 'Coffee',
      'match': '98% Crew Match',
    },
    {
      'time': '11:30 AM',
      'title': 'The Hill Station',
      'desc': 'Signature cold cuts and wine with a valley view.',
      'tag': 'Brunch',
      'match': '85% Crew Match',
    }
  ];

  @override
  void initState() {
    super.initState();
    _simulatePlanning();
  }

  void _simulatePlanning() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF06B6D4) : const Color(0xFFEBA83A);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6),
      appBar: AppBar(
        title: Text(
          'AI Squad Planner',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Matey Header Vibe Check
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isGenerating ? 'Matey is planning... 🤖' : 'Planning complete! ✨',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Đà Lạt Chill Escape Plan',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.green, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '92% Match',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Parameter selector
                Text(
                  'Squad Vibe Parameters',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _allParams.map((param) {
                    final isSelected = _selectedParams.contains(param['name']);
                    return GestureDetector(
                      onTap: _isGenerating
                          ? null
                          : () {
                              setState(() {
                                if (isSelected) {
                                  _selectedParams.remove(param['name']!);
                                } else {
                                  _selectedParams.add(param['name']!);
                                }
                              });
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withValues(alpha: 0.15)
                              : (isDark ? const Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? primaryColor : (isDark ? Colors.white10 : Colors.black12),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(param['emoji']!, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              param['name']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? primaryColor : (isDark ? Colors.white70 : Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Suggested schedule cards
                Text(
                  'Suggested Day 1 Suggestions',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _isGenerating
                      ? _buildLoadingStream(primaryColor)
                      : _buildSuggestionsList(primaryColor, secondaryColor, isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingStream(Color primaryColor) {
    return Column(
      key: const ValueKey('loading'),
      children: [
        const SizedBox(height: 40),
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Matey is drafting Day 1 schedule...',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSuggestionsList(Color primaryColor, Color secondaryColor, bool isDark) {
    return ListView.builder(
      key: const ValueKey('list'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final item = _suggestions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      item['match'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: secondaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item['time'],
                          style: TextStyle(
                            color: secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['desc'],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item['tag'],
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
