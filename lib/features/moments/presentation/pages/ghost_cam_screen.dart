import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GhostCamScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const GhostCamScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<GhostCamScreen> createState() => _GhostCamScreenState();
}

class _GhostCamScreenState extends State<GhostCamScreen> {
  bool _isCapturing = false;
  int _ghostPingsCount = 3;

  @override
  Widget build(BuildContext context) {
    final bgGradStart = widget.isDarkMode ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final bgGradEnd = widget.isDarkMode ? const Color(0xFF151926) : const Color(0xFFF3EFE9);
    final textPrimary = widget.isDarkMode ? Colors.white : Colors.black87;
    final textSecondary = widget.isDarkMode ? Colors.white60 : Colors.black54;

    final neonPink = const Color(0xFFFF2E93);
    final neonAmber = const Color(0xFFFFB300);

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
          child: Stack(
            children: [
              Column(
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
                              'Ghost Cam 👻',
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
                            widget.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                            color: textPrimary,
                          ),
                          onPressed: widget.onThemeToggle,
                        ),
                      ],
                    ),
                  ),

                  // Advices info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Catch surprise candid ghost moments of your active squad.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Interactive live camera box
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: neonPink.withValues(alpha: 0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: neonPink.withValues(alpha: 0.2),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(38),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Camera viewfinder simulation (using a moody dark city picture)
                            Image.network(
                              'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=800',
                              fit: BoxFit.cover,
                            ),

                            // Camera flash overlay
                            if (_isCapturing)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                color: Colors.white,
                              ),

                            // Visual corner focus grids
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.white60, width: 2),
                                    left: BorderSide(color: Colors.white60, width: 2),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 20,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.white60, width: 2),
                                    right: BorderSide(color: Colors.white60, width: 2),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white60, width: 2),
                                    left: BorderSide(color: Colors.white60, width: 2),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              right: 20,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white60, width: 2),
                                    right: BorderSide(color: Colors.white60, width: 2),
                                  ),
                                ),
                              ),
                            ),

                            // Floating Ghost Alert Notification Badge
                            Positioned(
                              top: 30,
                              left: 20,
                              right: 20,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: neonAmber.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Text('👻', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Active Ghost Ping detected!',
                                            style: GoogleFonts.outfit(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'Minh Nhật is active nearby at Kyoto Station!',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Camera Shutter bottom actions
                            Positioned(
                              bottom: 30,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Ghost pings meter
                                  Column(
                                    children: [
                                      Text(
                                        '$_ghostPingsCount',
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Pings left',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // SHUTTER BUTTON
                                  GestureDetector(
                                    onTap: () {
                                      final messenger = ScaffoldMessenger.of(context);
                                      setState(() {
                                        _isCapturing = true;
                                      });
                                      Future.delayed(const Duration(milliseconds: 150), () {
                                        if (mounted) {
                                          setState(() {
                                            _isCapturing = false;
                                            if (_ghostPingsCount > 0) _ghostPingsCount--;
                                          });
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: const Text('Captured Surprise candid Ghost Boomerang moment! 📸⚡'),
                                              backgroundColor: neonPink,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: 76,
                                      height: 76,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 4),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: neonPink,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: neonPink.withValues(alpha: 0.4),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Flash toggler
                                  IconButton(
                                    icon: const Icon(Icons.flash_on, color: Colors.white),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
