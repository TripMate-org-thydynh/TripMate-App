import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiGenerationQueueScreen extends StatefulWidget {
  const AiGenerationQueueScreen({super.key});

  @override
  State<AiGenerationQueueScreen> createState() => _AiGenerationQueueScreenState();
}

class _AiGenerationQueueScreenState extends State<AiGenerationQueueScreen> {
  Timer? _timer;
  
  final List<Map<String, dynamic>> _tasks = [
    {
      'id': 'task-1',
      'title': 'Render Video Recap Cinematic 🎬',
      'subtitle': 'Ghép ảnh Kyoto, chèn nhạc EDM cực căng & sub troll',
      'progress': 0.74,
      'status': 'RENDERING',
      'eta': '25 giây',
      'color': const Color(0xFF8B5CF6), // Purple
      'type': 'VIDEO',
    },
    {
      'id': 'task-2',
      'title': 'Phân Tích Hóa Đơn Dalat Chaos 🧾',
      'subtitle': 'Matey AI OCR bóc tách 14 hóa đơn lẩu nướng gà lá é',
      'progress': 0.92,
      'status': 'PARSING',
      'eta': '5 giây',
      'color': const Color(0xFF10B981), // Emerald
      'type': 'OCR',
    },
    {
      'id': 'task-3',
      'title': 'Tính Cách Quái Vật Squad Roaster 👹',
      'subtitle': 'Phân tích chat log để tìm ra kẻ hủy diệt tình bạn',
      'progress': 0.40,
      'status': 'ANALYZING',
      'eta': '1 phút',
      'color': const Color(0xFFEF4444), // Red
      'type': 'ROAST',
    },
    {
      'id': 'task-4',
      'title': 'Bản Đồ Vibe Match Tìm Gái Xinh/Trai Đẹp 🗺️',
      'subtitle': 'Quét tọa độ check-in matching của hội bạn độc thân',
      'progress': 0.15,
      'status': 'SCANNING',
      'eta': '3 phút',
      'color': const Color(0xFF3B82F6), // Blue
      'type': 'GEO',
    }
  ];

  @override
  void initState() {
    super.initState();
    // Simulate real-time progress increases!
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        for (var task in _tasks) {
          if (task['progress'] < 1.0) {
            double step = 0.02 + (0.05 * (task['id'].hashCode % 3) / 3.0);
            task['progress'] = (task['progress'] + step).clamp(0.0, 1.0);
            if (task['progress'] >= 1.0) {
              task['status'] = 'COMPLETED';
              task['eta'] = 'Xong!';
            } else {
              // Update eta roughly
              int remainingSeconds = ((1.0 - task['progress']) * 100).toInt();
              if (remainingSeconds < 10) {
                task['eta'] = '$remainingSeconds giây';
              } else {
                task['eta'] = '${remainingSeconds ~/ 2} giây';
              }
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _boostTask(int index) {
    setState(() {
      final task = _tasks[index];
      if (task['progress'] < 1.0) {
        task['progress'] = (task['progress'] + 0.15).clamp(0.0, 1.0);
        if (task['progress'] >= 1.0) {
          task['status'] = 'COMPLETED';
          task['eta'] = 'Xong!';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚡ Đã ép xung Matey AI! Tăng tốc "${task['title']}"!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: task['color'],
          ),
        );
      }
    });
  }

  void _cancelTask(int index) {
    setState(() {
      final task = _tasks[index];
      _tasks.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🗑️ Đã hủy tác vụ "${task['title']}"'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Brand design system tokens
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF06B6D4) : const Color(0xFFEBA83A);
    final backgroundColor = isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hàng Đợi AI Render 🖥️',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () {
              setState(() {
                // Reset completed to 50%
                for (var task in _tasks) {
                  if (task['status'] == 'COMPLETED') {
                    task['progress'] = 0.50;
                    task['status'] = 'RENDERING';
                    task['eta'] = '30 giây';
                  }
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Matey AI status balloon using brand coloring gradient
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    '🧠',
                    style: TextStyle(fontSize: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lời khuyên từ Matey AI:',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"Ta đang phải chạy bằng cơm để render đống tệp đa phương tiện siêu nặng này cho các cưng đấy! Táp nút Bứt Tốc để ép xung CPU của ta nhé!" 💥',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Text(
              'Tác vụ đang xử lý (${_tasks.where((t) => t['progress'] < 1.0).length})',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            if (_tasks.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        'Hàng đợi trống rỗng! Matey đang rảnh rỗi nè!',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  final isCompleted = task['progress'] >= 1.0;
                  final Color baseColor = task['color'] as Color;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCompleted
                            ? Colors.green.withValues(alpha: 0.3)
                            : baseColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Type Badge & Title
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? Colors.green.withValues(alpha: 0.15)
                                            : baseColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isCompleted ? 'COMPLETED' : task['status'] as String,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isCompleted ? Colors.green : baseColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      task['title'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // ETA or Xong label
                              Text(
                                isCompleted ? 'Hoàn thành' : 'ETA: ${task['eta']}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted ? Colors.green : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task['subtitle'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Progress Bar & Percentage
                          Row(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 500),
                                      height: 8,
                                      width: (MediaQuery.of(context).size.width - 120) * task['progress'],
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isCompleted
                                              ? [Colors.green, Colors.teal]
                                              : [baseColor, baseColor.withValues(alpha: 0.6)],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isCompleted
                                                ? Colors.green.withValues(alpha: 0.3)
                                                : baseColor.withValues(alpha: 0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${(task['progress'] * 100).toInt()}%',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isCompleted ? Colors.green : (isDark ? Colors.white : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Control Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!isCompleted) ...[
                                TextButton.icon(
                                  onPressed: () => _cancelTask(index),
                                  icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                                  label: Text(
                                    'Hủy bỏ',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _boostTask(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: baseColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.flash_on, size: 14, color: Colors.white),
                                  label: Text(
                                    'Bứt Tốc ⚡',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                TextButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('🎉 Tác vụ "${task['title']}" đã xong và lưu vào nhật ký!'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                                  label: Text(
                                    'Xem kết quả',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
