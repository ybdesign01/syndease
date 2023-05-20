import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:syndease/models/sn_user.dart';
import 'package:syndease/screens/complete_profile.dart';
import 'package:syndease/utils/appVars.dart';
import 'package:syndease/utils/services.dart';

import '../screens/client/home_screen.dart';
import '../screens/syndic/syndic_home_screen.dart';

class VerifyController extends GetxController {
  TextEditingController pinController = TextEditingController();
  var backgroundColor = Colors.transparent;
  String verificationCode = "";
  String phoneNumber = "";
  RxBool loading = false.obs;
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

  validate() async {
    if (pinController.text.trim().length < 6) {
      Get.snackbar("Error", "Enter a valid code",
          colorText: Colors.white, backgroundColor: dangerColor);
      return false;
    } else {
      return true;
    }
  }

  submit() {
    validate().then((value) async {
      loading.toggle();
      update();
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationCode,
            smsCode: pinController.text.trim());
        UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = authResult.user;
        print(user);
        checkPhoneNumber(user!.uid).then((value) async {
          if (value == "found-in-users") {
            await getUserFromDb(user.uid).then((value) async {
              print('value.type ${value.toJson()}');
              await saveToSession(value);
              if (value.type == 0) {
                await SessionManager().set('progress', 'homeScreen');
                Get.offAll(() => const HomeScreen(),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 500));
              } else {
                Get.offAll(() => const SyndicHomeScreen(),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 500));
              }
            });
          } else {
            Get.snackbar('not found', "not found");
            SnUser snUser = SnUser(
                uid: user.uid,
                phoneNumber: user.phoneNumber,
                fullname: "",
                type: 0);
            await saveUserToDb(snUser).then((value) async {
              await saveToSession(snUser);
              await SessionManager().set('progress', 'completeProfile');

              Get.offAll(() => const CompleteProfile(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 500));
            });
          }
        });
        loading.toggle();
        update();
      } catch (e) {
        loading.toggle();
        update();
        Get.snackbar("Error", "Invalid code",
            colorText: Colors.white, backgroundColor: dangerColor);
      }
    });
  }

  @override
  Future<void> onInit() async {
    phoneNumber = await SessionManager().get('phone');
  //  verificationCode = Get.arguments;
    // TODO: implement onInit
    super.onInit();
  }
}
