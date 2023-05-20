import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syndease/models/sn_user.dart';
import 'package:syndease/screens/syndic/syndic_home_screen.dart';
import 'package:syndease/screens/verify_screen.dart';
import 'package:syndease/screens/welcome_screen.dart';
import 'package:syndease/screens/client/home_screen.dart';

import '../screens/complete_profile.dart';

Future<Widget> initWidget() async {
  String progress = await SessionManager().get('progress') ?? "";
  Widget? main;
  SnUser snUser = await getUserFromSession();
  if (snUser.uid == null) {
    main = const WelcomeScreen();
  } else if (snUser.type == 0) {
    switch (progress) {
      case 'homeScreen':
        main = const HomeScreen();
        break;
      case 'completeProfile':
        main = const CompleteProfile();
        break;

      default:
        main = const WelcomeScreen();
    }
  } else {
    main = const SyndicHomeScreen();
  }

  return main;
}

handlerPermission() async {
  var permission = await Permission.sensors.status;
  if (permission.isDenied) {
    await Permission.phone.request();
    await Permission.location.request();
  }
  if (permission.isRestricted) {
    await Permission.phone.request();
    await Permission.location.request();
  }
  if (permission.isPermanentlyDenied) {
    await Permission.phone.request();
    await Permission.location.request();
  }
  if (permission.isLimited) {
    await Permission.phone.request();
    await Permission.location.request();
  }
}

Future<String> checkPhoneNumber(uid) async {
  String message = "not-found";
  await FirebaseFirestore.instance
      .collection('sn_users')
      .doc(uid)
      .get()
      .then((value) {
    if (value.exists && value['fullname'] != '') message = "found-in-users";
  });
  // await FirebaseFirestore.instance
  //     .collection('sn_users')
  //     .where('uid', isEqualTo: "wR3PlhkC1WQ7lJlBFYkqAGCM6Sl2")
  //     .snapshots()
  //     .first
  //     .then((value) {
  //   if (value.size != 0) message = "found-in-users";
  // });
  return message;
}

saveUserToDb(SnUser user) async {
  await FirebaseFirestore.instance
      .collection('sn_users')
      .doc(user.uid)
      .set(user.toJson());
}

getUserFromDb(uid) async {
  SnUser snUser = SnUser();
  await FirebaseFirestore.instance
      .collection('sn_users')
      .doc(uid)
      .get()
      .then((value) {
    if (value.exists) snUser = SnUser.fromJson(value.data()!);
  });
  return snUser;
}

saveToSession(SnUser user) async {
  await SessionManager().set("user", user);
}

Future<SnUser> getUserFromSession() async {
  return SnUser.fromJson(await SessionManager().get("user") ?? {});
}
