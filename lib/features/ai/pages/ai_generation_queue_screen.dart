import 'dart:async';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AiGenerationQueueScreen extends StatefulWidget {
  const AiGenerationQueueScreen({super.key});

  @override
  State<AiGenerationQueueScreen> createState() =>
      _AiGenerationQueueScreenState();
}

class _AiGenerationQueueScreenState extends State<AiGenerationQueueScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  bool _showLoadingOverlay = true;
  late AnimationController _rotateController;
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _tasks = [
    {
      'id': 'task-1',
      'title': 'Render Video Recap Cinematic 🎬',
      'subtitle': 'Ghép ảnh Kyoto, chèn nhạc EDM cực căng & sub troll',
      'progress': 0.74,
      'status': 'RENDERING',
      'eta': '25 giây',
      'color': const Color(0xFFF5822B), // Purple
      'type': 'VIDEO',
    },
    {
      'id': 'task-2',
      'title': 'Phân Tích Hóa Đơn Dalat Chaos 🧾',
      'subtitle': 'Matey AI OCR bóc tách 14 hóa đơn lẩu nướng gà lá é',
      'progress': 0.92,
      'status': 'PARSING',
      'eta': '5 giây',
      'color': const Color(0xFF1FA85C), // Emerald
      'type': 'OCR',
    },
    {
      'id': 'task-3',
      'title': 'Tính Cách Quái Vật Squad Roaster 👹',
      'subtitle': 'Phân tích chat log để tìm ra kẻ hủy diệt tình bạn',
      'progress': 0.40,
      'status': 'ANALYZING',
      'eta': '1 phút',
      'color': const Color(0xFFD8422B), // Red
      'type': 'ROAST',
    },
    {
      'id': 'task-4',
      'title': 'Bản Đồ Vibe Match Tìm Gái Xinh/Trai Đẹp 🗺️',
      'subtitle': 'Quét tọa độ check-in matching của hội bạn độc thân',
      'progress': 0.15,
      'status': 'SCANNING',
      'eta': '3 phút',
      'color': const Color(0xFF3D8BFF), // Blue
      'type': 'GEO',
    },
  ];

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    // Auto-dismiss overlay after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _showLoadingOverlay = false);
      }
    });
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
                task['eta'] = 'ai_hub.seconds'.tr(args: ['$remainingSeconds']);
              } else {
                task['eta'] = 'ai_hub.seconds'.tr(
                  args: ['${remainingSeconds ~/ 2}'],
                );
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
    _rotateController.dispose();
    _pulseController.dispose();
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
            content: Text(
              'ai_hub.overclock_success'.tr(args: ['${task['title']}']),
            ),
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
          content: Text('ai_hub.task_cancelled'.tr(args: ['${task['title']}'])),
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
    final primaryColor = isDark
        ? const Color(0xFFC9B8FF)
        : const Color(0xFFF5822B);
    final secondaryColor = isDark
        ? const Color(0xFF1FA85C)
        : const Color(0xFF059669);
    final backgroundColor = isDark
        ? const Color(0xFF1A1712)
        : const Color(0xFFFDF6D3);
    final surfaceColor = isDark
        ? const Color(0xFF262019)
        : const Color(0xFFFFFDF5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // MAIN QUEUE CONTENT
          _buildQueueBody(
            context,
            isDark,
            primaryColor,
            secondaryColor,
            backgroundColor,
            surfaceColor,
          ),
          // MATEY IS COOKING OVERLAY
          if (_showLoadingOverlay)
            _buildCookingOverlay(context, isDark, primaryColor, secondaryColor),
        ],
      ),
    );
  }

  Widget _buildCookingOverlay(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _showLoadingOverlay = false),
      child: Container(
        color: (isDark ? const Color(0xFF1A1712) : Colors.white).withValues(
          alpha: 0.95,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated orbital spinner
              AnimatedBuilder(
                animation: _rotateController,
                builder: (_, child) {
                  return SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer rotating ring
                        Transform.rotate(
                          angle: _rotateController.value * 2 * math.pi,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  primaryColor.withValues(alpha: 0),
                                  primaryColor,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // White mask for donut effect
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? const Color(0xFF1A1712)
                                : Colors.white,
                          ),
                        ),
                        // Inner pulsing sparkle
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (_, child) => Icon(
                            Icons.auto_awesome,
                            color: primaryColor,
                            size: 44 + 8 * _pulseController.value,
                          ),
                        ),
                        // Orbiting particles
                        ...List.generate(6, (i) {
                          final angle =
                              _rotateController.value * 2 * math.pi +
                              i * math.pi / 3;
                          final radius = 62.0;
                          return Transform.translate(
                            offset: Offset(
                              math.cos(angle) * radius,
                              math.sin(angle) * radius,
                            ),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i.isEven ? primaryColor : secondaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (i.isEven
                                                ? primaryColor
                                                : secondaryColor)
                                            .withValues(alpha: 0.6),
                                    blurRadius: 0,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [primaryColor, primaryColor],
                ).createShader(bounds),
                child: Text(
                  'Matey is cooking...',
                  style: AppFonts.heading(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Curating the perfect vibe for the squad.',
                style: AppFonts.body(
                  fontSize: 15,
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Tap to see queue',
                style: AppFonts.body(
                  fontSize: 12,
                  color: isDark ? Colors.white30 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueueBody(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
    Color backgroundColor,
    Color surfaceColor,
  ) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AI Generation Queue 🖥️',
          style: AppFonts.heading(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: () {
              setState(() {
                for (var task in _tasks) {
                  if (task['status'] == 'COMPLETED') {
                    task['progress'] = 0.50;
                    task['status'] = 'RENDERING';
                    task['eta'] = '30s';
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
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🧠', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ai_hub.matey_advice_title'.tr(),
                          style: AppFonts.heading(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ai_hub.matey_advice_body'.tr(),
                          style: AppFonts.heading(
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
              'ai_hub.tasks_processing'.tr(
                args: ['${_tasks.where((t) => t['progress'] < 1.0).length}'],
              ),
              style: AppFonts.heading(
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
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF5822B).withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFFF5822B),
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ai_hub.empty_queue'.tr(),
                        style: AppFonts.heading(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Queue is clear — Matey is ready',
                        style: AppFonts.body(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  final isCompleted = task['progress'] >= 1.0;
                  final Color baseColor = task['color'] as Color;

                  String taskTitle = task['title'] as String;
                  String taskSubtitle = task['subtitle'] as String;

                  if (task['id'] == 'task-1') {
                    taskSubtitle = 'ai_hub.kyoto_task'.tr();
                  } else if (task['id'] == 'task-2') {
                    taskTitle = 'ai_hub.ocr_task_title'.tr();
                    taskSubtitle = 'ai_hub.ocr_task_sub'.tr();
                  } else if (task['id'] == 'task-3') {
                    taskTitle = 'ai_hub.roast_task_title'.tr();
                    taskSubtitle = 'ai_hub.roast_task_sub'.tr();
                  } else if (task['id'] == 'task-4') {
                    taskTitle = 'ai_hub.vibe_map_title'.tr();
                    taskSubtitle = 'ai_hub.vibe_map_sub'.tr();
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCompleted
                            ? Colors.green.withValues(alpha: 0.3)
                            : baseColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 0,
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? Colors.green.withValues(
                                                alpha: 0.15,
                                              )
                                            : baseColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isCompleted
                                            ? 'COMPLETED'
                                            : task['status'] as String,
                                        style: AppFonts.heading(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isCompleted
                                              ? Colors.green
                                              : baseColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      taskTitle,
                                      style: AppFonts.heading(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // ETA or Xong label
                              Text(
                                isCompleted
                                    ? 'ai_hub.completed'.tr()
                                    : 'ETA: ${task['eta']}',
                                style: AppFonts.heading(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted
                                      ? Colors.green
                                      : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            taskSubtitle,
                            style: AppFonts.heading(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
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
                                        color: isDark
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      height: 8,
                                      width:
                                          (MediaQuery.of(context).size.width -
                                              120) *
                                          task['progress'],
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? Colors.green
                                            : baseColor,
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isCompleted
                                                ? Colors.green.withValues(
                                                    alpha: 0.3,
                                                  )
                                                : baseColor.withValues(
                                                    alpha: 0.3,
                                                  ),
                                            blurRadius: 0,
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
                                style: AppFonts.heading(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isCompleted
                                      ? Colors.green
                                      : (isDark
                                            ? Colors.white
                                            : Colors.black87),
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
                                  icon: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.redAccent,
                                  ),
                                  label: Text(
                                    'ai_hub.cancel'.tr(),
                                    style: AppFonts.heading(
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(
                                    Icons.flash_on,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'ai_hub.boost'.tr(),
                                    style: AppFonts.heading(
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
                                        content: Text(
                                          'ai_hub.task_done_toast'.tr(
                                            args: [taskTitle],
                                          ),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  label: Text(
                                    'ai_hub.view_result'.tr(),
                                    style: AppFonts.heading(
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
                itemCount: _tasks.length,
              ),
          ],
        ),
      ),
    );
  }
}
