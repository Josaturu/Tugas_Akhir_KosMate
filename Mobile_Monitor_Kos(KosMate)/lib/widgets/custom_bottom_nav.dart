import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;
  final bool isPremium;
  final bool hasCenterBulge; // Tambahkan flag untuk kontrol benjolan tengah

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.isPremium = false,
    this.hasCenterBulge = true, // Default true untuk Tenant
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isPremium ? 90 : 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isPremium ? const BorderRadius.vertical(top: Radius.circular(30)) : null,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 25,
            spreadRadius: 2,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          bool isSelected = currentIndex == index;
          
          // Logika untuk tombol tengah yang menonjol (bulge)
          bool isCenter = index == (items.length / 2).floor();

          if (isPremium && isCenter && hasCenterBulge) {
            return _buildCenterItem(index, item, isSelected);
          }

          return _buildNavItem(index, item, isSelected);
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem(int index, BottomNavigationBarItem item, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _getIconData(item.icon),
                color: isSelected ? Colors.orange : Colors.grey[400],
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label ?? '',
              style: TextStyle(
                color: isSelected ? Colors.orange : Colors.grey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterItem(int index, BottomNavigationBarItem item, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          transform: Matrix4.translationValues(0, -15, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Icon(
                  _getIconData(item.icon),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item.label ?? '',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(Widget iconWidget) {
    if (iconWidget is Icon && iconWidget.icon != null) return iconWidget.icon!;
    return Icons.circle;
  }
}
