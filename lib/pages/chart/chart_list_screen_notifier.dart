import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/provider/current_parent_category_id.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:firebase_sample/pages/home/add_new_category_screen.dart';
import 'package:firebase_sample/pages/home/edit_group_name_screen.dart';
import 'package:firebase_sample/pages/home/zoom_tweet_image_screen.dart';
import 'package:firebase_sample/pages/settings/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_player/video_player.dart';

class ChartListScreenNotifier extends ChangeNotifier {
  ChartListScreenNotifier({
    this.context,
    this.parentCategoryIdNotifier,
  }) {
    textController.text = '';
    videoController = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    );
    initializeVideoPlayerFuture = videoController.initialize();

    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    screenSize = ScreenSize(
        size: MediaQuery.of(context).size,
        pixelRatio: MediaQuery.of(context).devicePixelRatio);
    sizeType = screenSize.specifyScreenSizeType();
  }

  final BuildContext context;
  final CurrentParentCategoryIdProvider parentCategoryIdNotifier;
  final nameFieldFormKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  ScreenSize screenSize;
  ScreenSizeType sizeType;
  bool isValid = false;

  DateTime _selectedRemindDate;
  bool get isDateValid => _selectedRemindDate != null;

  SlidableController slidableController;
  VideoPlayerController videoController;
  Future<void> initializeVideoPlayerFuture;
  String currentTabDocumentId = '';
  int currentTabIndex = 0;
  int initPosition = 0;
  bool isInitialLoadCompleted = false;
  List<QueryDocumentSnapshot> todoList = [];

  Animation<double> rotationAnimation;
  Color fabColor = Colors.blue;

  @override
  void dispose() {
    textController.dispose();
    videoController.dispose();
    super.dispose();
  }

  double calculateCompletePercent(
    List<QueryDocumentSnapshot> todoList,
  ) {
    final completedPercent = todoList
            .where((element) => element['isChecked'] == true)
            .toList()
            .length /
        todoList.length *
        100;
    return completedPercent;
  }

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    notifyListeners();
    refreshController.refreshCompleted();
  }

  void onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    notifyListeners();
    refreshController.loadComplete();
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    rotationAnimation = slideAnimation;
    notifyListeners();
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    fabColor = isOpen ? Colors.green : Colors.blue;
    notifyListeners();
  }

  void navigateSettingScreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => SettingsScreen(),
      ),
    );
  }

  void navigateAddCategoryScreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => AddCategoryScreen(),
      ),
    );
  }

  void navigateEditGroupNameScreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => EditGroupNameScreen(),
      ),
    );
  }

  void navigateZoomImageScreen(
    String imagePath,
    String heroTag,
  ) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => ZoomImageScreen(
          imagePath: imagePath,
          heroTagName: heroTag,
        ),
      ),
    );
  }

  double setFormHeightByDevice(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (sizeType == ScreenSizeType.xlarge) {
      return size.width * .4;
    } else if (sizeType == ScreenSizeType.xxlarge) {
      return size.width * .4;
    } else {
      return size.width * .3;
    }
  }

  static Widget getActionPane(int index) {
    switch (index % 4) {
      case 0:
        return SlidableBehindActionPane();
      case 1:
        return SlidableStrechActionPane();
      case 2:
        return SlidableScrollActionPane();
      case 3:
        return SlidableDrawerActionPane();
      default:
        return null;
    }
  }

  static Color getAvatarColor(int index) {
    switch (index % 4) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.indigoAccent;
      default:
        return null;
    }
  }

  static String getSubtitle(int index) {
    switch (index % 4) {
      case 0:
        return 'SlidableBehindActionPane';
      case 1:
        return 'SlidableStrechActionPane';
      case 2:
        return 'SlidableScrollActionPane';
      case 3:
        return 'SlidableDrawerActionPane';
      default:
        return null;
    }
  }

  void showSnackBar(
    BuildContext context,
    String text,
  ) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}
