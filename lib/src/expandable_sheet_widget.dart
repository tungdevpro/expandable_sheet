import 'package:flutter/material.dart';

import 'expandable_sheet_controller.dart';

class ExpandableSheet extends StatefulWidget {
  const ExpandableSheet({
    super.key,
    this.minHeight = 100,
    this.maxHeight = 500,
    this.initialHeight = 100,
    this.expandToFullHeight = false,
    this.onSheetHidden,
    this.onSheetMaxHeight,
    required this.contentBuilder,
    this.enableMaxHeight = false,
    this.backgroundColor = Colors.white,
    this.handleColor = const Color(0xFFD9D9D9),
  });

  final double minHeight;
  final double maxHeight;
  final double initialHeight;
  final bool enableMaxHeight;
  final bool expandToFullHeight;
  final VoidCallback? onSheetHidden;
  final VoidCallback? onSheetMaxHeight;
  final Widget Function(ScrollController) contentBuilder;
  final Color backgroundColor;
  final Color handleColor;

  @override
  State<ExpandableSheet> createState() => _ExpandableSheetState();
}

class _ExpandableSheetState extends State<ExpandableSheet> {
  static const double _layoutPadding = 30;
  static const double _snapAwayDistance = 50;
  static const double _cornerRadius = 20;
  static const double _handleWidth = 78;
  static const double _handleHeight = 5;
  static const double _handleMargin = 12;
  static const double _shadowBlurRadius = 20;
  static const double _shadowOffsetY = 6;
  static const double _shadowOpacity = 0.4;
  static const Duration _animationDuration = Duration(milliseconds: 150);

  late final ExpandableSheetController _controller = ExpandableSheetController(
    initialHeight: widget.expandToFullHeight ? widget.maxHeight : widget.initialHeight,
  );
  final ScrollController _scrollController = ScrollController();

  late final ValueNotifier<bool> _contentVisible = ValueNotifier(true);
  late double _maxHeight = widget.maxHeight;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _contentVisible.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final position = _scrollController.position;
    final scrolledPastTop = _scrollController.offset <= -_snapAwayDistance;
    if (_scrollController.offset <= 0 && position.outOfRange && !position.atEdge && scrolledPastTop) {
      _hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (!widget.enableMaxHeight) {
          _maxHeight = constraints.maxHeight - _layoutPadding;
        }
        if (widget.expandToFullHeight) {
          _controller.height = _maxHeight;
          _contentVisible.value = true;
        }
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(context),
              _buildContent(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(_cornerRadius),
          topRight: Radius.circular(_cornerRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _shadowOpacity),
            offset: const Offset(0, _shadowOffsetY),
            blurRadius: _shadowBlurRadius,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: _handleMargin),
        height: _handleHeight,
        width: _handleWidth,
        decoration: BoxDecoration(color: widget.handleColor, borderRadius: BorderRadius.circular(99)),
      ),
    );
  }

  Widget _buildContent() {
    return StreamBuilder<double>(
      stream: _controller.heightStream,
      initialData: _controller.height,
      builder: (_, snapshot) {
        return AnimatedContainer(
          height: snapshot.data,
          decoration: BoxDecoration(color: widget.backgroundColor),
          duration: _animationDuration,
          child: ValueListenableBuilder(
            valueListenable: _contentVisible,
            builder: (context, visible, child) {
              return AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: _animationDuration,
                child: IgnorePointer(
                  ignoring: !visible,
                  child: widget.contentBuilder(_scrollController),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final newHeight = _controller.height - details.delta.dy;

    if (newHeight >= widget.minHeight && newHeight <= _maxHeight) {
      if (!_contentVisible.value && newHeight > widget.minHeight + _snapAwayDistance) {
        _contentVisible.value = true;
      }

      _controller.height = newHeight;
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _snapToNearestExtent();
  }

  void _snapToNearestExtent() {
    final currentHeight = _controller.height;

    final extents = <double>[widget.minHeight, widget.initialHeight, _maxHeight];
    final nearest = extents.reduce(
      (a, b) => (a - currentHeight).abs() < (b - currentHeight).abs() ? a : b,
    );

    if (nearest == widget.minHeight) {
      _hide();
    } else if (nearest == _maxHeight) {
      _show();
      _contentVisible.value = true;
    } else {
      _controller.height = widget.initialHeight;
      _contentVisible.value = true;
      _controller.visible = true;
    }
  }

  void _hide() {
    _controller.height = widget.minHeight;
    _controller.visible = false;
    _contentVisible.value = false;
    widget.onSheetHidden?.call();
  }

  void _show() {
    _controller.height = _maxHeight;
    _controller.visible = true;
    _contentVisible.value = true;
    widget.onSheetMaxHeight?.call();
  }
}
