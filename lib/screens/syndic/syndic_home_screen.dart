import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:syndease/utils/widgets.dart';

import '../../controllers/syndic/syndic_home_controller.dart';

class SyndicHomeScreen extends StatelessWidget {
  const SyndicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: GetBuilder<SyndicHomeController>(
                init: SyndicHomeController(),
                builder: (controller) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('hello syndic ${controller.snUser.fullname}'),
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
