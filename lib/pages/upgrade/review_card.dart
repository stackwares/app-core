import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:icons_plus/icons_plus.dart';

class ReviewCard extends StatelessWidget {
  final String review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LineAwesome.user_circle, size: 15),
                const SizedBox(width: 5),
                RatingBarIndicator(
                  rating: 5,
                  itemCount: 5,
                  itemSize: 15,
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Text(
                review,
                overflow: TextOverflow.fade,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
