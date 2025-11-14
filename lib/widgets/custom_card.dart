import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String description;
  final String animation;

  const CustomCard({super.key, required this.title, required this.description, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Lottie.asset(animation, width: 60, height: 60),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text(description),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
