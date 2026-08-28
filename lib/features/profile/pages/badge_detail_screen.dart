import 'dart:ui';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../../core/app_messenger.dart';
import 'package:google_fonts/google_fonts.dart';

class BadgeDetailScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;
  final String? badgeName;
  final bool? unlocked;

  const BadgeDetailScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
    this.badgeName,
    this.unlocked,
  });

  @override
  State<BadgeDetailScreen> createState() => _BadgeDetailScreenState();
}

class _BadgeDetailScreenState extends State<BadgeDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _rotateController;
  late Animation<double> _glowAnim;
  late Animation<double> _rotateAnim;

  final List<Map<String, dynamic>> _requirements = const [
    {'done': true, 'label': 'Spend 10m+ on midnight snacks'},
    {'done': true, 'label': 'Trigger 5+ unplanned detours'},
    {
      'done': false,
      'label': 'Survive a 24h travel streak',
      'suffix': '(In Progress)',
    },
  ];

  final List<Map<String, dynamic>> _timeline = const [
    {
      'level': 'Level 3: Chaos Agent',
      'trip': '"Berlin Weekend Bender"',
      'date': 'Oct 12',
    },
    {
      'level': 'Level 2: Wildcard',
      'trip': '"Roadtrip to Nowhere"',
      'date': 'Aug 04',
    },
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _glowAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _rotateAnim = Tween<double>(begin: 0, end: 6.28).animate(_rotateController);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bg = isDark ? const Color(0xFF080818) : const Color(0xFFF0EEFF);
    final surface = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.75);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFF1A1A2E).withValues(alpha: 0.55);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Ambient blobs
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(color: Colors.transparent),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      _buildGlassButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Badge Detail',
                          style: AppFonts.heading(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      _buildGlassButton(
                        icon: isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        onTap: widget.onThemeToggle ?? () {},
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildGlassButton(
                        icon: Icons.more_horiz,
                        onTap: () => showGlobalSnack(
                          'Tính năng đang được hoàn thiện 🚧',
                        ),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Badge hero
                        AnimatedBuilder(
                          animation: _glowAnim,
                          builder: (context, child) => Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow ring
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7B2FF7).withValues(
                                        alpha: 0.35 * _glowAnim.value,
                                      ),
                                      blurRadius: 0,
                                      spreadRadius: 10,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFC9B8FF).withValues(
                                        alpha: 0.2 * _glowAnim.value,
                                      ),
                                      blurRadius: 0,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                              // Rotating ring
                              AnimatedBuilder(
                                animation: _rotateAnim,
                                builder: (context, child) => Transform.rotate(
                                  angle: _rotateAnim.value,
                                  child: Container(
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFC9B8FF),
                                        width: 2,
                                      ),
                                    ),
                                    child: CustomPaint(
                                      painter: _DashedCirclePainter(
                                        color: const Color(
                                          0xFFC9B8FF,
                                        ).withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Badge circle
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF7B2FF7),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.local_fire_department,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Legendary badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.stars,
                              size: 16,
                              color: Color(0xFFFFD700),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Legendary',
                              style: AppFonts.heading(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'your chaos has evolved ✨',
                          style: AppFonts.heading(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'travel personality unlocked.',
                          style: AppFonts.body(
                            fontSize: 14,
                            color: textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // XP Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Level 4',
                                            style: AppFonts.heading(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: textSecondary,
                                            ),
                                          ),
                                          Text(
                                            'Chaos King',
                                            style: AppFonts.heading(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                          color: Color(0xFF7B2FF7),
                                        ),
                                        child: Text(
                                          '2,450 / 3,000 XP',
                                          style: AppFonts.heading(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: LinearProgressIndicator(
                                      value: 2450 / 3000,
                                      minHeight: 8,
                                      backgroundColor: const Color(
                                        0xFFC9B8FF,
                                      ).withValues(alpha: 0.12),
                                      valueColor: const AlwaysStoppedAnimation(
                                        Color(0xFFC9B8FF),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '550 XP to Level 5: God of Chaos',
                                    style: AppFonts.body(
                                      fontSize: 12,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Requirements
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.task_alt,
                                        size: 18,
                                        color: Color(0xFF1FA85C),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Requirements',
                                        style: AppFonts.heading(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  ...List.generate(_requirements.length, (i) {
                                    final req = _requirements[i];
                                    final done = req['done'] as bool;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            done
                                                ? Icons.check_circle
                                                : Icons.lock_outline,
                                            size: 18,
                                            color: done
                                                ? const Color(0xFF1FA85C)
                                                : textSecondary,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              req['label'] as String,
                                              style: AppFonts.body(
                                                fontSize: 13,
                                                color: done
                                                    ? textPrimary
                                                    : textSecondary,
                                                fontWeight: done
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (req.containsKey('suffix'))
                                            Text(
                                              req['suffix'] as String,
                                              style: AppFonts.body(
                                                fontSize: 11,
                                                color: const Color(0xFFFFD700),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Squad Stat
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.group,
                                        size: 18,
                                        color: Color(0xFFC9B8FF),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Squad Stat',
                                        style: AppFonts.heading(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Only 3% of squads achieve this.',
                                    style: AppFonts.body(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      _buildAvatar('Sarah'),
                                      const SizedBox(width: 8),
                                      _buildAvatar('Mike'),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Also earned this badge',
                                        style: AppFonts.body(
                                          fontSize: 12,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Achievement Timeline
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Achievement Timeline',
                                    style: AppFonts.heading(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  ...List.generate(_timeline.length, (i) {
                                    final item = _timeline[i];
                                    final isLast = i == _timeline.length - 1;
                                    return IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFFC9B8FF),
                                                ),
                                              ),
                                              if (!isLast)
                                                Expanded(
                                                  child: Container(
                                                    width: 2,
                                                    color: const Color(
                                                      0xFFC9B8FF,
                                                    ).withValues(alpha: 0.2),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                bottom: isLast ? 0 : 16,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        item['level'] as String,
                                                        style:
                                                            GoogleFonts.plusJakartaSans(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  textPrimary,
                                                            ),
                                                      ),
                                                      Text(
                                                        item['date'] as String,
                                                        style:
                                                            AppFonts.body(
                                                              fontSize: 11,
                                                              color:
                                                                  textSecondary,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Unlocked during ${item['trip']}',
                                                    style: AppFonts.body(
                                                      fontSize: 12,
                                                      color: textSecondary,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _glowAnim,
                                builder: (context, child) => Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Color(0xFF7B2FF7),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF7B2FF7)
                                            .withValues(
                                              alpha: 0.4 * _glowAnim.value,
                                            ),
                                        blurRadius: 0,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(100),
                                      onTap: () => showGlobalSnack(
                                        'Tính năng đang được hoàn thiện 🚧',
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.ios_share,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Share the Glory',
                                              style: AppFonts.heading(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: OutlinedButton.icon(
                                  onPressed: () => showGlobalSnack(
                                    'Tính năng đang được hoàn thiện 🚧',
                                  ),
                                  icon: const Icon(
                                    Icons.person_add_outlined,
                                    size: 18,
                                    color: Color(0xFFC9B8FF),
                                  ),
                                  label: Text(
                                    'Equip to Profile',
                                    style: AppFonts.heading(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFC9B8FF),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: const Color(
                                        0xFFC9B8FF,
                                      ).withValues(alpha: 0.4),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF7B2FF7),
          ),
          child: Center(
            child: Text(
              name[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.05),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const dashCount = 16;
    const dashAngle = 6.28 / dashCount;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        final startAngle = i * dashAngle;
        final sweepAngle = dashAngle * 0.6;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
