import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import 'action_cards.dart';
import 'o_an_quan_engine.dart';

/// Ô Ăn Quan chơi chung một máy (pass-and-play), kèm thẻ hành động: ăn được
/// quan hoặc từ 5 điểm trở lên thì rút một thẻ. Không cần mạng.
///
/// Điểm nhấn duy nhất của màn: ô đang chọn + hai nút chọn chiều rải.
class OAnQuanScreen extends StatefulWidget {
  const OAnQuanScreen({super.key});

  @override
  State<OAnQuanScreen> createState() => _OAnQuanScreenState();
}

class _OAnQuanScreenState extends State<OAnQuanScreen> {
  OAnQuanState _state = OAnQuanState.initial();
  final ActionDeck _deck = ActionDeck();
  int? _selected;
  int? _active;
  StepKind? _activeKind;
  bool _animating = false;

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _dark ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _surface => _dark ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _line => _dark ? GenZTokens.lineDark : GenZTokens.line;
  Color get _fill => _dark ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _ink => _dark ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _inkSoft => _dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _accent => _dark ? GenZTokens.accentDark : GenZTokens.accent;
  Color get _onAccent => _dark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
  Color get _success => _dark ? GenZTokens.successDark : GenZTokens.success;

  String _name(int p) => 'oaq.player'.tr(namedArgs: {'n': '${p + 1}'});

  // ── Luồng một lượt ─────────────────────────────────────────────────────
  Future<void> _play(int dir) async {
    final cell = _selected;
    if (cell == null || _animating) return;
    final mover = _state.turn;
    HapticFeedback.selectionClick();
    final r = OAnQuanEngine.play(_state, cell, dir);
    setState(() => _selected = null);
    await _replay(r.steps);
    var next = r.state;

    if (ActionDeck.earns(gained: r.gained, quanTaken: r.quanTaken)) {
      final card = _deck.draw();
      if (!mounted) return;
      await _showCard(card, mover);
      next = _applyCard(next, card, mover);
    }

    final begin = OAnQuanEngine.beginTurn(next);
    await _replay(begin.steps, base: next);
    if (!mounted) return;
    setState(() => _state = begin.state);
    if (begin.state.over) _showResult();
  }

  OAnQuanState _applyCard(OAnQuanState s, ActionCard card, int mover) {
    switch (card.kind) {
      case ActionCardKind.extraTurn:
        return s.copyWith(turn: mover);
      case ActionCardKind.steal:
        final other = 1 - mover;
        final take = card.amount.clamp(0, s.capturedDan[other]);
        final dan = List.of(s.capturedDan);
        dan[other] -= take;
        dan[mover] += take;
        return s.copyWith(capturedDan: dan);
      case ActionCardKind.squad:
        return s;
    }
  }

  /// Phát lại từng bước. Người dùng bật "giảm chuyển động" thì nhảy thẳng
  /// tới kết quả.
  Future<void> _replay(List<OAnQuanStep> steps, {OAnQuanState? base}) async {
    if (steps.isEmpty) return;
    if (MediaQuery.of(context).disableAnimations) {
      setState(() => _state = steps.last.after);
      return;
    }
    setState(() => _animating = true);
    for (final step in steps) {
      if (!mounted) return;
      setState(() {
        _state = step.after;
        _active = step.cell;
        _activeKind = step.kind;
      });
      if (step.kind == StepKind.capture) HapticFeedback.lightImpact();
      await Future<void>.delayed(
        Duration(milliseconds: step.kind == StepKind.capture ? 420 : 170),
      );
    }
    if (!mounted) return;
    setState(() {
      _animating = false;
      _active = null;
      _activeKind = null;
    });
  }

