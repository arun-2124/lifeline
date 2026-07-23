import 'package:flutter/material.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String status;

  const StatusBadgeWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status.trim().toLowerCase()) {
      case 'pending':
      case 'published':
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF0D6EFD);
        break;
      case 'matched':
      case 'accepted':
        bg = const Color(0xFFFFF3CD);
        fg = const Color(0xFF856404);
        break;
      case 'picked up':
      case 'in_transit':
        bg = const Color(0xFFE2E3E5);
        fg = const Color(0xFF383D41);
        break;
      case 'delivered':
      case 'completed':
        bg = const Color(0xFFD1E7DD);
        fg = const Color(0xFF0F5132);
        break;
      case 'cancelled':
      case 'expired':
        bg = const Color(0xFFF8D7DA);
        fg = const Color(0xFF842029);
        break;
      default:
        bg = const Color(0xFFE9ECEF);
        fg = const Color(0xFF495057);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
