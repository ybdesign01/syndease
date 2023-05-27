import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syndease/models/category.dart';
import 'package:syndease/models/group_report.dart';
import 'package:syndease/models/sn_user.dart';
import 'package:syndease/screens/syndic/syndic_home_screen.dart';
import 'package:syndease/screens/welcome_screen.dart';
import 'package:syndease/screens/client/home_screen.dart';
import '../models/report.dart';
import '../screens/complete_profile.dart';

Future<Widget> initWidget() async {
  String fcm = await SessionManager().get('fcm') ?? "";
  print(fcm);
  String progress = await SessionManager().get('progress') ?? "";
  Widget? main;
  SnUser snUser = await getUserFromSession();
  snUser.fcm = fcm;
  await resaveUser(snUser.uid);
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

resaveUser(uid) async {
  await getUserFromDb(uid).then((val) async {
    await saveToSession(val);
  });
}

handlerPermission() async {
  var permission = await Permission.sensors.status;
  if (permission.isDenied) {
    await Permission.phone.request();
    await Permission.location.request();
    await Permission.notification.request();
  }
  if (permission.isRestricted) {
    await Permission.phone.request();
    await Permission.notification.request();
    await Permission.location.request();
  }
  if (permission.isPermanentlyDenied) {
    await Permission.phone.request();
    await Permission.location.request();
  }
  if (permission.isLimited) {
    await Permission.phone.request();
    await Permission.location.request();
    await Permission.notification.request();
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

Future getNearestSyndic(String latitude, String longitude) async {
  SnUser snUser = SnUser();
  var b = FirebaseFirestore.instance
      .collection('sn_users')
      .where('type', isEqualTo: 1)
      .snapshots();
  final firestore = FirebaseFirestore.instance;
  final snapshot =
      await firestore.collection('sn_users').where('type', isEqualTo: 1).get();
  final docs = snapshot.docs;
  final coords = docs.map((doc) => doc.data()).toList();
  List<Map<String, double>> coordsList = [];
  for (var element in coords) {
    coordsList.add({
      'latitude': double.parse(element['latitude']),
      'longitude': double.parse(element['longitude']),
    });
  }
  int closestIdx = findClosestCoord(coordsList, {
    'latitude': double.parse(latitude),
    'longitude': double.parse(longitude),
  });
  return SnUser.fromJson(docs[closestIdx].data());
}

int findClosestCoord(
    List<Map<String, double>> coords, Map<String, double> target) {
  double minDist = double.infinity;
  int closestIdx = -1;

  for (int i = 0; i < coords.length; i++) {
    double dist = _distance(coords[i]['latitude']!, coords[i]['longitude']!,
        target['latitude']!, target['longitude']!);
    if (dist < minDist) {
      minDist = dist;
      closestIdx = i;
    }
  }

  return closestIdx;
}

double _distance(double lat1, double lon1, double lat2, double lon2) {
  const int earthRadius = 6371000;
  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);
  double a = pow(sin(dLat / 2), 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = earthRadius * c;
  return distance;
}

double _toRadians(double degrees) {
  return degrees * pi / 180;
}

Future<SnUser> getUserFromSession() async {
  return SnUser.fromJson(await SessionManager().get("user") ?? {});
}

Future<List<Categories>> getAllCategories() async {
  List<Categories> categories = [];
  await FirebaseFirestore.instance.collection('categories').get().then((value) {
    for (var element in value.docs) {
      categories.add(Categories.fromJson(element.data()));
    }
  });
  return categories;
}

String capitalize(name) {
  return "${name[0].toUpperCase()}${name.substring(1).toLowerCase()}";
}

changeDateToText(String date) {
  String finaldate = date;

  DateTime finaldatee = DateTime.parse(finaldate);
  String test = DateFormat('EEEE, MMM d, yyyy ').format(finaldatee);
  return test;
}

Future<Report> getReportByid(id) async {
  Report report = Report();
  await FirebaseFirestore.instance
      .collection('reports')
      .doc(id)
      .get()
      .then((value) {
    report = Report.fromJson(value.data()!);
  });
  return report;
}

getPendingReports(SnUser snUser) async {
  List<Report> reports = [];
  await FirebaseFirestore.instance
      .collection('reports')
      .where('status', isEqualTo: 'pending')
      .where('client_uid.uid', isEqualTo: snUser.uid)
      .orderBy('creation_date', descending: true)
      .get()
      .then((value) {
    for (var element in value.docs) {
      reports.add(Report.fromJson(element.data()));
    }
  });
  return reports;
}

getSyndicPendingReports(SnUser snUser) async {
  List<Report> reports = [];
  await FirebaseFirestore.instance
      .collection('reports')
      .where('status', isEqualTo: 'pending')
      .where('syndic_uid.uid', isEqualTo: snUser.uid)
      .orderBy('creation_date', descending: true)
      .get()
      .then((value) {
    for (var element in value.docs) {
      reports.add(Report.fromJson(element.data()));
    }
  });

  return reports;
}

getAllReports(SnUser snUser) async {
  List<Report> reports = [];
  await FirebaseFirestore.instance
      .collection('reports')
      .where('client_uid.uid', isEqualTo: snUser.uid)
      .orderBy('creation_date', descending: true)
      .get()
      .then((value) {
    for (var element in value.docs) {
      reports.add(Report.fromJson(element.data()));
    }
  });
  return reports;
}

getSyndicReports(SnUser snUser) async {
  List<Report> reports = [];
  await FirebaseFirestore.instance
      .collection('reports')
      .where('syndic_uid.uid', isEqualTo: snUser.uid)
      .orderBy('creation_date', descending: true)
      .get()
      .then((value) {
    for (var element in value.docs) {
      reports.add(Report.fromJson(element.data()));
    }
  });
  return reports;
}

getGroupReportsSyndic(SnUser snUser) async {
  List<Reportgroup> reportgroup = [];
  await FirebaseFirestore.instance
      .collection('group_reports')
      .where('syndic_uid', isEqualTo: snUser.uid)
      .orderBy('creation_date', descending: true)
      .get()
      .then((value) {
    for (var element in value.docs) {
      reportgroup.add(Reportgroup.fromJson(element.data()));
    }
  });
  return reportgroup;
}

Future<void> initOneSignal() async {
  await OneSignal.shared.setAppId('e285b13b-d2da-4cec-ac90-4454e7a811e1');
  String osUserID = 'userID';
  OneSignal.shared.setSubscriptionObserver((changes) async {
    osUserID = changes.to.userId ?? '';
    String playerid = osUserID;
    await SessionManager().set('fcm', playerid);
  });
  await OneSignal.shared.promptUserForPushNotificationPermission(
    fallbackToSettings: true,
  );

  OneSignal.shared.setNotificationWillShowInForegroundHandler(
      (OSNotificationReceivedEvent event) {
    // Will be called whenever a notification is received in foreground
    // Display Notification, pass null param for not displaying the notification
    event.complete(event.notification);
  });
  OneSignal.shared
      .setNotificationOpenedHandler((OSNotificationOpenedResult result) {});
  OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {});
  await OneSignal.shared.getDeviceState();
}

sendNotification(String? fcm, heading, content) async {
  await OneSignal.shared.postNotification(OSCreateNotification(
    playerIds: [fcm!],
    content: content,
    heading: heading,
  ));
}
