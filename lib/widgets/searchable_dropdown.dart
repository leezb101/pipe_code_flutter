/*
 * @Author: LeeZB
 * @Date: 2025-10-10
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-10-10
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:pipe_code_flutter/models/common/warehouse_vo.dart';
import 'package:rxdart/rxdart.dart';

/// 可搜索下拉组件（类似 Element UI 的 el-select）
///
/// 支持：
/// - 单一输入框，点击展开下拉列表
/// - 600ms 防抖搜索
/// - 实时过滤
/// - 点击外部自动关闭
/// - 页面导航时自动清理
class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final Widget Function(T) itemBuilder;
  final String Function(T item)? selectedLabelBuilder;
  final String? errorMessage;
  final String businessType;
  final String Function(T item) getSearchText;

  const SearchableDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
    this.selectedLabelBuilder,
    this.errorMessage,
    required this.businessType,
    required this.getSearchText,
  }) : super(key: key);

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>.seeded(
    '',
  );
  List<T> _filteredItems = [];
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _textController = TextEditingController(
      text: widget.value != null ? _getDisplayText(widget.value as T) : '',
    );

    // 设置防抖，600毫秒延迟
    _searchSubject.stream
        .debounceTime(const Duration(milliseconds: 600))
        .listen((searchText) {
          _filterItems(searchText);
        });

    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _textController.text = widget.value != null
          ? _getDisplayText(widget.value as T)
          : '';
    }
    if (oldWidget.items != widget.items) {
      _filterItems(_textController.text);
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && !_isDropdownOpen) {
      _showOverlay();
    } else if (!_focusNode.hasFocus && _isDropdownOpen) {
      _hideOverlay();
    }
  }

  String _getDisplayText(T item) {
    return widget.selectedLabelBuilder != null
        ? widget.selectedLabelBuilder!(item)
        : widget.getSearchText(item);
  }

  void _filterItems(String searchText) {
    if (!mounted) return;

    setState(() {
      if (searchText.isEmpty) {
        _filteredItems = widget.items;
      } else {
        final lowerSearch = searchText.toLowerCase();
        _filteredItems = widget.items.where((item) {
          final searchableText = widget.getSearchText(item).toLowerCase();
          return searchableText.contains(lowerSearch);
        }).toList();
      }
    });

    if (_isDropdownOpen) {
      _updateOverlay();
    }
  }

  void _showOverlay() {
    _isDropdownOpen = true;
    _filteredItems = widget.items;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;

    // 恢复显示已选择的值
    if (widget.value != null) {
      _textController.text = _getDisplayText(widget.value as T);
    }
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // 点击外部区域关闭下拉框
          _focusNode.unfocus();
        },
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, size.height + 5.0),
                child: GestureDetector(
                  onTap: () {
                    // 阻止事件冒泡，点击下拉列表内部不关闭
                  },
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _filteredItems.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                '没有匹配的结果',
                                style: TextStyle(color: AppTheme.grey600),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                final isSelected = widget.value == item;
                                return InkWell(
                                  onTap: () {
                                    widget.onChanged(item);
                                    _textController.text = _getDisplayText(
                                      item,
                                    );
                                    _focusNode.unfocus();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.getBusinessColor(
                                              widget.businessType,
                                            ).withOpacity(0.1)
                                          : null,
                                      border: index < _filteredItems.length - 1
                                          ? Border(
                                              bottom: BorderSide(
                                                color: Colors.grey[200]!,
                                                width: 1,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: widget.itemBuilder(item),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check,
                                            color: AppTheme.getBusinessColor(
                                              widget.businessType,
                                            ),
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    // 页面切换或组件被移出树时，确保关闭浮层
    if (_isDropdownOpen) {
      _hideOverlay();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _hideOverlay();
    _textController.dispose();
    _focusNode.dispose();
    _searchSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage != null) {
      return Row(
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.getBusinessColor(widget.businessType),
            ),
          ),
          SizedBox(width: AppTheme.spacingSmall),
          Expanded(
            child: Text(
              widget.errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: '输入关键词搜索或点击选择',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_textController.text.isNotEmpty && _focusNode.hasFocus)
                IconButton(
                  icon: Icon(Icons.clear, color: AppTheme.grey600, size: 20),
                  onPressed: () {
                    _textController.clear();
                    _searchSubject.add('');
                    widget.onChanged(null);
                  },
                ),
              Icon(
                _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: AppTheme.getBusinessColor(widget.businessType),
              ),
              SizedBox(width: 8),
            ],
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(
              color: AppTheme.getBusinessColor(widget.businessType),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {}); // 更新清除按钮显示
          _searchSubject.add(value);
        },
        onTap: () {
          if (!_isDropdownOpen) {
            _showOverlay();
          }
        },
      ),
    );
  }
}

/// 构建仓库下拉项的显示组件
/// 显示仓库名称、地址和类型标识（独立仓库/项目现场）
Widget buildWarehouseItemWidget(WarehouseVO warehouse) {
  return Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 仓库名称和地址
            Text('${warehouse.name} - ${warehouse.address}'),
            SizedBox(height: 2),
            // 仓库类型标识
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: warehouse.isRealWarehouse
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                warehouse.isRealWarehouse ? '独立仓库' : '项目现场',
                style: TextStyle(
                  fontSize: 11,
                  color: warehouse.isRealWarehouse ? Colors.blue : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
