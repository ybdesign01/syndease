import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syndease/controllers/client/home_controller.dart';
import 'package:syndease/models/category.dart';
import 'package:syndease/models/report.dart';
import 'package:syndease/screens/client/home_screen.dart';
import 'package:syndease/utils/appVars.dart';
import 'package:syndease/utils/services.dart';

class NewReportController extends GetxController {
  RxBool loading = false.obs;
  TextEditingController categoryController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final homeController = Get.put(HomeController());
  List<String> categoryList = [];
  List<Categories> categoryItems = [];
  Report report = Report();

  XFile? file;
  File? image;

  selectImage() async {
    try {
      file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        image = File(file!.path);
        update();
      }
    } catch (e) {}
  }

  getMyLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    report.latitude = position.latitude.toString();
    report.longitude = position.longitude.toString();
    report.syndicUid =
        await getNearestSyndic(report.latitude!, report.longitude!);
    update();
  }

  verify() async {
    if (titleController.text.trim().isEmpty) {
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      return false;
    }
    if (categoryController.text.trim().isEmpty) {
      return false;
    }
    if (file == null) {
      return false;
    }
    return true;
  }

  submit() async {
    await verify().then((value)async {
      if (value) {
        loading.toggle();
        update();
      await  FirebaseStorage.instance
            .ref('report-images/${file!.name}')
            .putFile(image!)
            .then((p0) {
          p0.ref.getDownloadURL().then((value) async {
            report.image = value;
            report.title = titleController.text.trim();
            report.description = descriptionController.text.trim();
            report.category = categoryController.text.trim();
            report.status = "pending";
 
            report.creationDate = DateTime.now().toString();
            await FirebaseFirestore.instance
                .collection('reports')
                .add(report.toJson())
                .then((DocumentReference doc) async {
              report.uid = doc.id;
              await FirebaseFirestore.instance
                  .collection('reports')
                  .doc(doc.id)
                  .update(report.toJson());
            });

            Get.snackbar(
              "Success",
              tr("reportadded"),
            );

            loading.toggle();
            update();
            // ignore: non_constant_identifier_names
            final HomeSController = Get.put(
              HomeController(),
            );
            HomeSController.onInit();
            Get.offAll(() => const HomeScreen(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 500));
            homeController.reports.insert(0, report);
            sendNotification(report.syndicUid!.fcm,
                "${report.clientUid!.fullname} has a problem", report.title!);
          });
        });
      } else {
        Get.snackbar("Error", tr("fillallfields"),
            colorText: Colors.white, backgroundColor: dangerColor);
      }
    });
  }

  @override
  Future<void> onInit() async {
    handlerPermission();
    getMyLocation();
    loading.toggle();
    update();
    await getAllCategories().then((value) {
      categoryItems = value;
      for (var element in categoryItems) {
        Get.locale!.languageCode == 'fr'
            ? categoryList.add(element.nameFr!)
            : categoryList.add(element.nameEn!);
      }
      loading.toggle();
      update();
    });
    await getUserFromSession().then((value) async {
      report.clientUid = value;
    });
    super.onInit();
  }
}
