/*
 * @Author: LeeZB
 * @Date: 2025-06-28 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:ui';
import 'package:flutter/material.dart';
import 'toast_type.dart';

class IOSToast extends StatefulWidget {
  const IOSToast({
    super.key,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.showIcon = true,
  });

  final String message;
  final ToastType type;
  final Duration duration;
  final bool showIcon;

  @override
  State<IOSToast> createState() => _IOSToastState();
}

class _IOSToastState extends State<IOSToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _showToast();
  }

  void _showToast() async {
    await _animationController.forward();
    await Future.delayed(widget.duration);
    if (mounted) {
      await _animationController.reverse();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 350),
                          decoration: BoxDecoration(
                            color: widget.type.backgroundColor.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                offset: const Offset(0, 12),
                                blurRadius: 30,
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: widget.type.backgroundColor.withValues(alpha: 0.2),
                                offset: const Offset(0, 4),
                                blurRadius: 12,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.showIcon) ...[
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Icon(
                                      widget.type.icon,
                                      color: widget.type.textColor,
                                      size: 24,
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(width: 16),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: widget.showIcon ? 0 : 16,
                                    ),
                                    child: Text(
                                      widget.message,
                                      style: TextStyle(
                                        color: widget.type.textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          );
        },
      ),
    );
  }
}