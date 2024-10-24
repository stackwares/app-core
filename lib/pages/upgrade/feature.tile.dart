import 'package:app_core/globals.dart';
import 'package:flutter/material.dart';

class FeatureTile extends StatelessWidget {
  final String title;
  final bool highlighted;
  final double fontSize;

  const FeatureTile({
    Key? key,
    required this.title,
    this.highlighted = false,
    this.fontSize = 18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: isSmallScreen ? 3 : 6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: darkThemeData.primaryColor),
          const SizedBox(width: 15),
          Flexible(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                // fontWeight: FontWeight.w500,
                color: highlighted ? darkThemeData.colorScheme.tertiary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
