import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../core/format/money.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../expense_tracker/application/expenses_providers.dart';
import '../../expense_tracker/domain/expense.dart';
import '../../gamification/data/games_repository.dart';
import '../../moments/data/trip_recap_repository.dart';
import '../../trips/application/trips_providers.dart';
import '../data/ai_repository.dart';

/// Trợ lý ngân sách.
///
/// Trước đây màn này in cứng "Total Financial Damage $1,420.69" và "Remaining
/// $579.31" — bằng đô la, trong khi app chạy tiền Việt — cho mọi chuyến và mọi
/// tài khoản, kể cả người chưa ghi khoản chi nào. Nay số liệu lấy từ
/// `/trips/:id/recap` (tổng đã chi thật) và ngân sách đặt cho chuyến.
class AiBudgetAssistantScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const AiBudgetAssistantScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  ConsumerState<AiBudgetAssistantScreen> createState() =>
      _AiBudgetAssistantScreenState();
}

class _AiBudgetAssistantScreenState
    extends ConsumerState<AiBudgetAssistantScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _marqueeController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _marqueeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final surfaceHigh = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final primary = isDark ? GenZTokens.lilac : GenZTokens.purple;
    final secondary = GenZTokens.green;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textMuted = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final errorColor = GenZTokens.danger;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Aurora background
          Positioned.fill(
            child: CustomPaint(
              painter: _AuroraPainter(
                isDark: isDark,
                primary: primary,
                secondary: secondary,
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(textPrimary, primary, secondary, isDark),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        // Hero: Matey orb + total damage
                        _buildHeroSection(
                          primary,
                          secondary,
                          textPrimary,
                          textMuted,
                          errorColor,
                          isDark,
                        ),
                        const SizedBox(height: 24),
                        // Marquee ticker
                        if (_roast != null) ...[
                          _buildMarquee(secondary, textMuted, surface, isDark),
                          const SizedBox(height: 24),
                        ],
                        // Insights grid
                        _buildInsightsGrid(
                          primary,
                          secondary,
                          textPrimary,
                          textMuted,
                          errorColor,
                          surface,
                          surfaceHigh,
                          isDark,
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

  /// Roast do AI viết cho chuyến này — provider tự cache theo chuyến.
  String? get _roast {
    final id = ref.watch(activeTripIdProvider);
    if (id == null) return null;
    return ref
        .watch(expenseRoastProvider(id))
        .maybeWhen(data: (r) => r?.$1, orElse: () => null);
  }

  /// Chuyến đã đặt ngân sách chưa — chưa đặt thì đừng hiện "0% đã dùng"
  /// như thể đã có ngân sách.
  bool get _hasBudget {
    final id = ref.watch(activeTripIdProvider);
    if (id == null) return false;
    return ref
        .watch(tripsProvider)
        .maybeWhen(
          data: (trips) {
            for (final t in trips) {
              if (t.id == id) return (t.budget ?? 0) > 0;
            }
            return false;
          },
          orElse: () => false,
        );
  }

  /// % ngân sách đã dùng — 0 khi chuyến chưa đặt ngân sách.
  int get _budgetUsedPct {
    final id = ref.watch(activeTripIdProvider);
    if (id == null) return 0;
    final budget = ref
        .watch(tripsProvider)
        .maybeWhen(
          data: (trips) {
            for (final t in trips) {
              if (t.id == id) return t.budget ?? 0;
            }
            return 0.0;
          },
          orElse: () => 0.0,
        );
    if (budget <= 0) return 0;
    final pct = (_totalSpent / budget * 100).round();
    return pct.clamp(0, 100);
  }

  /// Nhịp chi suy từ % ngân sách đã dùng, thay vì luôn ghi "Nhanh".
  String _paceLabel() {
    if (!_hasBudget) return 'ai.budget_pace_na'.tr();
    final p = _budgetUsedPct;
    if (p >= 75) return 'ai.budget_pace_fast'.tr();
    if (p >= 40) return 'ai.budget_pace_ok'.tr();
    return 'ai.budget_pace_slow'.tr();
  }

  /// Hạng mục chi nhiều nhất của chuyến: (tên, số tiền, % trên tổng).
  (String, double, int)? get _topCategory {
    final id = ref.watch(activeTripIdProvider);
    if (id == null) return null;
    final list = ref
        .watch(tripExpensesProvider(id))
        .maybeWhen(data: (e) => e, orElse: () => const <Expense>[]);
    if (list.isEmpty) return null;

    final byCat = <String, double>{};
    var total = 0.0;
    for (final e in list) {
      byCat[e.category] = (byCat[e.category] ?? 0) + e.amount;
      total += e.amount;
    }
    if (total <= 0) return null;

    var topName = byCat.keys.first;
    var topAmount = byCat[topName]!;
    byCat.forEach((k, v) {
      if (v > topAmount) {
        topName = k;
        topAmount = v;
      }
    });
    return (topName, topAmount, ((topAmount / total) * 100).round());
  }

  /// Tổng đã chi của chuyến đang mở — 0 khi chưa có chuyến/khoản chi nào.
  double get _totalSpent {
    final id = ref.watch(activeTripIdProvider);
    if (id == null) return 0;
    return ref
        .watch(tripRecapProvider(id))
        .maybeWhen(data: (r) => r.totalSpent, orElse: () => 0);
  }

  /// Còn lại = ngân sách đặt cho chuyến trừ đã chi. Chưa đặt ngân sách thì 0.
  double get _remaining {
    final id = ref.watch(activeTripIdProvider);
    if (id == null) return 0;
    final budget = ref
        .watch(tripsProvider)
        .maybeWhen(
          data: (trips) {
            for (final t in trips) {
              if (t.id == id) return t.budget ?? 0;
            }
            return 0.0;
          },
          orElse: () => 0.0,
        );
    final left = budget - _totalSpent;
    return left > 0 ? left : 0;
  }

  String get _currency {
    final id = ref.watch(activeTripIdProvider);
    if (id == null) return 'VND';
    return ref
        .watch(tripRecapProvider(id))
        .maybeWhen(data: (r) => r.currency, orElse: () => 'VND');
  }

  /// FOOD -> "Ăn uống". Khóa lạ thì trả về nguyên khóa.
  String _categoryLabel(String key) {
    const map = {
      'ACCOMMODATION': 'expense.cat_stay',
      'FOOD': 'expense.cat_food',
      'TRANSPORT': 'expense.cat_transport',
      'ACTIVITIES': 'expense.cat_activities',
      'SHOPPING': 'expense.cat_shopping',
      'ENTERTAINMENT': 'expense.cat_entertainment',
      'OTHER': 'expense.cat_other',
    };
    final k = map[key.toUpperCase()];
    return k == null ? key : k.tr();
  }

  String _money(double v) {
    if (_currency != 'VND') return v.toStringAsFixed(2);
    return formatMoney(v, locale: context.locale.languageCode);
  }

  Widget _buildTopBar(
    Color textPrimary,
    Color primary,
    Color secondary,
    bool isDark,
  ) {
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: surface,
              border: Border.all(
                color: textPrimary,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Icon(
              PhosphorIcons.users(PhosphorIconsStyle.bold),
              color: primary,
              size: 18,
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) =>
                LinearGradient(colors: [primary, primary]).createShader(bounds),
            child: Text(
              'trip.mate',
              style: AppFonts.heading(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                color: textPrimary,
              ),
            ),
          ),
          Row(
            children: [
              if (widget.onThemeToggle != null)
                IconButton(
                  icon: Icon(
                    isDark
                        ? PhosphorIcons.sun(PhosphorIconsStyle.bold)
                        : PhosphorIcons.moon(PhosphorIconsStyle.bold),
                    color: textPrimary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: widget.onThemeToggle,
                  tooltip: isDark
                      ? 'theme.switch_light'.tr()
                      : 'theme.switch_dark'.tr(),
                ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: surface,
                  border: Border.all(
                    color: textPrimary,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Icon(
                  PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                  color: primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    Color primary,
    Color secondary,
    Color textPrimary,
    Color textMuted,
    Color errorColor,
    bool isDark,
  ) {
    return Column(
      children: [
        // Pulsing AI Orb
        ScaleTransition(
          scale: _pulseAnim,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary,
                  border: Border.all(
                    color: textPrimary,
                    width: GenZTokens.borderWidth,
                  ),
                  boxShadow: GenZTokens.hardShadow(textPrimary),
                ),
                child: Icon(
                  PhosphorIcons.robot(PhosphorIconsStyle.fill),
                  color: GenZTokens.paper,
                  size: 48,
                ),
              ),
              Positioned(
                top: -8,
                right: -16,
                child: Transform.rotate(
                  angle: 12 * math.pi / 180,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: GenZTokens.danger,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: textPrimary,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                    child: Text(
                      'ai.judging_you'.tr(),
                      style: AppFonts.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: GenZTokens.paper,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'ai.budget_total'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textMuted,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currency == 'VND' ? '' : '\$',
              style: AppFonts.heading(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: primary,
              ),
            ),
            Text(
              _money(_totalSpent),
              style: AppFonts.heading(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                letterSpacing: -2,
                color: textPrimary,
                shadows: [
                  Shadow(color: primary.withValues(alpha: 0.6), blurRadius: 0),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarquee(
    Color secondary,
    Color textMuted,
    Color surface,
    bool isDark,
  ) {
    final tickerText = '${_roast!}  •  ';
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: secondary,
            width: GenZTokens.borderWidthThin,
          ),
        ),
        child: Row(
          children: [
            // Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: surface,
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.megaphone(PhosphorIconsStyle.fill),
                    color: secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ai.matey_says'.tr(),
                    style: AppFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _marqueeController,
                builder: (ctx, child) {
                  return ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionalTranslation(
                        translation: Offset(
                          1.0 - _marqueeController.value * 2.0,
                          0,
                        ),
                        child: Text(
                          tickerText + tickerText,
                          maxLines: 1,
                          style: AppFonts.body(
                            fontSize: 13,
                            color: textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsGrid(
    Color primary,
    Color secondary,
    Color textPrimary,
    Color textMuted,
    Color errorColor,
    Color surface,
    Color surfaceHigh,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Critical Insight card
        Expanded(
          child: _glassCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.flame(PhosphorIconsStyle.fill),
                      color: errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'ai.critical_insight'.tr(),
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (_) {
                    final top = _topCategory;
                    if (top == null) {
                      return Text(
                        'ai.budget_no_expense'.tr(),
                        style: AppFonts.heading(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                          height: 1.4,
                        ),
                      );
                    }
                    return RichText(
                      text: TextSpan(
                        style: AppFonts.heading(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: '${'ai.budget_top_pre'.tr()} '),
                          TextSpan(
                            text: '${top.$3}%',
                            style: AppFonts.heading(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: errorColor,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' ${'ai.budget_top_post'.tr(args: [_categoryLabel(top.$1), _money(top.$2)])}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Vibe Check / Budget meter card
        Expanded(
          child: _glassCard(
            isDark: isDark,
            glowColor: primary,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'ai.vibe_check'.tr(),
                    style: AppFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Circular progress
                SizedBox(
                  width: 120,
                  height: 120,
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (ctx, child) {
                      return CustomPaint(
                        painter: _CircularProgressPainter(
                          progress:
                              _progressController.value *
                              (_budgetUsedPct / 100),
                          trackColor: isDark
                              ? GenZTokens.paperDark
                              : GenZTokens.cream,
                          progressColor: GenZTokens.green,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _hasBudget ? '$_budgetUsedPct%' : '—',
                                style: AppFonts.heading(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                              Text(
                                _hasBudget
                                    ? 'ai.budget_used'.tr()
                                    : 'ai.budget_unset'.tr(),
                                style: AppFonts.body(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: GenZTokens.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'ai.remaining'.tr(),
                          style: AppFonts.body(fontSize: 12, color: textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _hasBudget ? _money(_remaining) : '—',
                          style: AppFonts.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'ai.budget_pace'.tr(),
                          style: AppFonts.body(fontSize: 12, color: textMuted),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.trendUp(PhosphorIconsStyle.bold),
                              size: 14,
                              color: errorColor,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _paceLabel(),
                              style: AppFonts.body(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: errorColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassCard({
    required bool isDark,
    required Widget child,
    Color? glowColor,
  }) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? ink).withValues(alpha: 0.18),
            blurRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final bool isDark;
  final Color primary;
  final Color secondary;

  _AuroraPainter({
    required this.isDark,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..shader = RadialGradient(
        colors: [primary.withValues(alpha: 0.15), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.15, size.height * 0.3),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawRect(Offset.zero & size, p1);

    final p2 = Paint()
      ..shader = RadialGradient(
        colors: [secondary.withValues(alpha: 0.1), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.85, size.height * 0.7),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawRect(Offset.zero & size, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    const strokeWidth = 10.0;
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter old) =>
      old.progress != progress;
}
