import 'package:flutter/material.dart';

import 'package:mobile_app/core/constants/app_colors.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool enableTilt;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 20.0,
    this.enableTilt = true,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  void _onPointerMove(PointerMoveEvent event, RenderBox box) {
    if (!widget.enableTilt) return;
    final center = box.size.center(Offset.zero);
    final position = event.localPosition - center;

    setState(() {
      _tiltX = (position.dy / center.dy) * 0.05; // max ~3 degrees
      _tiltY = -(position.dx / center.dx) * 0.05;
    });
  }

  void _onPointerReset() {
    if (!widget.enableTilt) return;
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Listener(
        onPointerMove: (event) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) _onPointerMove(event, box);
        },
        onPointerUp: (_) => _onPointerReset(),
        onPointerCancel: (_) => _onPointerReset(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateX(_tiltX)
            ..rotateY(_tiltY),
          transformAlignment: Alignment.center,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: AppColors.surfaceSubtle,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
