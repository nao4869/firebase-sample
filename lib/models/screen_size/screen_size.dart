import 'package:flutter/material.dart';

enum ScreenSizeType {
  small,
  medium,
  large,
  xlarge,
  xxlarge,
}

class ScreenSize {
  ScreenSize({
    this.size,
    this.pixelRatio,
  });

  final Size size;
  final double pixelRatio;

  ScreenSizeType specifyScreenSizeType() {
    // 数値が小さいほど縦長となる。
    final deviceRatio = size.width / size.height;
    if (deviceRatio < .50) {
      return ScreenSizeType.xxlarge;
    }
    if (deviceRatio < .55) {
      return ScreenSizeType.xlarge;
    }
    if (deviceRatio < .60) {
      return ScreenSizeType.large;
    }
    if (deviceRatio < .64) {
      return ScreenSizeType.medium;
    }
    return ScreenSizeType.small;
  }

  SizeParameter parameter() {
    final screenSize = specifyScreenSizeType();
    switch (screenSize) {
      case ScreenSizeType.small:
        return SizeParameter.small();
      case ScreenSizeType.medium:
        return SizeParameter.medium();
      case ScreenSizeType.large:
        return SizeParameter.large();
      case ScreenSizeType.xlarge:
        return SizeParameter.xlarge();
      case ScreenSizeType.xxlarge:
        return SizeParameter.xxlarge();
    }
    assert(false, 'Missing case');
    return SizeParameter.medium();
  }

  Size manipulateCardSize() {
    final screenSize = specifyScreenSizeType();

    switch (screenSize) {
      case ScreenSizeType.small:
        final height = size.height * .65;
        return Size(height * .75, height);
      case ScreenSizeType.medium:
        final height = size.height * .65;
        return Size(height * .75, height);
      case ScreenSizeType.large:
        final height = size.height * .65;
        return Size(height * .75, height);
      case ScreenSizeType.xlarge:
        final height = size.height * .65;
        return Size(height * .75, height);
      case ScreenSizeType.xxlarge:
        final height = size.height * .55;
        return Size(height * .75, height);
    }
    final height = size.height * .65;
    return Size(height * .75, height);
  }

  Size manipulateFilterCardSize() {
    final screenSize = specifyScreenSizeType();

    switch (screenSize) {
      case ScreenSizeType.small:
        final height = size.height * .48;
        return Size(height * .75, height);
      case ScreenSizeType.medium:
        final height = size.height * .48;
        return Size(height * .75, height);
      case ScreenSizeType.large:
        final height = size.height * .48;
        return Size(height * .75, height);
      case ScreenSizeType.xlarge:
        final height = size.height * .48;
        return Size(height * .75, height);
      case ScreenSizeType.xxlarge:
        final height = size.height * .48;
        return Size(height * .75, height);
    }
    final height = size.height * .48;
    return Size(height * .75, height);
  }
}

class SizeParameter {
  SizeParameter({
    this.heightFactor,
    this.opacity,
    this.slideAlign,
    this.rewindCardAlign,
    this.swipeAlign,
    this.swipeAlignVertical,
    this.rotateAngle,
    this.rewindRotateAngle,
    this.mainAnimationDuration,
    this.rewindAnimationDuration,
    this.dragThreshold,
  });

  final double heightFactor;

  /// リワインド用のカードの初期位置
  /// （カードサイズを変更後、リワインドのカードが見えてします場合はこちらを変更してください）
  final double rewindCardAlign;

  /// Opacityのかかり具合を調整するパラメーター
  final double opacity;

  /// スライドアニメーション時の移動量を調整するパラメーター
  final double slideAlign;

  /// スワイプ時の移動量を調整するパラメーター
  final double swipeAlign;
  final double swipeAlignVertical;

  /// 角度を調整するパラメーター
  final double rotateAngle;
  final double rewindRotateAngle;

  /// アニメーションの時間を設定するパラメーター
  final Duration mainAnimationDuration;
  final Duration rewindAnimationDuration;

  /// ドラッグ時の閾値のパラメーター
  final double dragThreshold;

  /// iPhone xs (max)
  factory SizeParameter.xxlarge() {
    return SizeParameter(
      heightFactor: .55,
      opacity: 0.13,
      slideAlign: 20.0,
      rewindCardAlign: -20.0,
      swipeAlign: 15.0,
      swipeAlignVertical: 10.0,
      rotateAngle: 0.017,
      rewindRotateAngle: -0.5,
      mainAnimationDuration: const Duration(milliseconds: 500),
      rewindAnimationDuration: const Duration(milliseconds: 600),
      dragThreshold: 3,
    );
  }

  /// pixel3XL
  factory SizeParameter.xlarge() {
    return SizeParameter(
      heightFactor: .65,
      opacity: 0.13,
      slideAlign: 40.0,
      rewindCardAlign: -30.0,
      swipeAlign: 15.0,
      swipeAlignVertical: 30.0,
      rotateAngle: 0.017,
      rewindRotateAngle: -0.5,
      mainAnimationDuration: const Duration(milliseconds: 500),
      rewindAnimationDuration: const Duration(milliseconds: 600),
      dragThreshold: 4.0,
    );
  }

  /// 1440x2560
  factory SizeParameter.large() {
    return SizeParameter(
      heightFactor: .65,
      opacity: 0.13,
      slideAlign: 20.0,
      rewindCardAlign: -20.0,
      swipeAlign: 10.0,
      swipeAlignVertical: 30.0,
      rotateAngle: 0.017,
      rewindRotateAngle: -0.5,
      mainAnimationDuration: const Duration(milliseconds: 500),
      rewindAnimationDuration: const Duration(milliseconds: 600),
      dragThreshold: 3.0,
    );
  }

  /// 1080x1920
  factory SizeParameter.medium() {
    return SizeParameter(
      heightFactor: .65,
      opacity: 0.18,
      slideAlign: 15.0,
      rewindCardAlign: -15.0,
      swipeAlign: 10.0,
      swipeAlignVertical: 30.0,
      rotateAngle: 0.017,
      rewindRotateAngle: -0.5,
      mainAnimationDuration: const Duration(milliseconds: 500),
      rewindAnimationDuration: const Duration(milliseconds: 600),
      dragThreshold: 2.5,
    );
  }

  /// 768x1280
  factory SizeParameter.small() {
    return SizeParameter(
      heightFactor: .65,
      opacity: 0.2,
      slideAlign: 10.0,
      rewindCardAlign: -10.0,
      swipeAlign: 8.0,
      swipeAlignVertical: 30.0,
      rotateAngle: 0.017,
      rewindRotateAngle: -0.5,
      mainAnimationDuration: const Duration(milliseconds: 500),
      rewindAnimationDuration: const Duration(milliseconds: 600),
      dragThreshold: 2.0,
    );
  }
}