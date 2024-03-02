import 'package:console_mixin/console_mixin.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_network/image_network.dart';

class RemoteImage extends StatelessWidget with ConsoleMixin {
  final String url;
  final double? width, height;
  final Alignment alignment;
  final Widget? failWidget;
  final Widget? loadingWidget;
  final String? cacheKey;
  final bool retry;

  const RemoteImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.loadingWidget,
    this.failWidget,
    this.cacheKey,
    this.retry = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return failWidget ?? SizedBox.shrink();
    }

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
          if (loadingWidget != null) return loadingWidget;
        } else if (state.extendedImageLoadState == LoadState.completed) {
          return state.completedWidget.animate().fade();
        } else if (state.extendedImageLoadState == LoadState.failed) {
          // If blocked by CORS, try to use Proxy
          if (retry && kIsWeb) {
            // Unblock CORS
            // var fixedUrl = url;
            // fixedUrl =
            //     'https://api.codetabs.com/v1/proxy?quest=${Uri.encodeComponent(url)}';

            // return RemoteImage(
            //   url: fixedUrl,
            //   retry: false,
            //   width: width,
            //   height: height,
            //   alignment: alignment,
            //   failWidget: failWidget,
            //   loadingWidget: loadingWidget,
            //   cacheKey: cacheKey,
            // );

            console.wtf('rendering html image');

            // HTML RENDERED IMAGE
            return ImageNetwork(
              image: url,
              fitWeb: BoxFitWeb.cover,
              height: h,
              width: w,
            );
          }

          if (failWidget != null) return failWidget;
        }

        return SizedBox.shrink();
      },
    );
  }
}
