import 'dart:ui';
import 'package:flutter/material.dart';

class PillNavItem {
  final IconData icon;
  final String label;
  const PillNavItem({required this.icon, required this.label});
}

class PillNavigationBar extends StatefulWidget {
  final List<PillNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color pillColor;
  final Color iconColor;
  final Color activeIconColor;

  const PillNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 64,
    this.borderRadius = 24,
    this.backgroundColor = const Color(0xFF1D1D1F),
    this.pillColor = Colors.white,
    this.iconColor = Colors.white60,
    this.activeIconColor = Colors.black,
  });

  @override
  State<PillNavigationBar> createState() => _PillNavigationBarState();
}

class _PillNavigationBarState extends State<PillNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final itemWidth = width / widget.items.length;
              final pillWidth = itemWidth * 0.6; // متناسق مع النص والأيقونة
              final pillHeight = widget.height * 0.64;
              final pillLeft =
                  (widget.selectedIndex * itemWidth) +
                  (itemWidth - pillWidth) / 2;

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // pill indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    left: pillLeft,
                    top: (widget.height - pillHeight) / 2,
                    width: pillWidth,
                    height: pillHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.pillColor,
                        borderRadius: BorderRadius.circular(pillHeight / 2),
                      ),
                    ),
                  ),

                  Row(
                    children: List.generate(widget.items.length, (index) {
                      final item = widget.items[index];
                      final isActive = index == widget.selectedIndex;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onChanged(index),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                color: isActive
                                    ? widget.activeIconColor
                                    : widget.iconColor,
                                fontWeight: FontWeight.w700,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 20,
                                    color: isActive
                                        ? widget.activeIconColor
                                        : widget.iconColor,
                                  ),
                                  if (isActive) ...[
                                    const SizedBox(width: 8),
                                    Text(item.label),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

