import 'package:flutter/material.dart';

class OnlineStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final double size;
  final bool showBorder;

  const OnlineStatusIndicator({
    super.key,
    required this.isOnline,
    this.size = 12,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: Colors.white,
                width: 2,
              )
            : null,
        boxShadow: isOnline
            ? [
                BoxShadow(
                  color: const Color(0xFF16A34A).withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}

class OnlineStatusBadge extends StatelessWidget {
  final bool isOnline;
  final Widget child;
  final double badgeSize;
  final Alignment alignment;

  const OnlineStatusBadge({
    super.key,
    required this.isOnline,
    required this.child,
    this.badgeSize = 12,
    this.alignment = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: OnlineStatusIndicator(
              isOnline: isOnline,
              size: badgeSize,
            ),
          ),
        ),
      ],
    );
  }
}
