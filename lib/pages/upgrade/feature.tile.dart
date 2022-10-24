import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeatureTile extends StatelessWidget {
  final IconData iconData;
  final String title;

  const FeatureTile({
    Key? key,
    required this.iconData,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: Get.theme.primaryColor),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
    );
  }
}
