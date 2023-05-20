import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:syndease/models/sn_user.dart';
import 'package:syndease/screens/client/home_screen.dart';
import 'package:syndease/utils/services.dart';

import '../utils/appVars.dart';

class CompleteProfileController extends GetxController {
  var backgroundColor = Colors.transparent;
  var colors = [
    primaryColor,
    primaryColor.withOpacity(0.6),
  ];

  var durations = [
    5000,
    4000,
  ];

  var heightPercentages = [
    0.29,
    0.22,
  ];

  RxBool loading = false.obs;
  SnUser snUser = SnUser();
  TextEditingController fullNameController = TextEditingController();

  verify() async {
    if (fullNameController.text.trim().length < 3) {
      Get.snackbar("Error", "Enter a valid name",
          colorText: Colors.white, backgroundColor: dangerColor);
      return false;
    }
    return true;
  }

  submit() {
    verify().then((value) async {
      if (value) {
        loading.toggle();
        update();
        snUser.fullname = fullNameController.text.trim();
        await saveUserToDb(snUser).then((value) async {
          await SessionManager().set('progress', 'homeScreen');
          saveToSession(snUser);
          Get.snackbar("Success", "User saved",
              colorText: Colors.green, backgroundColor: successColor);
          Get.to(() => const HomeScreen(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 500));
          loading.toggle();
          update();
        });
      }
    });
  }

  @override
  void onInit() {
    getUserFromSession().then((value) {
      snUser = value;
      print(snUser);
    });
    // TODO: implement onInit
    super.onInit();
  }
}
