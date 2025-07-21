/*
 * @Author: LeeZB
 * @Date: 2025-07-08 16:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-08 16:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreviewWidget extends StatefulWidget {
  const ImagePreviewWidget({
    super.key,
    required this.images,
    required this.initialIndex,
    this.onDelete,
    this.onImagesChanged,
  });

  final List<File> images;
  final int initialIndex;
  final Function(int index)? onDelete;
  final Function(List<File>)? onImagesChanged;

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  late PageController _pageController;
  late int _currentIndex;
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _images = List.from(widget.images);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _deleteCurrentImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图片'),
        content: const Text('确定要删除这张图片吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDelete();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _performDelete() {
    if (_images.isNotEmpty) {
      setState(() {
        _images.removeAt(_currentIndex);
      });

      widget.onDelete?.call(_currentIndex);
      widget.onImagesChanged?.call(_images);

      if (_images.isEmpty) {
        Navigator.pop(context);
        return;
      }

      if (_currentIndex >= _images.length) {
        _currentIndex = _images.length - 1;
      }

      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 图片预览区域
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Center(
                  child: Image.file(
                    _images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // 顶部工具栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        '${_currentIndex + 1} / ${_images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (widget.onDelete != null)
                      IconButton(
                        onPressed: _deleteCurrentImage,
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // 底部缩略图导航
          if (_images.length > 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _currentIndex;
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                _images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.white54,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
