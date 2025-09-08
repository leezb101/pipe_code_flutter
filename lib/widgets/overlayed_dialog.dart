import 'package:flutter/material.dart';

class OverlayedDialog extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onClose;

  const OverlayedDialog({super.key, this.child, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (child != null) child!,
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
