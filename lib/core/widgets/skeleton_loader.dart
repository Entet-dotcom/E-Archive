import 'package:flutter/material.dart';

/// Pulsing placeholder used while content is loading.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 12,
    this.borderRadius = 6,
  });

  final double? width;
  final double height;
  final double borderRadius;

  static const baseColor = Color(0xFFE2E8F0);
  static const highlightColor = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    final pulse = SkeletonPulseScope.of(context);
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Color.lerp(baseColor, highlightColor, pulse.value),
          ),
        );
      },
    );
  }
}

/// Wraps skeleton children with a shared pulse animation.
class SkeletonPulseScope extends StatefulWidget {
  const SkeletonPulseScope({super.key, required this.child});

  final Widget child;

  static Animation<double> of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SkeletonPulseData>();
    assert(scope != null, 'SkeletonBox must be inside SkeletonPulseScope');
    return scope!.animation;
  }

  @override
  State<SkeletonPulseScope> createState() => _SkeletonPulseScopeState();
}

class _SkeletonPulseScopeState extends State<SkeletonPulseScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SkeletonPulseData(
      animation: _animation,
      child: widget.child,
    );
  }
}

class _SkeletonPulseData extends InheritedWidget {
  const _SkeletonPulseData({
    required this.animation,
    required super.child,
  });

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_SkeletonPulseData oldWidget) =>
      oldWidget.animation != animation;
}
