import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class BackupRestoreScreen extends StatefulWidget {
  final bool isDarkMode;
  const BackupRestoreScreen({super.key, this.isDarkMode = false});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  List<Map<String, String>> _backups = [];
  bool _isLoading = false;

  Color get _bg =>
      widget.isDarkMode ? const Color(0xFF1A1712) : const Color(0xFFFDF6D3);
  Color get _surface =>
      widget.isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _ink =>
      widget.isDarkMode ? const Color(0xFFFDF6D3) : const Color(0xFF141210);
  Color get _primary => const Color(0xFFF5822B);
  Color get _textSec =>
      widget.isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  @override
  void initState() {
    super.initState();
    _loadBackupsList();
  }

  Future<void> _loadBackupsList() async {
    final prefs = await SharedPreferences.getInstance();
    final listString = prefs.getString('offline_backups_list');
    if (listString != null) {
      final List<dynamic> decoded = jsonDecode(listString);
      setState(() {
        _backups = decoded
            .map((e) => Map<String, String>.from(e as Map))
            .toList();
      });
    }
  }

  Future<void> _createBackup() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    // Simulated trip/pack data
    final backupData = {
      'trips_count': 3,
      'trips': [
        {'id': '1', 'name': 'Phú Quốc Escape 🌊', 'vibe': 'chill'},
        {'id': '2', 'name': 'Đà Lạt Săn Mây 🌲', 'vibe': 'nature'},
        {'id': '3', 'name': 'Hà Nội Ăn Sập 🍲', 'vibe': 'food'}
      ],
      'checklist_items_completed': 18,
      'stats': {
        'places_explored': 12,
        'total_trips': 3,
        'streak_months': 2,
      },
      'timestamp': DateTime.now().toIso8601String()
    };

    final timestampStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final backupId = 'backup_${DateTime.now().millisecondsSinceEpoch}';

    final prefs = await SharedPreferences.getInstance();
    
    // Save backup contents
    await prefs.setString(backupId, jsonEncode(backupData));

    // Save to list
    final newBackupList = [
      {'id': backupId, 'date': timestampStr, 'label': 'Backup $timestampStr'},
      ..._backups
    ];
    await prefs.setString('offline_backups_list', jsonEncode(newBackupList));

    await Future.delayed(const Duration(milliseconds: 600)); // Simulate write
    setState(() {
      _backups = newBackupList;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'system_phases.backup_success'.tr(),
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _restoreBackup(String backupId) async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final backupContent = prefs.getString(backupId);

    await Future.delayed(const Duration(milliseconds: 600)); // Simulate read
    setState(() => _isLoading = false);

    if (backupContent != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _ink, width: 2.5),
          ),
          title: Text(
            'Chi tiết Khôi phục 📂',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: _ink),
          ),
          content: Text(
            'Dữ liệu chứa:\n- 3 Chuyến đi\n- 18 Checklist đã hoàn thành\n- 12 Địa điểm đã khám phá\n\nCưng có muốn ghi đè dữ liệu hiện tại bằng bản sao lưu này không?',
            style: GoogleFonts.outfit(color: _ink),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('general.cancel2'.tr(), style: GoogleFonts.spaceGrotesk(color: _textSec, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD84D),
                foregroundColor: const Color(0xFF141210),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: _ink, width: 1.5),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'system_phases.restore_success'.tr(),
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(
                'system_phases.restore_btn'.tr(),
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _deleteBackup(String backupId) async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(backupId);

    final updated = _backups.where((b) => b['id'] != backupId).toList();
    await prefs.setString('offline_backups_list', jsonEncode(updated));

    setState(() {
      _backups = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderCol = _ink;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'system_phases.backup_title'.tr(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _ink,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header description card in Brutalist design
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderCol, width: 2.5),
                      boxShadow: [
                        BoxShadow(color: borderCol, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'system_phases.backup_title'.tr(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'system_phases.backup_desc'.tr(),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: _textSec,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: Text(
                              'system_phases.backup_btn'.tr(),
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            onPressed: _createBackup,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    'Các bản sao lưu đã tạo:',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: _backups.isEmpty
                        ? Center(
                            child: Text(
                              'system_phases.backup_empty'.tr(),
                              style: GoogleFonts.outfit(color: _textSec),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _backups.length,
                            itemBuilder: (context, index) {
                              final item = _backups[index];
                              final id = item['id']!;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderCol, width: 2),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _primary.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.insert_drive_file, color: _primary, size: 20),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['label']!,
                                            style: GoogleFonts.spaceGrotesk(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: _ink,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Offline JSON Backup File',
                                            style: GoogleFonts.outfit(
                                              fontSize: 11,
                                              color: _textSec,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: () => _restoreBackup(id),
                                          child: Text(
                                            'system_phases.restore_btn'.tr(),
                                            style: GoogleFonts.spaceGrotesk(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                          onPressed: () => _deleteBackup(id),
                                        ),
                                      ],
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
