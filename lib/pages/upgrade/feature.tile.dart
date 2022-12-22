import 'package:app_core/animations/animations.dart';
import 'package:app_core/globals.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeatureTile extends StatelessWidget {
  final String title;
  final bool highlighted;
  final double fontSize;

  const FeatureTile({
    Key? key,
    required this.title,
    this.highlighted = false,
    this.fontSize = 17,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListItemAnimation(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: isSmallScreen ? 5 : 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, color: Get.theme.primaryColor),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: highlighted ? Get.theme.colorScheme.tertiary : null,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
