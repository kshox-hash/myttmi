import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:myttmi/core/constants/app_colors.dart';

class LiquidTickerBar extends StatelessWidget {
  final String textA;
  final String textB;
  final double pixelsPerSecond;
  final double gap;
  final Duration pauseAfterA;
  final Duration liquidEvery;

  const LiquidTickerBar({
    super.key,
    required this.textA,
    required this.textB,
    required this.pixelsPerSecond,
    required this.gap,
    required this.pauseAfterA,
    required this.liquidEvery,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidWobble(
      every: liquidEvery,
      intensity: 1.15,
      child: Container(
        child: Row(
          children: [
            const Icon(
              Icons.graphic_eq,
              size: 16,
              color: AppColors.electric,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DualMarquee(
                textA: textA,
                textB: textB,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
                pixelsPerSecond: pixelsPerSecond,
                gap: gap,
                pauseAfterA: pauseAfterA,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiquidWobble extends StatefulWidget {
  final Widget child;
  final Duration every;
  final double intensity;

  const LiquidWobble({
    super.key,
    required this.child,
    required this.every,
    this.intensity = 1.0,
  });

  @override
  State<LiquidWobble> createState() => _LiquidWobbleState();
}

class _LiquidWobbleState extends State<LiquidWobble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  static const _activeDuration = Duration(milliseconds: 1250);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _activeDuration);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller
        ..stop()
        ..reset()
        ..forward();
    });

    _timer = Timer.periodic(widget.every, (_) {
      if (!mounted) return;
      _controller
        ..stop()
        ..reset()
        ..forward();
    });
  }

  @override
  void didUpdateWidget(covariant LiquidWobble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.every != widget.every) {
      _timer?.cancel();
      _timer = Timer.periodic(widget.every, (_) {
        if (!mounted) return;
        _controller
          ..stop()
          ..reset()
          ..forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intensity = widget.intensity.clamp(0.0, 2.5);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final fade = (1 - t);

        final w1 = math.sin(t * math.pi * 6) * 0.9 * fade;
        final w2 = math.sin(t * math.pi * 10) * 0.5 * fade;

        final dx = (w1 * 0.9 + w2 * 0.45) * intensity;
        final dy = (w2 * 0.7) * intensity;

        final rot = (w1 * 0.0024) * intensity;
        final scaleY = 1.0 + (w2 * 0.010) * intensity;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: rot,
            child: Transform.scale(
              scaleX: 1.0,
              scaleY: scaleY,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class DualMarquee extends StatefulWidget {
  final String textA;
  final String textB;
  final TextStyle style;
  final double pixelsPerSecond;
  final double gap;
  final Duration pauseAfterA;

  const DualMarquee({
    super.key,
    required this.textA,
    required this.textB,
    required this.style,
    this.pixelsPerSecond = 30,
    this.gap = 30,
    this.pauseAfterA = const Duration(seconds: 3),
  });

  @override
  State<DualMarquee> createState() => _DualMarqueeState();
}

class _DualMarqueeState extends State<DualMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double _boxWidth = 0;
  double _aWidth = 0;
  double _bWidth = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  double _measureTextWidth(String text) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.size.width;
  }

  void _recalcAndRestart() {
    if (!mounted) return;
    if (_boxWidth <= 0) return;

    final newA = _measureTextWidth(widget.textA);
    final newB = _measureTextWidth(widget.textB);

    final pausePx =
        widget.pixelsPerSecond * widget.pauseAfterA.inMilliseconds / 1000.0;
    final totalDistance = newA + pausePx + newB + widget.gap;

    setState(() {
      _aWidth = newA;
      _bWidth = newB;
    });

    if (totalDistance <= _boxWidth) {
      _controller.stop();
      return;
    }

    final seconds = totalDistance / widget.pixelsPerSecond;

    _controller
      ..stop()
      ..duration = Duration(milliseconds: (seconds * 1000).round())
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recalcAndRestart());
  }

  @override
  void didUpdateWidget(covariant DualMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textA != widget.textA ||
        oldWidget.textB != widget.textB ||
        oldWidget.style != widget.style ||
        oldWidget.pixelsPerSecond != widget.pixelsPerSecond ||
        oldWidget.gap != widget.gap ||
        oldWidget.pauseAfterA != widget.pauseAfterA) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _recalcAndRestart());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;

      if (w != _boxWidth) {
        _boxWidth = w;
        WidgetsBinding.instance.addPostFrameCallback((_) => _recalcAndRestart());
      }

      final pausePx =
          widget.pixelsPerSecond * widget.pauseAfterA.inMilliseconds / 1000.0;
      final totalDistance = _aWidth + pausePx + _bWidth + widget.gap;

      if (_aWidth == 0 || _bWidth == 0 || totalDistance <= _boxWidth) {
        return Text(
          "${widget.textA}   ${widget.textB}",
          style: widget.style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }

      return ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final distance = totalDistance;
            final x = -t * distance;

            return Stack(
              children: [
                Transform.translate(
                  offset: Offset(x, 0),
                  child: _marqueeRow(pausePx),
                ),
                Transform.translate(
                  offset: Offset(x + distance, 0),
                  child: _marqueeRow(pausePx),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _marqueeRow(double pausePx) {
    return OverflowBox(
      alignment: Alignment.centerLeft,
      minWidth: 0,
      maxWidth: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.textA, style: widget.style, maxLines: 1),
          SizedBox(width: pausePx),
          Text(widget.textB, style: widget.style, maxLines: 1),
          SizedBox(width: widget.gap),
        ],
      ),
    );
  }
}
