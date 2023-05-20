import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:syndease/controllers/verify_controller.dart';
import 'package:syndease/screens/verify_success.dart';
import 'package:syndease/utils/widgets.dart';

import 'package:get/get.dart';

import '../utils/appVars.dart';

class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerifyController>(
        init: VerifyController(),
        builder: (controller) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: backgroundColor,
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(left: 60.w, right: 60.w),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [logo],
                          ),
                          40.verticalSpace,
                          GradientText("verifytext",
                              gradient: gradientColor,
                              style: blueTitleTextStyle),
                          10.verticalSpace,
                          Text("entercode", style: textStyle).tr(),
                          70.verticalSpace,
                          Center(
                            child: VerificationCode(
                              underlineWidth: 2.w,
                              itemSize: 50.w,
                              underlineUnfocusedColor: darkColor,
                              textStyle: const TextStyle(
                                  fontSize: 20.0, color: darkColor),
                              keyboardType: TextInputType.phone,
                              underlineColor:
                                  primaryColor, // If this is null it will use primaryColor: Colors.red from Theme
                              length: 6,
                              cursorColor: Colors.white,
                              onCompleted: (String value) {
                                controller.pinController.text = value;
                              },
                              onEditing: (bool
                                  value) {}, // If this is null it will default to the ambient
                              // clearAll is NOT required, you can delete it
                              // takes any widget, so you can implement your design
                            ),
                          ),
                          80.verticalSpace,
                          SecondaryButton(
                            text: "verifynumber",
                            onpress: () => {
                              Get.offAll(() => const VerifySuccess(),
                                  transition: Transition.fadeIn,
                                  duration: const Duration(milliseconds: 500))
                            },
                          ),
                          80.verticalSpace,
                        ]),
                  ),
                ),
              ), /* add child content here */
            ),
          );
        });
  }
}
