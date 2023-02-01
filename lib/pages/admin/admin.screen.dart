import 'package:app_core/globals.dart';
import 'package:app_core/supabase/supabase_realtime.service.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:locale_emoji_flutter/locale_emoji_flutter.dart';

import '../../utils/utils.dart';
import 'admin_screen.controller.dart';

class AdminScreen extends StatelessWidget with ConsoleMixin {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminScreenController());

    final content = Obx(
      () => ListView.separated(
        shrinkWrap: true,
        itemCount: RealtimeService.to.data.length,
        separatorBuilder: (context, index) => Divider(
          height: 5,
          color: Colors.grey.withOpacity(0.1),
        ),
        itemBuilder: (context, index) {
          final item = RealtimeService.to.data[index];
          final emojiFlag = Locale(item.locale).flagEmoji ?? '🌍';

          var platformIcon = Icons.circle;
          Color? platformColor;
          final platform_ = item.platform.toLowerCase();

          if (platform_.contains('android')) {
            platformIcon = LineIcons.android;
            platformColor = Colors.lightGreen;
          } else if (platform_.contains('ios')) {
            platformIcon = Icons.phone_iphone;
          } else if (platform_.contains('macos')) {
            platformIcon = LineIcons.apple;
            platformColor = Colors.grey;
          } else if (platform_.contains('web')) {
            platformIcon = LineIcons.chrome;
            platformColor = Colors.yellow;
          } else if (platform_.contains('windows')) {
            platformIcon = LineIcons.windows;
            platformColor = Colors.blue;
          } else if (platform_.contains('linux')) {
            platformIcon = LineIcons.linux;
            platformColor = Colors.brown;
          }

          final plan = item.plan != 'free'
              ? '${item.plan}${item.planTrial ? ' - trial' : ''}'
              : item.plan ?? 'free';

          Color? planColor;

          if (plan.contains('trial')) {
            planColor = Colors.blueGrey;
          } else if (plan.contains('starter')) {
            planColor = Colors.amber.withOpacity(0.5);
          } else if (plan.contains('plus')) {
            planColor = Colors.green;
          } else if (plan.contains('pro')) {
            planColor = Colors.blue;
          } else if (plan.contains('max')) {
            planColor = Colors.purple;
          } else if (plan.contains('business')) {
            planColor = Colors.pink;
          }

          return ListTile(
            title: Row(
              children: [
                Tooltip(
                  message: item.country,
                  child: Text(emojiFlag),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    item.email,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (DateTime.tryParse(item.createdAt) != null) ...[
                  Text(
                    '${Utils.timeAgo(DateTime.parse(item.createdAt))} ago',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ]
              ],
            ),
            onLongPress: () => Utils.copyToClipboard(item.id),
            // leading: Tooltip(
            //   message: item.locale,
            //   child: Text(emojiFlag, style: const TextStyle(fontSize: 25)),
            // ),
            // trailing: Column(
            //   children: [
            //     Icon(platformIcon, color: platformColor),
            //     const SizedBox(height: 2),
            //     Text(
            //       item.platform,
            //       style: const TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //   ],
            // ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Wrap(
                spacing: 5,
                runSpacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SmallChip(
                    text: plan.toUpperCase(),
                    color: planColor,
                  ),
                  if (item.license != null) ...[
                    SmallChip(
                      text:
                          '${kFormatter.format(item.license!.usedTokens)} / ${kFormatter.format(item.license!.maxTokens)}',
                    ),
                  ],
                  SmallChip(text: item.platform),
                  SmallChip(text: item.deviceType),
                  SmallChip(text: item.version),
                  SmallChip(text: item.theme),
                  SmallChip(text: item.locale),
                ],
              ),
            ),
          );
        },
      ),
    );

    final appBar = AppBar(
      title: Obx(() => Text('Online: ${RealtimeService.to.data.length}')),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        IconButton(
          onPressed: controller.reload,
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 10),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}

class SmallChip extends StatelessWidget {
  final String text;
  final Color? color;
  final TextStyle? textStyle;

  const SmallChip({
    super.key,
    this.color,
    required this.text,
    this.textStyle = const TextStyle(fontSize: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: color,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        child: Text(text, style: textStyle),
      ),
    );
  }
}
