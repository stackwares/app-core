import 'package:app_core/globals.dart';
import 'package:flutter/material.dart';

class CustomPopupButton extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final String tooltip;
  final List<CustomPopupData> items;

  const CustomPopupButton({
    Key? key,
    required this.child,
    required this.items,
    this.enabled = true,
    this.tooltip = 'Show menu',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CustomPopupData>(
      icon: child,
      enabled: enabled,
      tooltip: tooltip,
      onSelected: (e) => e.onTap.call(),
      itemBuilder: (BuildContext context) {
        return items
            .map(
              (e) => PopupMenuItem(
                value: e,
                height: popupItemHeight,
                child: CustomPopupButtonChild(data: e),
              ),
            )
            .toList();
      },
    );
  }
}

class CustomPopupData {
  final String text;
  final IconData? iconData;
  final Widget? trailing;
  final Widget? child;
  final Function() onTap;

  const CustomPopupData({
    Key? key,
    required this.text,
    this.iconData,
    this.trailing,
    this.child,
    required this.onTap,
  });
}

class CustomPopupButtonChild extends StatelessWidget {
  final CustomPopupData data;
  const CustomPopupButtonChild({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data.iconData != null) ...[
                Icon(data.iconData, size: popupIconSize),
              ],
              const SizedBox(width: 10),
              Text(data.text),
            ],
          ),
        ),
        if (data.trailing != null) ...[data.trailing!]
      ],
    );
  }
}
