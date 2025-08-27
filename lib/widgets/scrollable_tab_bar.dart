import 'package:flutter/material.dart';
import '../models/records/record_type.dart';

/// A horizontally scrollable TabBar that renders tabs in fixed order.
/// - Does not reorder or collapse tabs
/// - Highlights only the selected tab
/// - Ensures the selected tab is scrolled into view (without moving it to the front)
class ScrollableTabBar extends StatefulWidget {
  final RecordType selectedTab;
  final Function(RecordType) onTabSelected;
  final List<RecordType> allTabs;

  const ScrollableTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    required this.allTabs,
  });

  @override
  State<ScrollableTabBar> createState() => _ScrollableTabBarState();
}

class _ScrollableTabBarState extends State<ScrollableTabBar>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<RecordType, GlobalKey> _tabKeys = {};
  late final AnimationController _indicatorCtrl;
  int _fromIndex = 0;
  int _toIndex = 0;

  @override
  void initState() {
    super.initState();
    _syncKeys();
    // Ensure initial selected tab is visible after first frame
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _ensureSelectedVisible(),
    );
    _scrollController.addListener(_onScrollChanged);

    _indicatorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _indicatorCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    final initialIndex = widget.allTabs.indexOf(widget.selectedTab);
    _fromIndex = initialIndex >= 0 ? initialIndex : 0;
    _toIndex = _fromIndex;
  }

  @override
  void didUpdateWidget(covariant ScrollableTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_listEquals(oldWidget.allTabs, widget.allTabs)) {
      _syncKeys();
      // 当 tabs 列表变化时，直接同步索引，避免跨列表动画跳跃
      final idx = widget.allTabs.indexOf(widget.selectedTab);
      _fromIndex = idx >= 0 ? idx : 0;
      _toIndex = _fromIndex;
    }
    if (oldWidget.selectedTab != widget.selectedTab) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _ensureSelectedVisible(),
      );
      final newIndex = widget.allTabs.indexOf(widget.selectedTab);
      if (newIndex >= 0) {
        _fromIndex = _toIndex;
        _toIndex = newIndex;
        _indicatorCtrl.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    _indicatorCtrl.dispose();
    super.dispose();
  }

  void _onScrollChanged() {
    if (!mounted) return;
    setState(() {
      // trigger rebuild for indicator position
    });
  }

  void _syncKeys() {
    // Add keys for any new tabs
    for (final t in widget.allTabs) {
      _tabKeys.putIfAbsent(t, () => GlobalKey());
    }
    // Remove keys for tabs that no longer exist
    final toRemove = _tabKeys.keys
        .where((k) => !widget.allTabs.contains(k))
        .toList();
    for (final k in toRemove) {
      _tabKeys.remove(k);
    }
  }

  bool _listEquals(List<RecordType> a, List<RecordType> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _ensureSelectedVisible() async {
    final key = _tabKeys[widget.selectedTab];
    final ctx = key?.currentContext;
    if (ctx == null) return;
    try {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: 0.5, // try to center the selected tab when possible
      );
    } catch (_) {
      // ignore scrolling errors
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allTabs.isEmpty) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: widget.allTabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tab = widget.allTabs[index];
                return KeyedSubtree(
                  key: _tabKeys[tab],
                  child: _buildTabChip(context, tab),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildDiscreteIndicators(context),
        ],
      ),
    );
  }

  Widget _buildDiscreteIndicators(BuildContext context) {
    final n = widget.allTabs.length;
    if (n <= 0) return const SizedBox(height: 6);

    const height = 6.0;
    const radius = 3.0;
    const spacing = 6.0;
    final primary = Theme.of(context).primaryColor;
    final baseColor = Colors.grey[300]!;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;

          // 优先用实际 tab 芯片的宽度来对齐指示器；若测量失败，退回均分策略
          List<double>? segWidths;
          List<double>? segLefts;
          double totalContentWidth = 0;
          bool canMeasure = true;
          for (int i = 0; i < n; i++) {
            final key = _tabKeys[widget.allTabs[i]];
            final ctx = key?.currentContext;
            if (ctx == null) {
              canMeasure = false;
              break;
            }
            final box = ctx.findRenderObject();
            if (box is! RenderBox) {
              canMeasure = false;
              break;
            }
            final size = box.hasSize ? box.size : null;
            if (size == null) {
              canMeasure = false;
              break;
            }
            segWidths ??= [];
            segLefts ??= [];
            final w = size.width;
            segWidths.add(w);
          }
          if (canMeasure && segWidths != null) {
            // 计算每段起点（基于内容宽度比例映射到 trackWidth）
            totalContentWidth =
                segWidths.fold<double>(0, (p, e) => p + e) +
                (n - 1) * 8.0; // 8 对应 chip 间隔
            double acc = 0;
            segLefts = [];
            for (int i = 0; i < n; i++) {
              segLefts.add((acc / totalContentWidth) * trackWidth);
              acc += segWidths[i] + (i == n - 1 ? 0 : 8.0);
            }
          }

          // 如果无法测量，使用均分到整行的方案，确保“占满整行”
          final useEqual = !canMeasure || segWidths == null || segLefts == null;
          final spacingEqual = spacing;
          final segWidthEqual = useEqual
              ? ((trackWidth - (n - 1) * spacingEqual) / n).clamp(
                  8.0,
                  trackWidth,
                )
              : null;

          // 基础指示器行（灰色）
          final children = <Widget>[];
          for (int i = 0; i < n; i++) {
            final w = useEqual
                ? segWidthEqual!
                : (trackWidth / totalContentWidth) * segWidths[i];
            children.add(
              Container(
                width: w,
                height: height,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
            );
            if (i != n - 1)
              children.add(
                SizedBox(
                  width: useEqual
                      ? spacingEqual
                      : (trackWidth / totalContentWidth) * 8.0,
                ),
              );
          }

          // 计算动画中高亮拇指的位置与宽度
          double t;
          if (_indicatorCtrl.isAnimating) {
            t = _indicatorCtrl.value;
          } else {
            // 非动画期间，确保直接落在目标 index，避免“卡在倒数第二个/第一个”的错觉
            t = 1.0;
          }
          final from = _fromIndex.clamp(0, n - 1);
          final to = _toIndex.clamp(0, n - 1);
          final dir = (to - from).sign; // -1, 0, 1

          double baseFromLeft;
          double baseToLeft;
          double baseFromWidth;
          double baseToWidth;
          if (useEqual) {
            baseFromLeft = from * (segWidthEqual! + spacingEqual);
            baseToLeft = to * (segWidthEqual + spacingEqual);
            baseFromWidth = segWidthEqual;
            baseToWidth = segWidthEqual;
          } else {
            baseFromLeft = segLefts[from];
            baseToLeft = segLefts[to];
            baseFromWidth = (trackWidth / totalContentWidth) * segWidths[from];
            baseToWidth = (trackWidth / totalContentWidth) * segWidths[to];
          }

          final left = baseFromLeft + (baseToLeft - baseFromLeft) * t;
          final segWidthNow = baseFromWidth + (baseToWidth - baseFromWidth) * t;

          // 黏性宽度：中段变宽，两端正常
          final midBump = 1 - (2 * t - 1).abs(); // 0→1→0
          final extra = (segWidthNow * 0.45) * midBump; // 稍微降低峰值，减少“过头感”
          final width = segWidthNow + extra;
          final directionalOffset = extra * 0.12 * dir;

          return Stack(
            children: [
              Row(children: children),
              // 高亮拇指覆盖到目标 segment，带动画
              Positioned(
                left: left + directionalOffset,
                top: 0,
                height: height,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  width: width,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.22),
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabChip(BuildContext context, RecordType recordType) {
    final isSelected = widget.selectedTab == recordType;

    return GestureDetector(
      onTap: () => widget.onTabSelected(recordType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
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
