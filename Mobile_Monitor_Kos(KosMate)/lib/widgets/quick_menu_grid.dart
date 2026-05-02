import 'package:flutter/material.dart';
import 'animations.dart';

class QuickMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  QuickMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class QuickMenuGrid extends StatelessWidget {
  final List<QuickMenuItem> menus;

  const QuickMenuGrid({super.key, required this.menus});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Lebar item adalah lebar maksimal dibagi 3, dikurangi total spasi (12 * 2) dibagi 3
        final double itemWidth = (constraints.maxWidth - 24) / 3;
        
        return DelayedFadeIn(
          delay: 400,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: menus.map((menu) => SizedBox(
              width: itemWidth,
              child: _buildMenuIcon(menu),
            )).toList(),
          ),
        );
      }
    );
  }

  Widget _buildMenuIcon(QuickMenuItem menu) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: menu.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.black.withOpacity(0.02)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(menu.icon, color: menu.color, size: 28),
              const SizedBox(height: 8),
              Text(
                menu.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
