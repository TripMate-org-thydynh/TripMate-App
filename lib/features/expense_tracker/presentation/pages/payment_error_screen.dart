import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentErrorScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback? onRetry;

  const PaymentErrorScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    this.onRetry,
  });

  @override
  State<PaymentErrorScreen> createState() => _PaymentErrorScreenState();
}

class _PaymentErrorScreenState extends State<PaymentErrorScreen>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _errorGlowController;
  late Animation<double> _shakeAnim;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
    _errorGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Trigger shake on load
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _shakeController.forward();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _errorGlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final errorColor = const Color(0xFFFF3B5C);
    final warningColor = const Color(0xFFFF9F0A);
    final bgColor = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final cardBg = isDark ? const Color(0xFF1A2340) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // GLASS APP BAR
            _buildAppBar(isDark, errorColor, textPrimary),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ERROR ICON WITH SHAKE ANIMATION
                    AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(
                          6 * _shakeAnim.value * (1 - _shakeAnim.value) * 4 * (2 * (0.5 - (_shakeAnim.value % 1)).abs()),
                          0,
                        ),
                        child: _buildErrorOrb(isDark, errorColor),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // "PAYMENT FAILED" TITLE
                    Text(
                      'Payment Failed',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: errorColor,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your transaction couldn\'t be processed.',
                      style: GoogleFonts.inter(fontSize: 15, color: textMuted, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // ERROR DETAIL CARD
                    _buildErrorCard(isDark, errorColor, warningColor, cardBg, textPrimary, textMuted),
                    const SizedBox(height: 20),

                    // PAYMENT DETAILS
                    _buildPaymentDetails(isDark, cardBg, textPrimary, textMuted),
                    const SizedBox(height: 32),

                    // RETRY BUTTON
                    GestureDetector(
                      onTap: () {
                        setState(() => _isRetrying = true);
                        _shakeController.reset();
                        final messenger = ScaffoldMessenger.of(context);
                        Future.delayed(const Duration(seconds: 2), () {
                          if (!mounted) return;
                          setState(() => _isRetrying = false);
                          if (widget.onRetry != null) {
                            widget.onRetry!();
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Retrying payment...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        });
                      },
                      child: AnimatedBuilder(
                        animation: _errorGlowController,
                        builder: (_, child) => Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: _isRetrying ? Colors.grey.withValues(alpha: 0.3) : errorColor,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: _isRetrying
                                ? []
                                : [
                                    BoxShadow(
                                      color: errorColor.withValues(alpha: 0.3 + 0.15 * _errorGlowController.value),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                          ),
                          child: Center(
                            child: _isRetrying
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.refresh, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Retry Payment',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // USE DIFFERENT METHOD LINK
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening payment options...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.12),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Use a Different Method',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark, Color errorColor, Color textPrimary) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x800B1326) : const Color(0x9EFFFFFF),
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 18),
              ),
              Text(
                'trip.mate',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: errorColor,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOrb(bool isDark, Color errorColor) {
    return AnimatedBuilder(
      animation: _errorGlowController,
      builder: (_, child) => Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: errorColor.withValues(alpha: 0.1),
          border: Border.all(
            color: errorColor.withValues(alpha: 0.3 + 0.2 * _errorGlowController.value),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: errorColor.withValues(alpha: 0.2 + 0.15 * _errorGlowController.value),
              blurRadius: 30,
              spreadRadius: 5,
            )
          ],
        ),
        child: const Icon(
          Icons.credit_card_off_rounded,
          color: Color(0xFFFF3B5C),
          size: 56,
        ),
      ),
    );
  }

  Widget _buildErrorCard(bool isDark, Color errorColor, Color warningColor, Color cardBg, Color textPrimary, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: errorColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: errorColor, size: 20),
              const SizedBox(width: 10),
              Text(
                'Error Code: PSP_001',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Your bank declined this transaction. This could be due to insufficient funds, a card limit, or a temporary block.',
            style: GoogleFonts.inter(fontSize: 13, color: textMuted, height: 1.5),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: warningColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: warningColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tip: Try a different card or contact your bank.',
                    style: GoogleFonts.inter(fontSize: 12, color: warningColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(bool isDark, Color cardBg, Color textPrimary, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow('Amount', '850,000 ₫', textPrimary, textMuted),
          const Divider(height: 20),
          _buildDetailRow('Recipient', 'Nam Trung', textPrimary, textMuted),
          const Divider(height: 20),
          _buildDetailRow('Category', 'Accommodation Split', textPrimary, textMuted),
          const Divider(height: 20),
          _buildDetailRow('Method', '**** 4242 Visa', textPrimary, textMuted),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color textPrimary, Color textMuted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: textMuted)),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
        ),
      ],
    );
  }
}
