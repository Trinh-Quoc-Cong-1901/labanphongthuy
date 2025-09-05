import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated rotation widget for smooth compass movement
class AnimatedCompassRotation extends StatelessWidget {
  final double angle; // in radians
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedCompassRotation({
    super.key,
    required this.angle,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: angle,
        end: angle,
      ),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Alternative implementation using implicit animations
class SmoothRotationTransition extends StatefulWidget {
  final double angle;
  final Widget child;
  final Duration duration;
  final Curve curve;

  const SmoothRotationTransition({
    super.key,
    required this.angle,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOutQuad,
  });

  @override
  State<SmoothRotationTransition> createState() => _SmoothRotationTransitionState();
}

class _SmoothRotationTransitionState extends State<SmoothRotationTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentAngle = 0;
  double _targetAngle = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _currentAngle = widget.angle;
    _targetAngle = widget.angle;
    _animation = Tween<double>(
      begin: _currentAngle,
      end: _targetAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void didUpdateWidget(SmoothRotationTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.angle != widget.angle) {
      _currentAngle = _animation.value;
      _targetAngle = widget.angle;
      
      // Calculate shortest rotation path
      double diff = _targetAngle - _currentAngle;
      
      // Normalize to [-π, π]
      while (diff > math.pi) {
        diff -= 2 * math.pi;
      }
      while (diff < -math.pi) {
        diff += 2 * math.pi;
      }
      
      _targetAngle = _currentAngle + diff;
      
      _animation = Tween<double>(
        begin: _currentAngle,
        end: _targetAngle,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
      
      _controller.forward(from: 0);
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
          child: child,
        );
      },
      child: widget.child,
    );
  }
}