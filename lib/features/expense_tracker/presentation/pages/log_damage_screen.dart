import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'expense_splitter_social_screen.dart';

class LogDamageScreen extends StatefulWidget {
  final bool? isDarkMode;
  const LogDamageScreen({super.key, this.isDarkMode});

  @override
  State<LogDamageScreen> createState() => _LogDamageScreenState();
}

class _LogDamageScreenState extends State<LogDamageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '300000');
  final _descriptionController = TextEditingController(text: 'Ăn uống BBQ xả láng 🍖');

  String _selectedCategory = 'BBQ';
  String _selectedSplitType = 'CUSTOM'; // EQUAL vs CUSTOM

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'BBQ',
      'label': 'BBQ 🍖',
      'icon': Icons.restaurant,
      'color': const Color(0xFFE0533C),
    },
    {
      'name': 'GRAB',
      'label': 'Grab 🚕',
      'icon': Icons.local_taxi,
      'color': const Color(0xFF34D399),
    },
    {
      'name': 'HOTEL',
      'label': 'Nơi ở 🏠',
      'icon': Icons.hotel,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'name': 'ACTIVITIES',
      'label': 'Vui chơi 🎢',
      'icon': Icons.local_activity,
      'color': const Color(0xFFFB923C),
    },
    {
      'name': 'OTHER',
      'label': 'Khác 🛍️',
      'icon': Icons.category,
      'color': const Color(0xFF94A3B8),
    },
  ];

  final List<Map<String, dynamic>> _members = [
    {
      'id': '1',
      'name': 'You (Bạn)',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=You',
      'role': 'Chủ xị 👑',
      'amount': 150000.0,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'id': '2',
      'name': 'Alex M.',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alex',
      'role': 'Tay chơi 🕶️',
      'amount': 100000.0,
      'color': const Color(0xFF06B6D4),
    },
    {
      'id': '3',
      'name': 'Sarah K.',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah',
      'role': 'Mầm non 🍼',
      'amount': 50000.0,
      'color': const Color(0xFFEBA83A),
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _calculateSplits() {
    final double total = double.tryParse(_amountController.text) ?? 0.0;
    if (_selectedSplitType == 'EQUAL') {
      final perPerson = total / _members.length;
      for (var member in _members) {
        member['amount'] = perPerson;
      }
    } else {
      // CUSTOM split type
      // Default: You = 150k, Alex M. = 100k, Sarah K. = 50k (ratio: 3/6, 2/6, 1/6)
      if (total == 300000.0) {
        _members[0]['amount'] = 150000.0;
        _members[1]['amount'] = 100000.0;
        _members[2]['amount'] = 50000.0;
      } else {
        // Proportionate distribution based on standard ratio
        _members[0]['amount'] = total * (3.0 / 6.0);
        _members[1]['amount'] = total * (2.0 / 6.0);
        _members[2]['amount'] = total * (1.0 / 6.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _calculateSplits();
    final theme = Theme.of(context);
    final bool isDark = widget.isDarkMode ?? (theme.brightness == Brightness.dark);

    // Color Palette
    final darkBg = const Color(0xFF0B1326);
    final darkSurface = const Color(0xFF171F33);
    final darkPrimary = const Color(0xFF8B5CF6);
    final darkSecondary = const Color(0xFF34D399);

    final lightBg = const Color(0xFFFCFAF6);
    final lightSurface = Colors.white;
    final lightPrimary = const Color(0xFFE0533C);
    final lightSecondary = const Color(0xFFEBA83A);

    final bgColor = isDark ? darkBg : lightBg;
    final surfaceColor = isDark ? darkSurface : lightSurface;
    final primaryColor = isDark ? darkPrimary : lightPrimary;
    final secondaryColor = isDark ? darkSecondary : lightSecondary;
    final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E2022);
    final textSecondaryColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF686D76);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textColor, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'expense.log_damage_title'.tr(),
          style: GoogleFonts.plusJakartaSans(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Gradient Orbs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70.0, sigmaY: 70.0),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor.withValues(alpha: 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount & Description Glass Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? surfaceColor.withValues(alpha: 0.65)
                              : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'expense.total_damage_wallet'.tr(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textSecondaryColor,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                // Glowing Rounded Scan Receipt Button
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: LinearGradient(
                                      colors: [primaryColor, secondaryColor],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30),
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(Icons.psychology, color: Colors.white),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'expense.scanning_invoice'.tr(),
                                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: primaryColor,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.qr_code_scanner_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Scan Receipt AI ⚡',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
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
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: primaryColor,
                                      letterSpacing: -1,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '0',
                                    ),
                                    onChanged: (val) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'expense.currency'.tr(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descriptionController,
                              style: GoogleFonts.inter(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'expense.desc_placeholder'.tr(),
                                hintStyle: GoogleFonts.inter(
                                  color: textSecondaryColor.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(Icons.mode_edit_outline_outlined, color: primaryColor, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: isDark ? bgColor.withValues(alpha: 0.5) : Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Categories Selector Row
                  Text(
                    'expense.spend_category'.tr(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textSecondaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 96,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat['name'];
                        final Color catColor = cat['color'] as Color;
                        
                        final String localizedCat = cat['name'] == 'BBQ'
                            ? 'BBQ 🍖'
                            : (cat['name'] == 'GRAB'
                                ? 'Grab 🚕'
                                : (cat['name'] == 'HOTEL'
                                    ? 'expense.cat_housing'.tr()
                                    : (cat['name'] == 'ACTIVITIES'
                                        ? 'expense.cat_entertainment'.tr()
                                        : 'expense.cat_others'.tr())));

                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = cat['name'];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              width: 96,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? catColor.withValues(alpha: isDark ? 0.2 : 0.15)
                                    : surfaceColor.withValues(alpha: isDark ? 0.6 : 0.8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? catColor
                                      : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
                                  width: isSelected ? 2 : 1.2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: catColor.withValues(alpha: 0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    cat['icon'] as IconData,
                                    color: isSelected ? catColor : textSecondaryColor,
                                    size: 26,
                                  ),
                                  const SizedBox(height: 8),
                                  FittedBox(
                                    child: Text(
                                      localizedCat,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isSelected ? catColor : textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Selector Tabs (Equal vs Custom)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'expense.split_method'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textSecondaryColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Sliding Pills for Tab Selector (Equal vs Custom)
                  Container(
                    height: 52,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? surfaceColor.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSplitType = 'EQUAL';
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.fastOutSlowIn,
                              decoration: BoxDecoration(
                                color: _selectedSplitType == 'EQUAL'
                                    ? (isDark ? primaryColor : primaryColor)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _selectedSplitType == 'EQUAL'
                                    ? [
                                        BoxShadow(
                                          color: primaryColor.withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'expense.split_equally'.tr(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _selectedSplitType == 'EQUAL'
                                      ? Colors.white
                                      : textSecondaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSplitType = 'CUSTOM';
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.fastOutSlowIn,
                              decoration: BoxDecoration(
                                color: _selectedSplitType == 'CUSTOM'
                                    ? (isDark ? primaryColor : primaryColor)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _selectedSplitType == 'CUSTOM'
                                    ? [
                                        BoxShadow(
                                          color: primaryColor.withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'expense.split_custom'.tr(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _selectedSplitType == 'CUSTOM'
                                      ? Colors.white
                                      : textSecondaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Detailed Victims List Glass Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: isDark
                              ? surfaceColor.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'expense.victims_list'.tr(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textSecondaryColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: secondaryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'expense.members_count'.tr(args: ['${_members.length}']),
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: secondaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _members.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 24,
                                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                              ),
                              itemBuilder: (context, index) {
                                final member = _members[index];
                                final Color memColor = member['color'] as Color;

                                final String localizedRole = member['role'] == 'Chủ xị 👑'
                                    ? 'expense.role_host'.tr()
                                    : (member['role'] == 'Tay chơi 🕶️' ? 'expense.role_player'.tr() : 'expense.role_kid'.tr());

                                return Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: memColor, width: 2),
                                      ),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: memColor.withValues(alpha: 0.1),
                                        child: ClipOval(
                                          child: Image.network(
                                            member['avatar']!,
                                            errorBuilder: (context, error, stackTrace) => Text(
                                              member['name']!.substring(0, 1),
                                              style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.bold,
                                                color: memColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            member['name']!,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: memColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              localizedRole,
                                              style: GoogleFonts.inter(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color: memColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${(member['amount'] as double).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w900,
                                            color: primaryColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _selectedSplitType == 'EQUAL'
                                              ? 'expense.equally_percent'.tr()
                                              : (index == 0
                                                  ? 'expense.custom_percent_host'.tr()
                                                  : (index == 1 ? 'expense.custom_percent_member'.tr() : 'expense.custom_percent_others'.tr())),
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: textSecondaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // High-contrast neo-brutalism styled Action buttons
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black : primaryColor.withValues(alpha: 0.35),
                          offset: const Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.celebration, color: Colors.white),
                                const SizedBox(width: 12),
                                Text(
                                  'expense.log_damage_success'.tr(),
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'expense.submit_split'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black : secondaryColor.withValues(alpha: 0.25),
                          offset: const Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ExpenseSplitterSocialScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: surfaceColor,
                        side: const BorderSide(color: Colors.black, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.gamepad_outlined, color: primaryColor, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'expense.who_pays_wheel'.tr(),
                            style: GoogleFonts.plusJakartaSans(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
