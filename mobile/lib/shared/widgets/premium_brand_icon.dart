import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PremiumBrandIcon extends StatefulWidget {
  const PremiumBrandIcon({super.key});

  @override
  State<PremiumBrandIcon> createState() => _PremiumBrandIconState();
}

class _PremiumBrandIconState extends State<PremiumBrandIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
          offset: Offset(0, -_animation.value),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.stitchIndigo.withValues(alpha: 0.2),
                  AppColors.stitchPurple.withValues(alpha: 0.2),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.stitchIndigo.withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.all_inclusive_rounded,
                size: 32,
                color: Color(0xFFA5B4FC),
              ),
            ),
          ),
        );
      },
    );
  }
}
