import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class RemoteImage extends StatelessWidget {
  final String url;
  final double? width, height;
  final Alignment alignment;
  final Image? placeholder;

  const RemoteImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      url,
      width: width ?? height,
      height: height ?? width,
      alignment: alignment,
      cache: true,
      fit: BoxFit.cover,
    );
  }
}
