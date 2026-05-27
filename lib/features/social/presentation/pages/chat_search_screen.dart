import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatSearchScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const ChatSearchScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<Map<String, String>> _allMessages = [
    {
      'user': '@alex_escapes',
      'avatar': '🦊',
      'content': 'We should check out the Fushimi Inari vermilion gates early tomorrow! Who is down?',
      'time': 'Yesterday • 4:15 PM',
    },
    {
      'user': '@minh_nhat',
      'avatar': '🐱',
      'content': 'Guys, Nishiki Market street food is absolutely calling our name. Mochi first or takoyaki first?',
      'time': 'Yesterday • 6:30 PM',
    },
    {
      'user': '@thao_ly',
      'avatar': '🦄',
      'content': 'I just found this specialty cafe called Still Cafe, it has a gorgeous garden. Major Kyoto aesthetic!',
      'time': 'Today • 9:20 AM',
    },
    {
      'user': '@nam_trung',
      'avatar': '🦖',
      'content': 'Fushimi Inari is amazing but let\'s make sure we bring plenty of water, that 10k gates climb is no joke.',
      'time': 'Today • 10:45 AM',
    },
    {
      'user': '@alex_escapes',
      'avatar': '🦊',
      'content': 'I am muting the channel if anyone argues about who gets which scooter again. Let\'s keep it chill!',
      'time': 'Today • 11:15 AM',
    }
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgGradStart = isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final bgGradEnd = isDark ? const Color(0xFF151926) : const Color(0xFFF3EFE9);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);

    // Search filter
    final filtered = _allMessages.where((msg) {
      if (_query.isEmpty) return false;
      return msg['content']!.toLowerCase().contains(_query.toLowerCase()) ||
          msg['user']!.toLowerCase().contains(_query.toLowerCase());
    }).toList();

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
              // Search Input Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: cardBg.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search chat history...',
                            hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: primaryColor),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _query = '';
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _query = val;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search results or pre-search state
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _query.isEmpty
                      ? _buildSearchSuggestions(textPrimary, textSecondary, primaryColor)
                      : filtered.isEmpty
                          ? _buildEmptyResults(textPrimary, textSecondary, primaryColor)
                          : _buildResultsList(filtered, isDark, cardBg, textPrimary, textSecondary, primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions(
    Color textPrimary,
    Color textSecondary,
    Color themeColor,
  ) {
    final suggestions = ['Kyoto Cafe', 'Nishiki Market', 'Fushimi Inari', 'Grab Booking'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          '🔥 Recent Search Keywords',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: suggestions.map((sug) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _searchController.text = sug;
                  _query = sug;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  sug,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyResults(
    Color textPrimary,
    Color textSecondary,
    Color themeColor,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🔍🤷‍♂️',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'No matches found in history',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try searching for another vibe or location.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(
    List<Map<String, String>> results,
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color themeColor,
  ) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final msg = results[index];
        final content = msg['content']!;
        
        // Highlight query match
        final lowerContent = content.toLowerCase();
        final lowerQuery = _query.toLowerCase();
        final matchIdx = lowerContent.indexOf(lowerQuery);
        
        Widget textWidget;
        if (matchIdx != -1) {
          final prefix = content.substring(0, matchIdx);
          final match = content.substring(matchIdx, matchIdx + _query.length);
          final suffix = content.substring(matchIdx + _query.length);
          textWidget = RichText(
            text: TextSpan(
              style: GoogleFonts.inter(fontSize: 13, color: textPrimary, height: 1.4),
              children: [
                TextSpan(text: prefix),
                TextSpan(
                  text: match,
                  style: const TextStyle(
                    backgroundColor: Colors.amber,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: suffix),
              ],
            ),
          );
        } else {
          textWidget = Text(
            content,
            style: GoogleFonts.inter(fontSize: 13, color: textPrimary, height: 1.4),
          );
        }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        msg['avatar']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        msg['user']!,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    msg['time']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              textWidget,
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Jump to context',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 9, color: themeColor),
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
