import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = 1100.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= maxWidth) {
          return child;
        }

        return Container(
          color: const Color(0xFF0F172A),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              decoration: const BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
