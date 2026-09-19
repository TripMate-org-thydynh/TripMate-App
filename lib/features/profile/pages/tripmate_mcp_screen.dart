import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../system_states/application/tripmate_mcp_config.dart';

class TripmateMcpScreen extends StatefulWidget {
  final bool isDarkMode;
  const TripmateMcpScreen({super.key, this.isDarkMode = false});

  @override
  State<TripmateMcpScreen> createState() => _TripmateMcpScreenState();
}

class _TripmateMcpScreenState extends State<TripmateMcpScreen> {
  bool _mcpEnabled = true;

  bool get _isDark =>
      widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
  Color get _bg =>
      _isDark ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _surface =>
      _isDark ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill =>
      _isDark ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _ink =>
      _isDark ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _line =>
      _isDark ? GenZTokens.lineDark : GenZTokens.line;
  Color get _accent =>
      _isDark ? GenZTokens.accentDark : GenZTokens.accent;
  Color get _onAccent =>
      _isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
  Color get _textSec =>
      _isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _success =>
      _isDark ? GenZTokens.successDark : GenZTokens.success;
  Color get _codeColor =>
      _isDark ? GenZTokens.infoDark : GenZTokens.info;

  @override
  Widget build(BuildContext context) {
    final jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(TripMateMcpConfig.schema);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), color: _ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'system_phases.mcp_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(GenZTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(GenZTokens.space4),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
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
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _mcpEnabled ? _success : _textSec,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _mcpEnabled
                                ? 'system_phases.mcp_active'.tr()
                                : 'profile.mcp_inactive'.tr(),
                            style: AppFonts.heading(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
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
                        activeThumbColor: _accent,
                        activeTrackColor: _accent.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                  const SizedBox(height: GenZTokens.space2),
                  Text(
                    'system_phases.mcp_desc'.tr(),
                    style: AppFonts.body(
                      fontSize: 13,
                      color: _textSec,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GenZTokens.space5),

            // Schema terminal-like code block
            Text(
              'profile.mcp_schema'.tr(),
              style: AppFonts.heading(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            const SizedBox(height: GenZTokens.space2),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(GenZTokens.space4),
              decoration: BoxDecoration(
                color: _fill,
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(
                      jsonString,
                      style: AppFonts.mono(
                        fontSize: 12,
                        color: _codeColor,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        PhosphorIcons.copy(),
                        color: _textSec,
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
            const SizedBox(height: GenZTokens.space5),

            // Action Docs Button - single accent button on screen
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: _onAccent,
                  elevation: 0,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                  ),
                ),
                icon: Icon(PhosphorIcons.bookOpen()),
                label: Text(
                  'system_phases.mcp_docs'.tr(),
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: _onAccent,
                  ),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: _surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                        side: BorderSide(color: _line, width: GenZTokens.borderWidthThin),
                      ),
                      title: Text(
                        'profile.mcp_docs'.tr(),
                        style: AppFonts.heading(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: _ink,
                        ),
                      ),
                      content: Text(
                        'settings.mcp_intro'.tr(),
                        style: AppFonts.body(fontSize: 13, color: _ink, height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'common.got_it'.tr(),
                            style: AppFonts.heading(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: _accent,
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
