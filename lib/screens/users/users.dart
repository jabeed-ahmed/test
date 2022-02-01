import 'package:flutter/material.dart';
import '/constants/controllers.dart';
import '/constants/style.dart';
import '../../helpers/reponsive.dart';
import '/widgets/custom_text.dart';
import 'package:get/get.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Obx(
            () => Row(
              children: [
                Container(
                    margin: EdgeInsets.only(
                        top: ResponsiveWidget.isSmallScreen(context) ? 56 : 6),
                    child: CustomText(
                      text: menuController.activeItem.value,
                      size: 24,
                      weight: FontWeight.bold,
                      color: dark,
                    )),
              ],
            ),
          ),
          Expanded(
              child: ListView(
            children: [
              // Clientstable(),
            ],
          )),
        ],
      ),
    );
  }
}
