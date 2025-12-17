import 'package:flutter/material.dart';
import '../utils/size_helper.dart';

/// Ortak boş durum widget'ı - responsive font ve padding ile
class EmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Widget? actionButton;
  final Color? iconColor;
  final Color? textColor;

  const EmptyState({
    super.key,
    required this.message,
    this.icon,
    this.actionButton,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = SizeHelper.isMobile(context);
    final isTablet = SizeHelper.isTablet(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : (isTablet ? 30 : 40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? Colors.white54,
                size: SizeHelper.clampFontSize(screenWidth, 32, 40, 48),
              ),
              SizedBox(height: isMobile ? 12 : 16),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor ?? Colors.white70,
                fontSize: SizeHelper.clampFontSize(screenWidth, 14, 16, 18),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (actionButton != null) ...[
              SizedBox(height: isMobile ? 16 : 20),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}

