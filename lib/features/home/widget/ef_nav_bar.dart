import 'package:flutter/material.dart';
import 'package:myttmi/core/constants/app_colors.dart';

class EFNavItem {
  final String label;
  final IconData icon;

  const EFNavItem({
    required this.label,
    required this.icon,
  });
}

class EFBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<EFNavItem> items;

  /// Si quieres que se vea EXACTO como la barra morada (plana),
  /// usa un color sólido acá.
  final Color? backgroundColor;

  /// Alto de la barra
  final double height;

  const EFBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.height = 64,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary; // o AppColors.deep
    final inactive = AppColors.text.withOpacity(0.70);

    return Material(
      color: bg,
      elevation: 10, // sombra suave como “pegada” abajo
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 24,
                        color: isActive ? AppColors.electric : inactive,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                          color: isActive ? AppColors.electric : inactive,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
