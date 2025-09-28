import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWithWatermark extends StatelessWidget {
  final CameraController controller;
  final String? watermarkText;
  final TextStyle? watermarkStyle;
  final Alignment watermarkAlignment;
  final EdgeInsets watermarkPadding;

  const CameraPreviewWithWatermark({
    super.key,
    required this.controller,
    this.watermarkText,
    this.watermarkStyle,
    this.watermarkAlignment = Alignment.bottomRight,
    this.watermarkPadding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraPreview(controller),
        if (watermarkText != null)
          WatermarkOverlay(
            text: watermarkText!,
            style: watermarkStyle,
            alignment: watermarkAlignment,
            padding: watermarkPadding,
          ),
      ],
    );
  }
}

class WatermarkOverlay extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Alignment alignment;
  final EdgeInsets padding;

  const WatermarkOverlay({
    super.key,
    required this.text,
    this.style,
    this.alignment = Alignment.bottomRight,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        padding: padding,
        child: Align(
          alignment: alignment,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              text,
              style:
                  style ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
