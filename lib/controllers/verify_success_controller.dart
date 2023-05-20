import 'dart:async';

import 'package:get/get.dart';
import 'package:syndease/screens/complete_profile.dart';

class VerifySuccessController extends GetxController {
  var current = 10;
  
  int get currentVal{
    return current;
  }
  

  @override
  Future<void> onInit() async {
    Timer(const Duration(seconds: 10), () {
      current = current - 1;
      Get.offAll(() => const CompleteProfile(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500));
    });

    super.onInit();
  }
}
