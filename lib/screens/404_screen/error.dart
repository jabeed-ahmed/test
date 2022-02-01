import 'package:flutter/material.dart';
import '/constants/style.dart';
import '/widgets/custom_text.dart';

class PageNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "images/error.png",
            width: 350,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: "Page not found",
                size: 24,
                weight: FontWeight.bold,
                color: dark,
              ),
            ],
          )
        ],
      ),
    );
  }
}
