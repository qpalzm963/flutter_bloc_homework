import 'dart:math';
import 'package:flutter/material.dart';

class RouletteWheel extends StatefulWidget {
  final List<String> participants;
  final String? winner; // 用于高亮显示赢家
  final bool isDrawing; // 是否正在抽奖

  const RouletteWheel({
    super.key,
    required this.participants,
    this.winner,
    this.isDrawing = false,
  });

  @override
  State<RouletteWheel> createState() => _RouletteWheelState();
}

class _RouletteWheelState extends State<RouletteWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 动画持续时间
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
  }

  @override
void didUpdateWidget(covariant RouletteWheel oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.isDrawing && !oldWidget.isDrawing) {
    // 开始抽奖动画
    _controller.reset();
    // 随机旋转角度，确保每次旋转都不同
    final random = Random();
    final fullRotations = random.nextInt(5) + 5; // 5-9圈
    final targetAngle = random.nextDouble() * 2 * pi; // 最终停止的角度

    // 计算赢家所在的扇区角度范围
    if (widget.winner != null && widget.participants.isNotEmpty) {
      final segmentAngle = 2 * pi / widget.participants.length;
      final winnerIndex = widget.participants.indexOf(widget.winner!); // 找到赢家索引
      if (winnerIndex != -1) {
        // 调整目标角度，使指针指向赢家扇区的中间
        // 假设指针在顶部（0弧度），扇区从右侧开始逆时针排列
        // 赢家扇区的起始角度
        final winnerStartAngle = winnerIndex * segmentAngle;
        // 赢家扇区的结束角度
        final winnerEndAngle = (winnerIndex + 1) * segmentAngle;
        // 赢家扇区的中心角度
        final winnerCenterAngle = (winnerStartAngle + winnerEndAngle) / 2;

        // 计算需要旋转到的角度，使指针指向赢家中心
        // 考虑轮盘的起始方向和旋转方向
        // 假设轮盘顺时针旋转，指针固定在顶部
        // 那么赢家扇区的中心需要旋转到指针位置
        // 目标角度 = (2 * pi - winnerCenterAngle) % (2 * pi)
        // 确保目标角度在赢家扇区内，并且是顺时针旋转
        final adjustedTargetAngle = (2 * pi - winnerCenterAngle + random.nextDouble() * segmentAngle - segmentAngle / 2) % (2 * pi);
        _animation = Tween<double>(begin: 0, end: fullRotations * 2 * pi + adjustedTargetAngle).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      } else {
        // 如果赢家不在列表中，则随机停止
        _animation = Tween<double>(begin: 0, end: fullRotations * 2 * pi + targetAngle).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      }
    } else {
      // 没有赢家或参与者，则随机停止
      _animation = Tween<double>(begin: 0, end: fullRotations * 2 * pi + targetAngle).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    }

    _controller.forward().whenComplete(() {
      // 动画结束后，如果需要，可以通知 BLoC 动画已完成
    });
  } else if (!widget.isDrawing && oldWidget.isDrawing) {
    // 抽奖结束，停止动画
    _controller.stop();
  }
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: CustomPaint(
            painter: _RoulettePainter(
              participants: widget.participants,
              winner: widget.winner,
              isDrawing: widget.isDrawing,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _RoulettePainter extends CustomPainter {
  final List<String> participants;
  final String? winner;
  final bool isDrawing;

  _RoulettePainter({
    required this.participants,
    this.winner,
    required this.isDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    if (participants.isEmpty) {
      final paint = Paint()..color = Colors.grey[300]!;
      canvas.drawCircle(center, radius, paint);
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '添加参与者',
          style: TextStyle(color: Colors.black54, fontSize: 20),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
      return;
    }

    final segmentAngle = 2 * pi / participants.length;

    for (int i = 0; i < participants.length; i++) {
      final startAngle = i * segmentAngle;
      final endAngle = (i + 1) * segmentAngle;

      final isWinnerSegment = !isDrawing && winner != null && participants[i] == winner;

      final paint = Paint()
        ..color = isWinnerSegment ? Colors.amber : _getColor(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // 绘制边框
      final borderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      // 绘制参与者名字
      final textPainter = TextPainter(
        text: TextSpan(
          text: participants[i],
          style: TextStyle(
            color: isWinnerSegment ? Colors.black : Colors.white,
            fontSize: 16,
            fontWeight: isWinnerSegment ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: radius * 0.8);

      // 计算文本位置
      final textAngle = startAngle + segmentAngle / 2; // 扇形中心角度
      final textX = center.dx + radius * 0.6 * cos(textAngle);
      final textY = center.dy + radius * 0.6 * sin(textAngle);

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi / 2); // 旋转文本使其与扇形对齐
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    // 绘制中心圆
    final centerCirclePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.2, centerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant _RoulettePainter oldDelegate) {
    return oldDelegate.participants != participants ||
        oldDelegate.winner != winner ||
        oldDelegate.isDrawing != isDrawing;
  }

  Color _getColor(int index) {
    final colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal,
      Colors.brown, Colors.indigo, Colors.cyan, Colors.pink, Colors.lime,
    ];
    return colors[index % colors.length];
  }
}
