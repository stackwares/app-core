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
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(e.iconData, size: popupIconSize),
                          const SizedBox(width: 10),
                          Text(e.text),
                        ],
                      ),
                    ),
                    if (e.trailing != null) ...[e.trailing!]
                  ],
                ),
              ),
            )
            .toList();
      },
    );
  }
}

class CustomPopupData {
  final String text;
  final IconData iconData;
  final Widget? trailing;
  final Function() onTap;

  const CustomPopupData({
    Key? key,
    required this.text,
    required this.iconData,
    this.trailing,
    required this.onTap,
  });
}
