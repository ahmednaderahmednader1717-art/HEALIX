// مجموعة كروت متلاصقة وقابلة للنقر
import 'package:flutter/material.dart';
import 'package:test_splash/core/app_colors.dart';

class ProfileCardItem {
  final String title;
  final IconData? icon;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool arrow;
  ProfileCardItem({
    required this.title,
    this.icon,
    this.subtitle,
    this.onTap,
    this.arrow = true,
  });
}

class ProfileCardGroup extends StatelessWidget {
  final List<ProfileCardItem> items;
  final double w, h;

  const ProfileCardGroup({
    super.key,
    required this.items,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items.length * 2 - 1, (i) {
        if (i.isEven) {
          final idx = i ~/ 2;
          return _InteractiveCard(
            item: items[idx],
            isFirst: idx == 0,
            isLast: idx == items.length - 1,
            w: w,
            h: h,
          );
        } else {
          return Divider(
            endIndent: 20,
            indent: 72 * w, // Align with text
            height: 0,
            thickness: 0.8 * h,
            color: Colors.white.withValues(alpha: 0.08),
          );
        }
      }),
    );
  }
}

class _InteractiveCard extends StatefulWidget {
  final ProfileCardItem item;
  final bool isFirst;
  final bool isLast;
  final double w, h;

  const _InteractiveCard({
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.w,
    required this.h,
  });

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        Future.delayed(const Duration(milliseconds: 20), () {
          if (widget.item.onTap != null) widget.item.onTap!();
        });
      },
      onTapCancel: () => _controller.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.ContainerColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(widget.isFirst ? 20 : 0),
              bottom: Radius.circular(widget.isLast ? 20 : 0),
            ),
          ),
          child: _buildCardContent(),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    final item = widget.item;
    final w = widget.w;
    final h = widget.h;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18 * h, horizontal: 18 * w),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: Colors.white, size: 22 * w),
          ),
          SizedBox(width: 16 * w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * w,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.subtitle!,
                      style: TextStyle(color: Colors.grey, fontSize: 13 * w),
                    ),
                  ),
              ],
            ),
          ),
          if (item.arrow)
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16 * w),
        ],
      ),
    );
  }
}
