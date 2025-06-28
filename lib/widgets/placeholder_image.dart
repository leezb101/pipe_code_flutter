/*
 * @Author: LeeZB
 * @Date: 2025-06-28 15:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 15:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({
    super.key,
    this.width = 200,
    this.height = 200,
    this.backgroundColor = Colors.grey,
    this.icon = Icons.image,
    this.iconColor = Colors.white,
    this.text,
  });

  final double width;
  final double height;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: backgroundColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: width * 0.3,
            color: iconColor.withValues(alpha: 0.7),
          ),
          if (text != null) ...[
            const SizedBox(height: 8),
            Text(
              text!,
              style: TextStyle(
                color: iconColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class AvatarPlaceholder extends StatelessWidget {
  const AvatarPlaceholder({
    super.key,
    this.size = 50,
    this.backgroundColor = Colors.blue,
    this.initials,
  });

  final double size;
  final Color backgroundColor;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: initials != null
            ? Text(
                initials!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                Icons.person,
                size: size * 0.6,
                color: Colors.white,
              ),
      ),
    );
  }
}