import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
class SquadChecklistPackingScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const SquadChecklistPackingScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<SquadChecklistPackingScreen> createState() =>
      _SquadChecklistPackingScreenState();
}

class _SquadChecklistPackingScreenState
    extends State<SquadChecklistPackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _checklistItems = [
    {'title': 'Book Train Passes 🎫', 'done': true, 'by': 'Alex'},
    {'title': 'Exchange Currency 💵', 'done': true, 'by': 'Minh Nhật'},
    {'title': 'Print hotel vouchers 🏨', 'done': false, 'by': ''},
    {'title': 'Buy SIM Cards 📱', 'done': false, 'by': ''},
  ];

  final List<Map<String, dynamic>> _packingItems = [
    {'title': 'GoPro Camera 📸', 'packed': true, 'by': 'Alex'},
    {'title': 'Bluetooth Speaker 🔊', 'packed': true, 'by': 'Minh Nhật'},
    {'title': 'Powerbank 🔋', 'packed': true, 'by': 'Thảo Ly (Me)'},
    {'title': 'Rain Jackets 🧥', 'packed': false, 'by': ''},
    {'title': 'Sunscreen 🧴', 'packed': false, 'by': ''},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleChecklist(int idx) {
    setState(() {
      _checklistItems[idx]['done'] = !_checklistItems[idx]['done'];
      _checklistItems[idx]['by'] = _checklistItems[idx]['done']
          ? 'Thảo Ly (Me)'
          : '';
    });
  }

  void _togglePacking(int idx) {
    setState(() {
      _packingItems[idx]['packed'] = !_packingItems[idx]['packed'];
      _packingItems[idx]['by'] = _packingItems[idx]['packed']
          ? 'Thảo Ly (Me)'
          : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primaryColor = isDark
        ? const Color(0xFFF5822B)
        : const Color(0xFFF5822B);
    final secondaryColor = isDark
        ? const Color(0xFF3D8BFF)
        : const Color(0xFFFFD84D);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1712)
          : const Color(0xFFFDF6D3),
      appBar: AppBar(
        title: Text(
          'Squad Prep List',
          style: AppFonts.heading(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: 'Squad Checklist'),
            Tab(text: 'Collaborative Packing'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Checklist
            _buildChecklistTab(primaryColor, isDark),
            // Tab 2: Packing
            _buildPackingTab(secondaryColor, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistTab(Color primaryColor, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      itemCount: _checklistItems.length,
      itemBuilder: (context, index) {
        final item = _checklistItems[index];
        final done = item['done'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262019) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black,
              width: 2,
            ),
          ),
          child: ListTile(
            leading: Checkbox(
              value: done,
              activeColor: primaryColor,
              onChanged: (val) => _toggleChecklist(index),
            ),
            title: Text(
              item['title'],
              style: AppFonts.heading(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: done ? TextDecoration.lineThrough : null,
                color: done
                    ? Colors.grey
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            subtitle: done
                ? Text(
                    'Checked off by ${item['by']}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildPackingTab(Color secondaryColor, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      itemCount: _packingItems.length,
      itemBuilder: (context, index) {
        final item = _packingItems[index];
        final packed = item['packed'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262019) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black,
              width: 2,
            ),
          ),
          child: ListTile(
            leading: Checkbox(
              value: packed,
              activeColor: secondaryColor,
              onChanged: (val) => _togglePacking(index),
            ),
            title: Text(
              item['title'],
              style: AppFonts.heading(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: packed ? TextDecoration.lineThrough : null,
                color: packed
                    ? Colors.grey
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            subtitle: packed
                ? Text(
                    'Packed by ${item['by']} 🎒',
                    style: TextStyle(
                      fontSize: 10,
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    'Needs packing',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
