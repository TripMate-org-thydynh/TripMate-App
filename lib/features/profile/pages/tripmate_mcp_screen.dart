import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../system_states/application/tripmate_mcp_config.dart';

class TripmateMcpScreen extends StatefulWidget {
  final bool isDarkMode;
  const TripmateMcpScreen({super.key, this.isDarkMode = false});

  @override
  State<TripmateMcpScreen> createState() => _TripmateMcpScreenState();
}

class _TripmateMcpScreenState extends State<TripmateMcpScreen> {
  bool _mcpEnabled = true;

  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      widget.isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _ink =>
      widget.isDarkMode ? const Color(0xFFFDF6D3) : const Color(0xFF141210);

  /// Accent lay tu theme dang chon.
  ///
  /// Truoc day viet cung `Color(0xFFF5822B)` — accent cua rieng preset *grape*.
  /// Day la State nen doc thang `context` duoc.
  Color get _primary => Theme.of(context).colorScheme.primary;
  Color get _textSec =>
      widget.isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  @override
  Widget build(BuildContext context) {
    final borderCol = _ink;
    final jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(TripMateMcpConfig.schema);

    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'system_phases.mcp_title'.tr(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: _ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderCol, width: 2.5),
                boxShadow: [
                  BoxShadow(color: borderCol, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _mcpEnabled
                                  ? const Color(0xFF1FA85C)
                                  : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(color: _ink, width: 1.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _mcpEnabled
                                ? 'system_phases.mcp_active'.tr()
                                : 'MCP Connection Status: INACTIVE',
                            style: GoogleFonts.spaceMono(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: _ink,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _mcpEnabled,
                        onChanged: (val) {
                          HapticFeedback.mediumImpact();
                          setState(() => _mcpEnabled = val);
                        },
                        activeThumbColor: const Color(0xFFFFD84D),
                        activeTrackColor: _primary.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'system_phases.mcp_desc'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: _textSec,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Schema terminal-like code block
            Text(
              'profile.mcp_schema'.tr(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? const Color(0xFF141210)
                    : const Color(0xFF262019),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol, width: 2),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(
                      jsonString,
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        color: const Color(0xFF56B6C2), // Teal color
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.white70,
                        size: 18,
                      ),
                      tooltip: 'settings.copy_schema'.tr(),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: jsonString));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('common.copied_schema'.tr()),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Docs Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD84D),
                  foregroundColor: const Color(0xFF141210),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: borderCol, width: 2),
                  ),
                ),
                icon: const Icon(Icons.menu_book),
                label: Text(
                  'system_phases.mcp_docs'.tr(),
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: _surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: _ink, width: 2.5),
                      ),
                      title: Text(
                        'profile.mcp_docs'.tr(),
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          color: _ink,
                        ),
                      ),
                      content: Text(
                        'settings.mcp_intro'.tr(),
                        style: GoogleFonts.outfit(color: _ink),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'OK',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              color: _primary,
                            ),
                          ),
                        ),
                      ],
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
}
