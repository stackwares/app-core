import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RemoteImage extends StatelessWidget {
  final String url;
  final double? width, height;
  final Alignment alignment;
  final Widget? failWidget;
  final String? cacheKey;

  const RemoteImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.failWidget,
    this.cacheKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = width ?? height ?? 10;
    final h = height ?? width ?? 10;

    return ExtendedImage.network(
      url,
      cache: true,
      fit: BoxFit.cover,
      width: w,
      height: h,
      alignment: alignment,
      enableLoadState: true,
      cacheKey: cacheKey,
      loadStateChanged: (state) {
        if (state.extendedImageLoadState == LoadState.loading) {
          // return null;
        } else if (state.extendedImageLoadState == LoadState.completed) {
          return state.completedWidget.animate().fade();
        } else if (state.extendedImageLoadState == LoadState.failed) {
          if (failWidget != null) return failWidget;
        }

        return SizedBox.shrink();
      },
    );
  }
}
