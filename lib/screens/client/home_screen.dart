import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:syndease/controllers/client/home_controller.dart';
import 'package:syndease/utils/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: GetBuilder<HomeController>(
                init: HomeController(),
                builder: (controller) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('hello  ${controller.snUser.fullname}'),
                      PrimaryButton(
                          text: 'logout',
                          onpress: () {
                            controller.logout();
                          }),
                    ],
                  );
                })));
  }
}
