// import 'package:app_core/pages/upgrade/extensions.dart';
// import 'package:app_core/pages/upgrade/upgrade_screen.controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

// import '../../purchases/purchases.services.dart';
// import '../../globals.dart';
// import '../../supabase/model/gumroad_product.model.dart';

// class IAPProductTile extends StatelessWidget {
//   final Package package;
//   const IAPProductTile({super.key, required this.package});

//   @override
//   Widget build(BuildContext context) {
//     final product = package.storeProduct;

//     final currencySymbol = product.priceString.substring(0, 1);
//     String savedText = '';

//     if (product.isAnnually) {
//       final monthly = PurchasesService.to.packages
//           .where((e) => e.identifier.contains('month'));
//       if (monthly.isNotEmpty) {
//         final price =
//             ((monthly.first.storeProduct.price * 12) - product.price).round();
//         savedText =
//             ' - Save $currencySymbol${currencyFormatter.format(price)} vs ${'monthly'.tr.toLowerCase()}';
//       }
//     } else if (product.isMonthly) {
//       final weekly = PurchasesService.to.packages
//           .where((e) => e.identifier.contains('week'));
//       if (weekly.isNotEmpty) {
//         final price =
//             ((weekly.first.storeProduct.price * 4) - product.price).round();
//         savedText =
//             ' - Save $currencySymbol${currencyFormatter.format(price)} vs ${'weekly'.tr.toLowerCase()}';
//       }
//     }

//     const subTitleStyle = TextStyle(
//       fontSize: 12,
//       fontWeight: FontWeight.w500,
//       color: Colors.grey,
//     );

//     const titleStyle = TextStyle(
//       fontWeight: FontWeight.w500,
//       fontSize: 16,
//     );

//     final title = Row(
//       children: [
//         Text(
//           product.itemTitle,
//           style: titleStyle,
//         ),
//         Text(
//           product.itemTitleNext,
//           style: titleStyle.copyWith(
//             color: Get.theme.colorScheme.tertiary,
//           ),
//         ),
//       ],
//     );

//     final subTitle = Row(
//       children: [
//         Text(
//           product.itemSubTitle,
//           style: subTitleStyle,
//         ),
//         Text(
//           savedText,
//           style: subTitleStyle.copyWith(
//             color: Get.theme.primaryColor,
//           ),
//         ),
//       ],
//     );

//     final content = Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 15,
//         vertical: 10,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               title,
//               const SizedBox(height: 5),
//               subTitle,
//             ],
//           ),
//           Obx(
//             () => Visibility(
//               visible:
//                   UpgradeScreenController.to.packageId == package.identifier,
//               replacement: const Icon(
//                 Icons.circle_outlined,
//                 color: Colors.grey,
//               ),
//               child: Icon(
//                 Icons.check_circle,
//                 color: Get.theme.primaryColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );

//     return InkWell(
//       onTap: () => UpgradeScreenController.to.package.value = package,
//       child: Obx(
//         () => Card(
//           elevation: Get.isDarkMode ? 10 : 1,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//             side: UpgradeScreenController.to.packageId == package.identifier
//                 ? BorderSide(color: Get.theme.primaryColor, width: 2)
//                 : const BorderSide(color: Colors.grey, width: 0.2),
//           ),
//           child: content,
//         ),
//       ),
//     );
//   }
// }

// class IAPProductTileWeb extends StatelessWidget {
//   final Product product;
//   const IAPProductTileWeb({super.key, required this.product});

//   @override
//   Widget build(BuildContext context) {
//     const subTitleStyle = TextStyle(
//       fontSize: 12,
//       fontWeight: FontWeight.w500,
//       color: Colors.grey,
//     );

//     const titleStyle = TextStyle(
//       fontWeight: FontWeight.w500,
//       fontSize: 16,
//     );

//     final title = Row(
//       children: [
//         Text(
//           'For only ${product.formattedPrice}',
//           style: titleStyle,
//         ),
//         Text(
//           ' - 50% OFF Limited Time Sale',
//           style: titleStyle.copyWith(
//             color: Get.theme.colorScheme.tertiary,
//             fontSize: 13,
//           ),
//         ),
//       ],
//     );

//     final subTitle = Row(
//       children: [
//         const Text(
//           'via Gumroad.com',
//           style: subTitleStyle,
//         ),
//         Text(
//           ' - ${'cancel_anytime'.tr}',
//           style: subTitleStyle.copyWith(
//             color: Get.theme.primaryColor,
//           ),
//         ),
//       ],
//     );

//     final content = Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 15,
//         vertical: 10,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               title,
//               const SizedBox(height: 5),
//               subTitle,
//             ],
//           ),
//           Icon(
//             Icons.check_circle,
//             color: Get.theme.primaryColor,
//           ),
//         ],
//       ),
//     );

//     return InkWell(
//       onTap: () {
//         //
//       },
//       child: Card(
//         elevation: 10.0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//           side: BorderSide(color: Get.theme.primaryColor, width: 2),
//         ),
//         child: content,
//       ),
//     );
//   }
// }
