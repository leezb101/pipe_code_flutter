import 'package:flutter/material.dart';
import '../models/records/record_type.dart';

class ExpandableTabBar extends StatefulWidget {
  final RecordType selectedTab;
  final Function(RecordType) onTabSelected;
  final List<RecordType> allTabs;

  const ExpandableTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    required this.allTabs,
  });

  @override
  State<ExpandableTabBar> createState() => _ExpandableTabBarState();
}

class _ExpandableTabBarState extends State<ExpandableTabBar>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  bool get _hasMoreTabs => widget.allTabs.length > 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _buildTabSection(),
    );
  }

  Widget _buildTabSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 首行：单行布局，不允许换行
          _buildFirstRow(),
          // 展开的额外内容区域
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _animation,
                child: child,
              );
            },
            child: _buildExpandedContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstRow() {
    final firstRowTabs = _getFirstRowTabs();
    
    return Row(
      children: [
        // 左侧：首行tab列表
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: firstRowTabs.map((tab) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildTabChip(tab),
              )).toList(),
            ),
          ),
        ),
        // 右侧：展开/收起按钮
        if (_hasMoreTabs && !_isExpanded)
          _buildInlineExpandButton(),
      ],
    );
  }

  Widget _buildExpandedContent() {
    if (!_hasMoreTabs || !_isExpanded) return const SizedBox.shrink();
    
    final hiddenTabs = _getHiddenTabs();
    
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          if (hiddenTabs.isNotEmpty) ...[
            const SizedBox(height: 8),
            // 剩余tabs的流式布局
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...hiddenTabs.map((tab) => _buildTabChip(tab)),
                // 在末行右侧添加收起按钮
                _buildInlineCollapseButton(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineExpandButton() {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey[500],
          size: 20,
        ),
      ),
    );
  }

  Widget _buildInlineCollapseButton() {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(left: 8),
        child: Icon(
          Icons.keyboard_arrow_up,
          color: Colors.grey[500],
          size: 20,
        ),
      ),
    );
  }

  List<RecordType> _getFirstRowTabs() {
    // 首行显示前4个tabs（为展开按钮留出空间）
    List<RecordType> firstRowTabs = [];
    
    // 首先确保当前选中的tab在首行
    firstRowTabs.add(widget.selectedTab);
    
    // 然后添加其他tabs，首行最多显示4个（为按钮留空间）
    for (RecordType tab in widget.allTabs) {
      if (!firstRowTabs.contains(tab) && firstRowTabs.length < 4) {
        firstRowTabs.add(tab);
      }
    }
    
    return firstRowTabs;
  }

  List<RecordType> _getHiddenTabs() {
    final firstRowTabs = _getFirstRowTabs();
    return widget.allTabs.where((tab) => !firstRowTabs.contains(tab)).toList();
  }

  Widget _buildTabChip(RecordType recordType) {
    final isSelected = widget.selectedTab == recordType;
    
    return GestureDetector(
      onTap: () => widget.onTabSelected(recordType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          recordType.displayName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}