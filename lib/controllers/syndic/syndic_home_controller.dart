import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:syndease/models/sn_user.dart';
import 'package:syndease/screens/welcome_screen.dart';
import 'package:syndease/utils/services.dart';

class SyndicHomeController extends GetxController {
  SnUser snUser = SnUser();
  void logout() async {
    FirebaseAuth.instance.signOut();
    await SessionManager().destroy();
    Get.offAll(() => const WelcomeScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500));
  }

  @override
  void onInit() {
    getUserFromSession().then((value) {
      snUser = value;
      update();
    });
    super.onInit();
  }
}
