import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AICaptionGeneratorScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const AICaptionGeneratorScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<AICaptionGeneratorScreen> createState() => _AICaptionGeneratorScreenState();
}

class _AICaptionGeneratorScreenState extends State<AICaptionGeneratorScreen> {
  double _sarcasmLevel = 75.0;
  double _chaosLevel = 90.0;
  double _cozyLevel = 20.0;

  final List<String> _chips = ['rain ☔', 'coffee ☕', 'candid 📸', 'lost 🗺️', 'aesthetic ✨', 'scooter 🛵'];
  final Set<String> _selectedChips = {'coffee ☕', 'lost 🗺️'};

  bool _isGenerating = false;
  final List<Map<String, String>> _generatedCaptions = [
    {
      'vibe': '🤡 Chaotic Sarcasm',
      'text': 'We got lost in Kyoto station for the 4th time, almost missed the temple, but hey... look at this coffee pattern! Priorities, guys. 💀☕',
    },
    {
      'vibe': '🍵 Cozy Aesthetic',
      'text': 'Warm brews in a wooden Kyoto house. The rain outside can\'t compete with this cozy vibe. 🌿✨',
    },
    {
      'vibe': '🖋️ Handwritten Poetic',
      'text': 'Lost tracks, warm steam, Kyoto dreams romanticized by four tired souls.',
    }
  ];

  void _regenerateCaptions() {
    setState(() {
      _isGenerating = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        // Witty adjustments based on slider levels
        if (_sarcasmLevel > 80.0) {
          _generatedCaptions[0] = {
            'vibe': '🤡 Chaotic Sarcasm',
            'text': 'Who needs maps or sense of direction when you have a 100k coffee that took 40 mins to queue? Peak luxury failure. 💅☕',
          };
        } else {
          _generatedCaptions[0] = {
            'vibe': '🤡 Chaotic Sarcasm',
            'text': 'Kyoto ramen crawl: where we eat 5 times our body weight and pretend it was for the culture. 🍜🤡',
          };
        }

        if (_cozyLevel > 70.0) {
          _generatedCaptions[1] = {
            'vibe': '🍵 Cozy Aesthetic',
            'text': 'Rainy mornings call for tatami shadows, green tea whispers, and quiet reflections. 🍵🌧️',
          };
        } else {
          _generatedCaptions[1] = {
            'vibe': '🍵 Cozy Aesthetic',
            'text': 'Just standard coffee shop romanticism. Let us stay in this bubble forever. 🌿☕',
          };
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Matey AI computed fresh captions! 🧠⚡'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgGradStart = isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final bgGradEnd = isDark ? const Color(0xFF151926) : const Color(0xFFF3EFE9);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    final neonPink = const Color(0xFFFF2E93);
    final neonCyan = const Color(0xFF00F5FF);
    final neonAmber = const Color(0xFFFFB300);
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
              // Header
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
                          'AI Caption Generator',
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

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Preview Box
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: neonPink.withValues(alpha: 0.5), width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=300',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reference Moment:',
                                  style: GoogleFonts.outfit(fontSize: 12, color: textSecondary, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kyoto Food Crawl Coffee Break',
                                  style: GoogleFonts.outfit(fontSize: 14, color: textPrimary, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Auto-tagged by Matey AI as: #Nishiki #Coffee #Lost',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 10, color: neonCyan, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Matey AI Commentary Roast
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: neonAmber.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Text('🏴‍☠️🤖', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Matey\'s Roaster Advice:',
                                    style: GoogleFonts.outfit(fontSize: 11, color: neonAmber, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '"This photo screams \'we spent 45 minutes looking for coffee\'. Up that sarcasm slider, mate!"',
                                    style: GoogleFonts.caveat(fontSize: 15, color: textPrimary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sliders (Sarcasm, Chaos, Cozy)
                      Text('Customize Vibe Temper:', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                      const SizedBox(height: 12),
                      _buildSlider('🔥 Chaos Density', _chaosLevel, neonPink, (val) {
                        setState(() {
                          _chaosLevel = val;
                        });
                      }),
                      _buildSlider('💀 Sarcasm Quota', _sarcasmLevel, neonCyan, (val) {
                        setState(() {
                          _sarcasmLevel = val;
                        });
                      }),
                      _buildSlider('🌿 Cozy Aesthetic', _cozyLevel, neonAmber, (val) {
                        setState(() {
                          _cozyLevel = val;
                        });
                      }),

                      const SizedBox(height: 20),

                      // Keyword Chip Pills
                      Text('Keyword Chips:', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _chips.map((chip) {
                          final isSelected = _selectedChips.contains(chip);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedChips.remove(chip);
                                } else {
                                  _selectedChips.add(chip);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor : cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.black12),
                                ),
                              ),
                              child: Text(
                                chip,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 30),

                      // Generate Button
                      if (_isGenerating)
                        const Center(child: CircularProgressIndicator())
                      else
                        GestureDetector(
                          onTap: _regenerateCaptions,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [neonPink, neonPink.withValues(alpha: 0.8)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: neonPink.withValues(alpha: 0.25),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Generate AI Captions ⚡',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Output lists with copy/edit hooks
                      Text('Suggestions:', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                      const SizedBox(height: 12),
                      ..._generatedCaptions.map((cap) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      cap['vibe']!,
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.copy, color: neonCyan, size: 16),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Caption copied to clipboard! 📋✨'),
                                          backgroundColor: neonPink,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cap['text']!,
                                style: GoogleFonts.plusJakartaSans(color: textPrimary, fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double val, Color color, ValueChanged<double> onChanged) {
    final isDark = widget.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)),
            Text('${val.toInt()}%', style: GoogleFonts.outfit(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: val,
          min: 0.0,
          max: 100.0,
          activeColor: color,
          inactiveColor: isDark ? Colors.white12 : Colors.black12,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
