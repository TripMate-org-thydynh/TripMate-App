import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/api_service.dart';
import '../../../../core/widgets/gen_z_widgets.dart';
import '../../../social/presentation/pages/trip_chat_live_screen.dart';

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

  Color _statusColor(String status, bool isDark) {
    switch (status) {
      case 'ONLINE':
        return GenZTokens.green;
      case 'IN_TRIP':
        return GenZTokens.purple;
      case 'IDLE':
        return GenZTokens.yellow;
      default:
        return GenZTokens.inkSoft;
    }
  }

  int get _activeCount => _members
      .where((m) => m['status'] == 'ONLINE' || m['status'] == 'IN_TRIP')
      .length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.5,
                    color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!_isLoading)
                PillTag(text: "$_activeCount active", color: GenZTokens.green),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: _isLoading
              ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
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
                        // Mở chat THẬT của chuyến. Trước đây chỗ này mở
                        // `SquadChatScreen` — một màn demo với tin nhắn và người
                        // gửi bịa, không nối với chat_repository nào.
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
                                // Avatar nảy nhẹ liên tục, so le theo index
                                Bobbing(
                                  amplitude: 3,
                                  phase: index * 0.9,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 350),
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isActive
                                          ? statusColor
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isDark
                                            ? GenZTokens.inkDark
                                            : GenZTokens.ink,
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
                                      backgroundColor: GenZTokens.lilac,
                                      child: friend['avatarUrl'] == null
                                          ? Text(
                                              friend['avatarChar'] as String,
                                              style: AppFonts.heading(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: GenZTokens.ink,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                // Chấm online pulse cho thành viên đang hoạt động
                                if (isActive)
                                  Positioned(
                                    top: -2,
                                    left: -2,
                                    child: PulseDot(
                                      color: statusColor,
                                      size: 9,
                                    ),
                                  ),
                                // Vibe icon badge
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: GenZTokens.yellow,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: GenZTokens.ink,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      _vibeIcon(friend['vibe'] as String),
                                      size: 10,
                                      color: GenZTokens.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              friend['name'] as String,
                              style: AppFonts.heading(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? GenZTokens.inkDark
                                    : GenZTokens.ink,
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
