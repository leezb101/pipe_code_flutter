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
  /// Preview widget that supports either local [images] (File) or remote [imageUrls] (String URLs).
  /// Exactly one of [images] or [imageUrls] must be provided.
  const ImagePreviewWidget({
    super.key,
    this.images,
    this.imageUrls,
    required this.initialIndex,
    this.onDelete,
    this.onImagesChanged,
    this.onUrlsChanged,
  }) : assert(
         (images != null && imageUrls == null) ||
             (images == null && imageUrls != null),
         'Provide either images or imageUrls (one and only one).',
       );

  /// Local images to preview.
  final List<File>? images;

  /// Remote image URLs to preview.
  final List<String>? imageUrls;

  /// Initially selected index
  final int initialIndex;

  /// Called when the delete action is confirmed for current index
  final Function(int index)? onDelete;

  /// Called when local images list changes (after deletion)
  final Function(List<File>)? onImagesChanged;

  /// Called when URL list changes (after deletion)
  final Function(List<String>)? onUrlsChanged;

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  late PageController _pageController;
  late int _currentIndex;
  List<File> _images = [];
  List<String> _imageUrls = [];
  late bool _useUrls;

  int get _length => _useUrls ? _imageUrls.length : _images.length;

  @override
  void initState() {
    super.initState();
    _useUrls = widget.imageUrls != null;
    if (_useUrls) {
      _imageUrls = List.from(widget.imageUrls!);
    } else {
      _images = List.from(widget.images!);
    }

    // Clamp initial index within bounds when possible
    _currentIndex = widget.initialIndex;
    if (_length > 0) {
      if (_currentIndex < 0) _currentIndex = 0;
      if (_currentIndex >= _length) _currentIndex = _length - 1;
    } else {
      _currentIndex = 0;
    }

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
    if (_length == 0) return;

    setState(() {
      if (_useUrls) {
        _imageUrls.removeAt(_currentIndex);
      } else {
        _images.removeAt(_currentIndex);
      }
    });

    widget.onDelete?.call(_currentIndex);
    if (_useUrls) {
      widget.onUrlsChanged?.call(_imageUrls);
    } else {
      widget.onImagesChanged?.call(_images);
    }

    if (_length == 0) {
      Navigator.pop(context);
      return;
    }

    if (_currentIndex >= _length) {
      _currentIndex = _length - 1;
    }

    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_length == 0) {
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
            itemCount: _length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Center(
                  child: _useUrls
                      ? Image.network(
                          _imageUrls[index],
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
                        )
                      : Image.file(
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
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
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
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Row(
                    children: [
                      // Enlarged back button tap target
                      SizedBox(
                        width: 72,
                        height: kToolbarHeight,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.pop(context),
                          child: const Center(
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${_currentIndex + 1} / ${_length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (widget.onDelete != null)
                        SizedBox(
                          width: 72,
                          height: kToolbarHeight,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _deleteCurrentImage,
                            child: const Center(
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 底部缩略图导航
          if (_length > 1)
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
                      itemCount: _length,
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
                              child: _useUrls
                                  ? Image.network(
                                      _imageUrls[index],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[800],
                                              child: const Icon(
                                                Icons.broken_image,
                                                color: Colors.white54,
                                              ),
                                            );
                                          },
                                    )
                                  : Image.file(
                                      _images[index],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
