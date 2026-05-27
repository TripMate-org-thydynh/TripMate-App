import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiReceiptScannerScreen extends StatefulWidget {
  const AiReceiptScannerScreen({super.key});

  @override
  State<AiReceiptScannerScreen> createState() => _AiReceiptScannerScreenState();
}

class _AiReceiptScannerScreenState extends State<AiReceiptScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;

  bool _isScanning = true;

  final List<Map<String, dynamic>> _detectedItems = [
    {'name': 'Lẩu gà lá é lớn', 'price': 350000.0, 'checked': true},
    {'name': 'Nước ngọt lon', 'price': 60000.0, 'checked': true},
    {'name': 'Mì gói thêm', 'price': 20000.0, 'checked': false},
    {'name': 'Khăn lạnh', 'price': 10000.0, 'checked': false},
  ];

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );

    // Mock completing scan in 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF34D399) : const Color(0xFFEBA83A);
    final tertiaryColor = isDark ? const Color(0xFFFFB783) : const Color(0xFFF59E0B);
    
    final bgColor = isDark ? const Color(0xFF040914) : const Color(0xFFFCFAF6);
    final textPrimary = isDark ? const Color(0xFFDAE2FD) : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFFCBC3D7) : const Color(0xFF6B7280);
    final cardBg = isDark ? const Color(0xFF171F33) : Colors.white;

    final glassBorder = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Soft atmospheric light gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomLeft,
                  radius: 1.2,
                  colors: isDark
                      ? [const Color(0xFF3F1B68).withValues(alpha: 0.15), Colors.transparent]
                      : [const Color(0xFFF5EDFF).withValues(alpha: 0.4), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top header navigation bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'trip.mate',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                          letterSpacing: -1.5,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.receipt_long, color: primaryColor),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _isScanning
                        ? _buildScanningViewport(isDark, primaryColor, secondaryColor, textPrimary, textSecondary)
                        : _buildItemsBreakdown(isDark, primaryColor, secondaryColor, tertiaryColor, cardBg, glassBorder, textPrimary, textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Scanning Viewport with looping glowing laser bar
  Widget _buildScanningViewport(
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      key: const ValueKey('scanning_view'),
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: primaryColor.withValues(alpha: 0.6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.25),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Receipt mockup silhouette
                Opacity(
                  opacity: 0.25,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long, size: 100, color: Colors.white70),
                        const SizedBox(height: 12),
                        Text(
                          'TAO NGO CHICKEN...',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Moving scanning bar
                AnimatedBuilder(
                  animation: _scannerAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: _scannerAnimation.value * 280 + 40,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.8),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: secondaryColor.withValues(alpha: 0.6),
                              blurRadius: 15,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Floating loading glass box
                Positioned(
                  bottom: 32,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'AI is scanning items...',
                              style: GoogleFonts.plusJakartaSans(
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          child: Text(
            'Keep your bill steady inside the frame. Matey AI will parse items and prices instantly! ⚡',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
          ),
        ),
      ],
    );
  }

  // Scan Completed Item Checklist Breakdown
  Widget _buildItemsBreakdown(
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
    Color tertiaryColor,
    Color cardBg,
    Color glassBorder,
    Color textPrimary,
    Color textSecondary,
  ) {
    return SingleChildScrollView(
      key: const ValueKey('items_view'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Styled Success Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AI Scan Complete! (Accuracy 98%). Check the items you consumed to calculate splits.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Header Bill Info
          Text(
            'Lẩu gà lá é Tao Ngộ 🍜',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Dalat Old Market • Da Lat Trip',
            style: GoogleFonts.inter(fontSize: 12, color: textSecondary),
          ),
          const SizedBox(height: 18),

          // Bill breakdown items card
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: glassBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _detectedItems.length,
                  itemBuilder: (context, index) {
                    final item = _detectedItems[index];
                    final isChecked = item['checked'] as bool;
                    return Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: textSecondary,
                      ),
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: primaryColor,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          item['name'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${(item['price'] as double).toStringAsFixed(0)} đ',
                          style: GoogleFonts.outfit(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        value: isChecked,
                        onChanged: (bool? val) {
                          setState(() {
                            _detectedItems[index]['checked'] = val ?? false;
                          });
                        },
                      ),
                    );
                  },
                ),
                const Divider(height: 32, color: Colors.white10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Split Damage:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      '${_calculateTotalSelected().toStringAsFixed(0)} đ',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Sweeping linear gradient action button (Confirm Split check_circle)
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Split confirmed! Your damage is ${_calculateTotalSelected().toStringAsFixed(0)} đ settled! ✨🛒'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: secondaryColor,
                ),
              );
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor, tertiaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Confirm Split',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  double _calculateTotalSelected() {
    double sum = 0.0;
    for (var item in _detectedItems) {
      if (item['checked'] as bool) {
        sum += item['price'] as double;
      }
    }
    return sum;
  }
}
