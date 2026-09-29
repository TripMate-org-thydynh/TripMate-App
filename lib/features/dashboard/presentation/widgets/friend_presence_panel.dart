import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/api_service.dart';
import '../../../../core/widgets/gen_z_widgets.dart';
import '../../../social/presentation/pages/trip_chat_live_screen.dart';
import '../../../invites/presentation/trip_invites_screen.dart';

class FriendPresencePanel extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const FriendPresencePanel({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<FriendPresencePanel> createState() => _FriendPresencePanelState();
}

class _FriendPresencePanelState extends State<FriendPresencePanel> {
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  String _tripName = '';
  String? _tripId;

  static IconData _vibeIcon(String vibe) {
    switch (vibe) {
      case "coffee":
        return PhosphorIconsRegular.coffee;
      case "camera":
        return PhosphorIconsRegular.camera;
      case "walk":
        return PhosphorIconsRegular.personSimpleWalk;
      case "sleep":
        return PhosphorIconsRegular.moon;
      case "home":
        return PhosphorIconsRegular.house;
      case "chill":
        return PhosphorIconsRegular.leaf;
      case "fire":
        return PhosphorIconsRegular.flame;
      case "food":
        return PhosphorIconsRegular.forkKnife;
      case "night":
        return PhosphorIconsRegular.moon;
      case "nature":
        return PhosphorIconsRegular.tree;
      default:
        return PhosphorIconsRegular.airplane;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSquadOnline();
  }

  Future<void> _fetchSquadOnline() async {
    final data = await ApiService.get('/dashboard/squad-online');
    if (mounted) {
      if (data != null && data['members'] != null) {
        final raw = data['members'] as List<dynamic>;
        setState(() {
          _tripName = data['tripName'] as String? ?? '';
          _tripId = data['tripId'] as String?;
          _members = raw.map((m) {
            final map = m as Map<String, dynamic>;
            final name = (map['name'] as String? ?? '?');
            return {
              'name': name,
              'status': map['status'] ?? 'OFFLINE',
              'vibe': _vibeFromTags(map['vibeTags']),
              'avatarChar': name.isNotEmpty ? name[0].toUpperCase() : '?',
              'avatarUrl': map['avatarUrl'],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        // API không trả thành viên nào → danh sách rỗng.
        // Trước đây nhánh này đổ vào 5 người bịa (Nam Trung, Thảo Ly, Minh
        // Nhật, Phú Khang, Hana), khiến tài khoản chưa có bạn nào vẫn thấy
        // "squad" đông đủ trên màn Home.
        setState(() {
          _members = const [];
          _isLoading = false;
        });
      }
    }
  }

  String _vibeFromTags(dynamic vibeTags) {
    if (vibeTags == null) return 'plane';
    final tags = vibeTags as List<dynamic>;
    if (tags.isEmpty) return 'plane';
    final tag = tags[0].toString().toLowerCase();
    if (tag.contains('chill')) return 'chill';
    if (tag.contains('chaos')) return 'fire';
    if (tag.contains('photo')) return 'camera';
    if (tag.contains('food')) return 'food';
    if (tag.contains('night')) return 'night';
    if (tag.contains('nature')) return 'nature';
    return 'plane';
  }

  Color get _ink => widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _line => widget.isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
  Color get _fill => widget.isDarkMode ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _accent =>
      widget.isDarkMode ? GenZTokens.accentDark : GenZTokens.accent;

  Color _statusColor(String status, bool isDark) {
    switch (status) {
      case 'ONLINE':
        return isDark ? GenZTokens.successDark : GenZTokens.success;
      case 'IN_TRIP':
        return isDark ? GenZTokens.accentDark : GenZTokens.accent;
      case 'IDLE':
        return isDark ? GenZTokens.warningDark : GenZTokens.warning;
      default:
        return isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    }
  }

  int get _activeCount => _members
      .where((m) => m['status'] == 'ONLINE' || m['status'] == 'IN_TRIP')
      .length;

  /// Chưa ai online (hoặc chưa có chuyến): hàng avatar giữ chỗ + lời rủ mời bạn,
  /// thay vì để trống một khoảng không.
  Widget _buildEmpty(BuildContext context, bool isDark) {
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final tripId = _tripId;

    Widget ghost(int i) => Transform.translate(
      offset: Offset(-12.0 * i, 0),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _fill,
          border: Border.all(color: surface, width: 2),
        ),
        child: Icon(
          PhosphorIcons.user(),
          size: 20,
          color: inkSoft.withValues(alpha: 0.6 - i * 0.12),
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 44.0 + 32 * 3,
                height: 44,
                child: Stack(
                  children: [
                    for (int i = 3; i >= 0; i--)
                      Positioned(left: 44.0 * i, child: ghost(i)),
                  ],
                ),
              ),
              const Spacer(),
              if (tripId != null)
                PressableCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TripInvitesScreen(
                        tripId: tripId,
                        tripName: _tripName,
                        isDarkMode: isDark,
                      ),
                    ),
                  ),
                  color: _accent,
                  borderColor: _accent,
                  shadowColor: _ink,
                  borderWidth: GenZTokens.borderWidthThin,
                  radius: GenZTokens.radiusPill,
                  depth: 1,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.userPlus(),
                        size: 16,
                        color: isDark
                            ? GenZTokens.onAccentDark
                            : GenZTokens.onAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'dashboard.squad_invite'.tr(),
                        style: AppFonts.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? GenZTokens.onAccentDark
                              : GenZTokens.onAccent,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: GenZTokens.space3),
          Text(
            'dashboard.squad_empty_title'.tr(),
            style: AppFonts.heading(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'dashboard.squad_empty_body'.tr(),
            style: AppFonts.body(fontSize: 13, color: inkSoft, height: 1.35),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _tripName.isNotEmpty
                      ? 'dashboard.squad_named'.tr(
                          namedArgs: {'name': _tripName},
                        )
                      : 'dashboard.squad_online_panel'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    letterSpacing: -0.5,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!_isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GenZTokens.space3,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _activeCount == 0
                        ? (isDark ? GenZTokens.fillDark : GenZTokens.fill)
                        : (isDark
                              ? GenZTokens.successDark
                              : GenZTokens.success),
                    borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                    border: Border.all(
                      color: _activeCount == 0
                          ? (isDark ? GenZTokens.lineDark : GenZTokens.line)
                          : Colors.transparent,
                      width: GenZTokens.borderWidthThin,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_activeCount > 0) ...[
                        PulseDot(
                          size: 7,
                          color: isDark
                              ? GenZTokens.onAccentDark
                              : GenZTokens.onAccent,
                        ),
                        const SizedBox(width: GenZTokens.space1),
                      ],
                      Text(
                        'dashboard.active_count'.tr(
                          namedArgs: {'count': '$_activeCount'},
                        ),
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: _activeCount > 0
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _activeCount == 0
                              ? (isDark
                                    ? GenZTokens.inkSoftDark
                                    : GenZTokens.inkSoft)
                              : (isDark
                                    ? GenZTokens.onAccentDark
                                    : GenZTokens.onAccent),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (!_isLoading && _members.isEmpty)
          _buildEmpty(context, isDark)
        else
          SizedBox(
            height: 90,
            child: _isLoading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(_accent),
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      final friend = _members[index];
                      final status = friend['status'] as String? ?? 'OFFLINE';
                      final isActive =
                          status == 'ONLINE' ||
                          status == 'IN_TRIP' ||
                          status == 'IDLE';
                      final statusColor = _statusColor(status, isDark);

                      return Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: GestureDetector(
                          onTap: () {
                            final tripId = _tripId;
                            if (tripId == null) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TripChatLiveScreen(
                                  tripId: tripId,
                                  isDarkMode: widget.isDarkMode,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 350),
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isActive
                                          ? statusColor
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _line,
                                        width: GenZTokens.borderWidthThin,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundImage:
                                          friend['avatarUrl'] != null
                                          ? NetworkImage(
                                              friend['avatarUrl'] as String,
                                            )
                                          : null,
                                      backgroundColor: _fill,
                                      child: friend['avatarUrl'] == null
                                          ? Text(
                                              friend['avatarChar'] as String,
                                              style: AppFonts.heading(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: _ink,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                  if (isActive)
                                    Positioned(
                                      top: -2,
                                      left: -2,
                                      child: PulseDot(
                                        color: statusColor,
                                        size: 9,
                                      ),
                                    ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: _fill,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _line,
                                          width: GenZTokens.borderWidthThin,
                                        ),
                                      ),
                                      child: Icon(
                                        _vibeIcon(friend['vibe'] as String),
                                        size: 10,
                                        color: _accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                friend['name'] as String,
                                style: AppFonts.heading(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
