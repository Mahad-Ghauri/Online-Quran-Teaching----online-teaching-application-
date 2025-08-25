// components/gradient_background.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
            const Color(0xFF6B73FF),
            const Color(0xFF9575FF),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated floating bubbles/circles for liquid effect
          ...List.generate(6, (index) => Positioned(
            top: (index * 150.0) % MediaQuery.of(context).size.height,
            left: (index * 80.0) % MediaQuery.of(context).size.width,
            child: AnimatedFloatingBubble(
              size: 100 + (index * 50.0),
              delay: Duration(milliseconds: index * 800),
            ),
          )),
          child,
        ],
      ),
    );
  }
}

class AnimatedFloatingBubble extends StatefulWidget {
  final double size;
  final Duration delay;

  const AnimatedFloatingBubble({
    super.key,
    required this.size,
    required this.delay,
  });

  @override
  State<AnimatedFloatingBubble> createState() => _AnimatedFloatingBubbleState();
}

class _AnimatedFloatingBubbleState extends State<AnimatedFloatingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3 + (widget.size / 50).round()),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
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
        return Transform.translate(
          offset: Offset(
            _animation.value * 20,
            _animation.value * 30,
          ),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}