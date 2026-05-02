import 'package:flutter/material.dart';

class BreathingLogo extends StatefulWidget {
  const BreathingLogo({super.key});

  @override
  State<BreathingLogo> createState() => _BreathingLogoState();
}

class _BreathingLogoState extends State<BreathingLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    // Pulses the shadow spread from 2.0 to 12.0
    _glowAnimation = Tween<double>(
      begin: 2.0,
      end: 12.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: .circle,
            color: colors.surfaceContainer,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.4),
                blurRadius: _glowAnimation.value * 2,
                spreadRadius: _glowAnimation.value,
              ),
            ],
          ),
          child: Icon(
            Icons.cloud_sync_rounded,
            size: 50,
            color: colors.primary,
          ),
        );
      },
    );
  }
}
