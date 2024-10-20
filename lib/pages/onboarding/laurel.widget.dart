import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../../widgets/laurel.widget.dart';

class LaurelWidget extends StatelessWidget {
  const LaurelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.flip(flipX: true, child: LaurelImage()),
        const SizedBox(width: 10),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 250),
          child: Column(
            children: [
              Text(
                'join_over_users'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              RatingBarIndicator(
                rating: 5,
                itemCount: 5,
                itemSize: 30,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        LaurelImage(),
      ],
    );
  }
}
