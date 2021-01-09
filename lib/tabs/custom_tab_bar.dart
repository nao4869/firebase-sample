import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomTabView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder tabBuilder;
  final IndexedWidgetBuilder pageBuilder;
  final Widget stub;
  final ValueChanged<int> onPositionChange;
  final ValueChanged<double> onScroll;
  final int initPosition;

  CustomTabView({
    @required this.itemCount,
    @required this.tabBuilder,
    @required this.pageBuilder,
    this.stub,
    this.onPositionChange,
    this.onScroll,
    this.initPosition,
  });

  @override
  _CustomTabsState createState() => _CustomTabsState();
}

class _CustomTabsState extends State<CustomTabView>
    with TickerProviderStateMixin {
  TabController controller;
  int _currentCount;
  int _currentPosition;

  @override
  void initState() {
    _currentPosition = widget.initPosition ?? 0;
    controller = TabController(
      length: widget.itemCount,
      vsync: this,
      initialIndex: _currentPosition,
    );
    controller.addListener(onPositionChange);
    controller.animation.addListener(onScroll);
    _currentCount = widget.itemCount;
    super.initState();
  }

  @override
  void didUpdateWidget(CustomTabView oldWidget) {
    if (_currentCount != widget.itemCount) {
      controller.animation.removeListener(onScroll);
      controller.removeListener(onPositionChange);
      controller.dispose();

      if (widget.initPosition != null) {
        _currentPosition = widget.initPosition;
      }

      if (_currentPosition > widget.itemCount - 1) {
        _currentPosition = widget.itemCount - 1;
        _currentPosition = _currentPosition < 0 ? 0 : _currentPosition;
        if (widget.onPositionChange is ValueChanged<int>) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              widget.onPositionChange(_currentPosition);
            }
          });
        }
      }

      _currentCount = widget.itemCount;
      setState(() {
        controller = TabController(
          length: widget.itemCount,
          vsync: this,
          initialIndex: _currentPosition,
        );
        controller.addListener(onPositionChange);
        controller.animation.addListener(onScroll);
      });
    } else if (widget.initPosition != null) {
      controller.animateTo(widget.initPosition);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.animation.removeListener(onScroll);
    controller.removeListener(onPositionChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider =
        Provider.of<SwitchAppThemeProvider>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    if (widget.itemCount < 1) return widget.stub ?? Container();
    return ColoredBox(
      color: theme.isLightTheme ? white : darkBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 10),
          Container(
            alignment: Alignment.center,
            child: TabBar(
              isScrollable: true,
              controller: controller,
              labelPadding: EdgeInsets.all(0.5),
              labelColor: white, // 内部の文字色
              labelStyle: TextStyle(
                color: white,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
              unselectedLabelColor: white,
              // indicator: ShapeDecoration(
              //   color: themeProvider.currentTheme,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.only(
              //       topRight: Radius.circular(10),
              //       topLeft: Radius.circular(10),
              //     ),
              //   ),
              // ),
              indicatorColor: themeProvider.currentTheme,
              tabs: List.generate(
                widget.itemCount,
                (index) => widget.tabBuilder(
                  context,
                  index,
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: controller,
              children: List.generate(
                widget.itemCount,
                (index) => widget.pageBuilder(
                  context,
                  index,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  onPositionChange() {
    if (!controller.indexIsChanging) {
      _currentPosition = controller.index;
      if (widget.onPositionChange is ValueChanged<int>) {
        widget.onPositionChange(_currentPosition);
      }
    }
  }

  onScroll() {
    if (widget.onScroll is ValueChanged<double>) {
      widget.onScroll(controller.animation.value);
    }
  }
}
