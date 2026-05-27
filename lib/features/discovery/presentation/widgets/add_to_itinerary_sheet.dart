import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class AddToItinerarySheet extends StatefulWidget {
  final String placeName;
  final String placeAddress;
  final bool isDarkMode;
  final Function(Map<String, dynamic> itineraryData) onAdded;

  const AddToItinerarySheet({
    super.key,
    required this.placeName,
    required this.placeAddress,
    required this.isDarkMode,
    required this.onAdded,
  });

  @override
  State<AddToItinerarySheet> createState() => _AddToItinerarySheetState();
}

class _AddToItinerarySheetState extends State<AddToItinerarySheet> with SingleTickerProviderStateMixin {
  int _selectedDay = 1;
  String _selectedTime = '09:00 AM';
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;
  bool _showSuccess = false;

  late AnimationController _successController;
  late Animation<double> _scaleAnimation;

  final List<String> _timeOptions = [
    '08:00 AM',
    '09:00 AM',
    '10:30 AM',
    '12:00 PM',
    '02:00 PM',
    '03:30 PM',
    '05:00 PM',
    '07:00 PM',
    '08:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _saveToItinerary() {
    setState(() {
      _isSaving = true;
    });

    // Simulate calling POST /itineraries on NestJS backend
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _showSuccess = true;
        });
        _successController.forward();
        
        // Pass details back
        widget.onAdded({
          'day': _selectedDay,
          'startTime': _selectedTime,
          'placeName': widget.placeName,
          'placeAddress': widget.placeAddress,
          'notes': _notesController.text,
        });

        // Auto-close sheet after success animation
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = widget.isDarkMode;

    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF06B6D4) : const Color(0xFFEBA83A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFCFAF6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: SafeArea(
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: _showSuccess
              ? _buildSuccessView(primaryColor)
              : _buildFormView(theme, colorScheme, primaryColor, secondaryColor, isDark),
        ),
      ),
    );
  }

  Widget _buildSuccessView(Color primaryColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 30),
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withValues(alpha: 0.15),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Added to Itinerary! 🎉',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.placeName} is booked for Day $_selectedDay at $_selectedTime.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFormView(
    ThemeData theme,
    ColorScheme colorScheme,
    Color primaryColor,
    Color secondaryColor,
    bool isDark,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'discovery.add_to_trip'.tr(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.placeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                ),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Day Select (Horizontal Pills)
        Text(
          'Select Day',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [1, 2, 3].map((day) {
            final isSelected = _selectedDay == day;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = day;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.15)
                        : (isDark ? const Color(0xFF1E293B) : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? primaryColor : (isDark ? Colors.white10 : Colors.black12),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Text(
                    'Day $day',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? primaryColor : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Time Selector (Horizontal Dropdowns/List)
        Text(
          'Start Time',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _timeOptions.length,
            itemBuilder: (context, index) {
              final time = _timeOptions[index];
              final isSelected = _selectedTime == time;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? secondaryColor.withValues(alpha: 0.15)
                          : (isDark ? const Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? secondaryColor : (isDark ? Colors.white10 : Colors.black12),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Text(
                      time,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? secondaryColor : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Custom Notes Field
        Text(
          'Notes / Alter Ego Plans',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: const InputDecoration(
              hintText: 'Add notes... (e.g. "Sat by the window for golden hour photo op")',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Action Button
        GestureDetector(
          onTap: _isSaving ? null : _saveToItinerary,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_location_alt_outlined, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Add to Plan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
