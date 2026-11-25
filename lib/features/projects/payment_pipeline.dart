import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/animations/motion.dart';
import '../../core/animations/reveal.dart';

/// Illustration for JerseyMEP: its payment flow drawn as pipework. Stands in
/// for screenshots and does not imitate the app's interface.
class PaymentPipeline extends StatefulWidget {
  const PaymentPipeline({super.key, required this.active});

  final bool active;

  @override
  State<PaymentPipeline> createState() => _PaymentPipelineState();
}

class _PaymentPipelineState extends State<PaymentPipeline> with SingleTickerProviderStateMixin {
  late final AnimationController _flow = AnimationController(vsync: this, duration: const Duration(seconds: 3));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFlow();
  }

  @override
  void didUpdateWidget(PaymentPipeline old) {
    super.didUpdateWidget(old);
    if (widget.active != old.active) _syncFlow();
  }

  void _syncFlow() {
    final shouldRun = widget.active && !reduceMotionOf(context);
    if (shouldRun && !_flow.isAnimating) {
      _flow.repeat();
    } else if (!shouldRun) {
      // Back to zero so no pulse is left frozen in the pipes.
      _flow.reset();
    }
  }

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Illustration: a payment starts, then branches to success or failure, drawn as pipework',
      child: ExcludeSemantics(
        child: RevealBuilder(
          duration: const Duration(milliseconds: 1100),
          builder: (context, progress) => CustomPaint(
            painter: _PipelinePainter(build: progress, flow: _flow),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _PipelinePainter extends CustomPainter {
  _PipelinePainter({required this.build, required this.flow}) : super(repaint: Listenable.merge([build, flow]));

  final Animation<double> build;
  final Animation<double> flow;

  static const _failure = Color(0xFFFF8FA3);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final unit = (w < h ? w : h) / 100;
    final pipe = unit * 7;

    _grid(canvas, size);

    final start = Offset(w * 0.2, h * 0.3);
    final fork = Offset(w * 0.5, h * 0.56);
    final success = Offset(w * 0.8, h * 0.3);
    final failure = Offset(w * 0.8, h * 0.8);

    final inlet = _route([Offset(-pipe, start.dy), start, Offset(start.dx, fork.dy), fork], unit * 9);
    final toSuccess = _route([fork, Offset(success.dx, fork.dy), success, Offset(success.dx, -pipe)], unit * 9);
    final toFailure = _route([fork, Offset(fork.dx, failure.dy), failure, Offset(w + pipe, failure.dy)], unit * 9);

    final t = Curves.easeInOutCubic.transform(build.value);
    final first = (t / 0.5).clamp(0.0, 1.0);
    final second = ((t - 0.5) / 0.5).clamp(0.0, 1.0);

    _pipe(canvas, toFailure, second, pipe, _failure);
    _pipe(canvas, toSuccess, second, pipe, AppPalette.dark.mint);
    _pipe(canvas, inlet, first, pipe, AppPalette.dark.indigo);

    if (build.isCompleted && flow.value > 0) {
      final f = flow.value;
      _pulse(canvas, inlet, (f / 0.5).clamp(0.0, 1.0), pipe, f < 0.5);
      final branch = ((f - 0.5) / 0.5).clamp(0.0, 1.0);
      _pulse(canvas, toSuccess, branch, pipe, f >= 0.5);
      _pulse(canvas, toFailure, branch, pipe, f >= 0.5);
    }

    _valve(canvas, Offset(start.dx, (start.dy + fork.dy) / 2), unit, AppPalette.dark.indigo, first);
    _valve(canvas, fork, unit, AppPalette.dark.text, first, hub: true);
    _valve(canvas, success, unit, AppPalette.dark.mint, second);
    _valve(canvas, failure, unit, _failure, second);

    _label(canvas, 'Payment started', Offset(start.dx + unit * 10, (start.dy + fork.dy) / 2 - unit * 3), first, unit);
    _label(canvas, 'Success', success + Offset(-unit * 8, 0), second, unit, alignRight: true);
    _label(canvas, 'Failure', failure + Offset(0, unit * 9), second, unit, center: true);
  }

  void _grid(Canvas canvas, Size size) {
    final dot = Paint()..color = AppPalette.dark.text.withValues(alpha: 0.07);
    for (var x = 18.0; x < size.width; x += 26) {
      for (var y = 18.0; y < size.height; y += 26) {
        canvas.drawCircle(Offset(x, y), 1.1, dot);
      }
    }
  }

  /// Polyline with rounded elbows.
  Path _route(List<Offset> points, double radius) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length - 1; i++) {
      final before = points[i] - points[i - 1];
      final after = points[i + 1] - points[i];
      final enter = points[i] - before / before.distance * radius.clamp(0, before.distance / 2);
      final exit = points[i] + after / after.distance * radius.clamp(0, after.distance / 2);
      path
        ..lineTo(enter.dx, enter.dy)
        ..quadraticBezierTo(points[i].dx, points[i].dy, exit.dx, exit.dy);
    }
    return path..lineTo(points.last.dx, points.last.dy);
  }

  void _pipe(Canvas canvas, Path route, double t, double width, Color color) {
    if (t <= 0) return;
    for (final metric in route.computeMetrics()) {
      final part = metric.extractPath(0, metric.length * t);
      final base = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;
      canvas
        ..drawPath(
          part.shift(const Offset(0, 8)),
          base
            ..color = const Color(0x40000000)
            ..strokeWidth = width + 4,
        )
        ..drawPath(
          part,
          base
            ..color = Color.lerp(color, AppPalette.dark.background, 0.55)!
            ..strokeWidth = width,
        )
        ..drawPath(
          part,
          base
            ..color = color.withValues(alpha: 0.75)
            ..strokeWidth = width * 0.62,
        )
        ..drawPath(
          part.shift(Offset(-width * 0.1, -width * 0.12)),
          base
            ..color = AppPalette.dark.text.withValues(alpha: 0.28)
            ..strokeWidth = width * 0.14,
        );
    }
  }

  void _pulse(Canvas canvas, Path route, double t, double width, bool visible) {
    if (!visible) return;
    for (final metric in route.computeMetrics()) {
      final head = metric.length * t;
      canvas.drawPath(
        metric.extractPath((head - width * 2.4).clamp(0, metric.length), head),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = width * 0.34
          ..color = AppPalette.dark.text.withValues(alpha: 0.9),
      );
    }
  }

  void _valve(Canvas canvas, Offset center, double unit, Color color, double t, {bool hub = false}) {
    final pop = Curves.easeOutBack.transform(((t - 0.6) / 0.4).clamp(0.0, 1.0));
    if (pop <= 0) return;
    final r = unit * (hub ? 7.5 : 6) * pop;
    canvas
      ..drawCircle(center, r, Paint()..color = const Color(0xFF10132B))
      ..drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = unit * 1.2
          ..color = color,
      )
      ..drawCircle(center, r * 0.38, Paint()..color = color);
  }

  void _label(
    Canvas canvas,
    String text,
    Offset at,
    double t,
    double unit, {
    bool alignRight = false,
    bool center = false,
  }) {
    final alpha = ((t - 0.7) / 0.3).clamp(0.0, 1.0);
    if (alpha <= 0) return;
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const AppType(
          AppPalette.dark,
        ).label((unit * 4).clamp(13, 18), color: AppPalette.dark.text.withValues(alpha: alpha), weight: 600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = alignRight
        ? at.dx - painter.width
        : center
        ? at.dx - painter.width / 2
        : at.dx;
    painter
      ..paint(canvas, Offset(dx, at.dy - (center ? 0 : painter.height / 2)))
      ..dispose();
  }

  @override
  bool shouldRepaint(_PipelinePainter old) => old.build != build || old.flow != flow;
}
