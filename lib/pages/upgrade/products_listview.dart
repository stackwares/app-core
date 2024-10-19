import 'package:app_core/pages/upgrade/upgrade_screen.controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../globals.dart';
import 'empty_packages.dart';
import 'item.tile.dart';

class ProductsListView extends StatelessWidget {
  const ProductsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UpgradeScreenController>();
    final scrollController = ScrollController();

    final listView = Obx(
      () => Visibility(
        visible: controller.data.isNotEmpty,
        replacement: const EmptyPackages(),
        child: ListView.builder(
          controller: scrollController,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          // scrollDirection: Axis.horizontal,
          itemCount: controller.data.length,
          itemBuilder: (context, index) => IAPProductTile(
            package: controller.data[index],
          ).animate().slideY(duration: 600.ms).fade(duration: 600.ms),
        ),
      ),
    );

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: isDesktop,
      child: listView,
    );
  }
}
