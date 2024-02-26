import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RemoteImage extends StatelessWidget {
  final String url;
  final double? width, height;
  final Alignment alignment;
  final Widget? failWidget;

  const RemoteImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.failWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      url,
      cache: true,
      fit: BoxFit.cover,
      width: width ?? height,
      height: height ?? width,
      alignment: alignment,
      enableLoadState: true,
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