  Future<void> _showCard(ActionCard card, int mover) {
    final icon = switch (card.kind) {
      ActionCardKind.extraTurn => PhosphorIcons.arrowClockwise(),
      ActionCardKind.steal => PhosphorIcons.handGrabbing(),
      ActionCardKind.squad => PhosphorIcons.usersThree(),
    };
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          side: BorderSide(color: _line),
        ),
        title: Row(
          children: [
            Icon(icon, color: _ink, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                card.titleKey.tr(),
                style: AppFonts.heading(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'oaq.card_drawn_by'.tr(namedArgs: {'name': _name(mover)}),
              style: AppFonts.body(fontSize: 13, color: _inkSoft),
            ),
            const SizedBox(height: 8),
            Text(
              card.bodyKey.tr(),
              style: AppFonts.body(fontSize: 15, color: _ink, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'oaq.card_ok'.tr(),
              style: AppFonts.body(fontWeight: FontWeight.w700, color: _ink),
            ),
          ),
        ],
      ),
    );
  }

  void _showResult() {
    final a = _state.score(0), b = _state.score(1);
    final text = a == b
        ? 'oaq.draw'.tr()
        : 'oaq.winner'.tr(namedArgs: {'name': _name(a > b ? 0 : 1)});
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: Text(
          text,
          style: AppFonts.heading(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        content: Text(
          '${_name(0)}: $a · ${_name(1)}: $b',
          style: AppFonts.mono(fontSize: 15, color: _ink),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _restart();
            },
            child: Text(
              'oaq.play_again'.tr(),
              style: AppFonts.body(fontWeight: FontWeight.w700, color: _ink),
            ),
          ),
        ],
      ),
    );
  }

  void _restart() => setState(() {
    _state = OAnQuanState.initial();
    _selected = null;
  });

  void _showRules() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GenZTokens.radiusCard),
        ),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GenZTokens.space5),
          child: Text(
            'oaq.rules_body'.tr(),
            style: AppFonts.body(fontSize: 15, color: _ink, height: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Giao diện ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: _ink),
        title: Text(
          'oaq.title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'oaq.rules'.tr(),
            icon: Icon(PhosphorIcons.question(), color: _ink),
            onPressed: _showRules,
          ),
          IconButton(
            tooltip: 'oaq.restart'.tr(),
            icon: Icon(PhosphorIcons.arrowCounterClockwise(), color: _ink),
            onPressed: _animating ? null : _restart,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GenZTokens.space4),
          child: Column(
            children: [
              _scoreChip(1),
              const Spacer(),
              _board(),
              const Spacer(),
              _scoreChip(0),
              const SizedBox(height: GenZTokens.space4),
              _controls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreChip(int p) {
    final myTurn = _state.turn == p && !_state.over;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: myTurn ? _ink : _line,
          width: myTurn ? GenZTokens.borderWidth : GenZTokens.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Text(
            _name(p),
            style: AppFonts.heading(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          if (myTurn) ...[
            const SizedBox(width: 8),
            Text(
              'oaq.your_turn'.tr(),
              style: AppFonts.body(fontSize: 13, color: _inkSoft),
            ),
          ],
          const Spacer(),
          if (_state.capturedQuan[p] > 0) ...[
            Icon(
              PhosphorIcons.crown(PhosphorIconsStyle.fill),
              size: 16,
              color: _ink,
            ),
            Text(
              ' ×${_state.capturedQuan[p]}  ',
              style: AppFonts.mono(fontSize: 13, color: _ink),
            ),
          ],
          Text(
            '${_state.score(p)}',
            style: AppFonts.mono(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _board() {
    return Container(
      padding: const EdgeInsets.all(GenZTokens.space2),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: _line),
      ),
      child: AspectRatio(
        aspectRatio: 7 / 2.6,
        child: Row(
          children: [
            Expanded(child: _cell(0, quan: true)),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        for (final c in const [11, 10, 9, 8, 7])
                          Expanded(child: _cell(c)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        for (final c in const [1, 2, 3, 4, 5])
                          Expanded(child: _cell(c)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _cell(6, quan: true)),
          ],
        ),
      ),
    );
  }

  Widget _cell(int i, {bool quan = false}) {
    final count = _state.dan[i];
    final hasQuan = _state.quan[i];
    final selectable = !_animating && _state.canPlay(i);
    final selected = _selected == i;
    final active = _active == i;
    final borderColor = selected
        ? _accent
        : active
        ? (_activeKind == StepKind.capture ? _success : _ink)
        : _line;

    return Semantics(
      button: selectable,
      label: 'oaq.cell_label'.tr(namedArgs: {'n': '$count'}),
      child: GestureDetector(
        key: ValueKey('oaq-cell-$i'),
        onTap: selectable
            ? () {
                HapticFeedback.selectionClick();
                setState(() => _selected = selected ? null : i);
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: selectable ? _fill : _bg,
            borderRadius: BorderRadius.circular(
              quan ? GenZTokens.radiusPill : GenZTokens.radiusButton,
            ),
            border: Border.all(
              color: borderColor,
              width: selected || active
                  ? GenZTokens.borderWidthFocus
                  : GenZTokens.borderWidthThin,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: _stones(count, hasQuan),
              ),
              Positioned(
                right: 5,
                bottom: 3,
                child: Text(
                  hasQuan ? '$count+Q' : '$count',
                  style: AppFonts.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _inkSoft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Vẽ quân bằng chấm tròn; quá 12 viên thì chỉ còn con số (đỡ rối mắt).
  Widget _stones(int count, bool hasQuan) {
    final dots = count.clamp(0, 12);
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 2,
      runSpacing: 2,
      children: [
        if (hasQuan)
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: _ink, shape: BoxShape.circle),
          ),
        for (var k = 0; k < dots; k++)
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _inkSoft, shape: BoxShape.circle),
          ),
      ],
    );
  }

  Widget _controls() {
    final cell = _selected;
    if (cell == null) {
      return SizedBox(
        height: 48,
        child: Center(
          child: Text(
            _state.over
                ? 'oaq.game_over'.tr()
                : 'oaq.pick_cell'.tr(namedArgs: {'name': _name(_state.turn)}),
            textAlign: TextAlign.center,
            style: AppFonts.body(fontSize: 13, color: _inkSoft),
          ),
        ),
      );
    }
    // Hàng trên hiển thị 11→7 từ trái qua phải, nên "sang phải" trên màn hình
    // là chiều giảm chỉ số với người chơi 1.
    final rightDir = _state.turn == 0 ? 1 : -1;
    Widget btn(String key, IconData icon, int dir, {bool iconFirst = true}) {
      // Flexible: chữ to (cài đặt cỡ chữ hệ thống) thì xuống dòng chứ không tràn.
      final label = Flexible(
        child: Text(
          key.tr(),
          textAlign: TextAlign.center,
          style: AppFonts.body(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _onAccent,
          ),
        ),
      );
      final ic = Icon(icon, size: 18, color: _onAccent);
      return Expanded(
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _accent,
            minimumSize: const Size.fromHeight(48),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
            ),
          ),
          onPressed: _animating ? null : () => _play(dir),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: iconFirst
                ? [ic, const SizedBox(width: 6), label]
                : [label, const SizedBox(width: 6), ic],
          ),
        ),
      );
    }

    return Row(
      children: [
        btn('oaq.sow_left', PhosphorIcons.arrowLeft(), -rightDir),
        const SizedBox(width: GenZTokens.space3),
        btn(
          'oaq.sow_right',
          PhosphorIcons.arrowRight(),
          rightDir,
          iconFirst: false,
        ),
      ],
    );
  }
}
