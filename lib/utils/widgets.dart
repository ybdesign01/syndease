import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syndease/utils/appVars.dart';

class PrimaryTextField extends StatelessWidget {
  String hintText;
  TextEditingController? controller;
  Icon? prefixIcon;
  bool? visibility;
  String? label;
  bool? centered;
  PrimaryTextField({
    this.label,
    required this.hintText,
    this.controller,
    this.prefixIcon,
    this.visibility = false,
    this.centered = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centered == true
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        label == null
            ? const Text("")
            : Text(
                tr(label!),
                textAlign: TextAlign.start,
                style: labelTextStyle,
              ),
        10.verticalSpace,
        Container(
          height: 52.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.50),
                spreadRadius: -1,
                blurRadius: 7,
                offset: const Offset(0, 0), // changes position of shadow
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: visibility ?? false,
            textAlign: centered == true ? TextAlign.center : TextAlign.start,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              filled: true,
              fillColor: const Color.fromARGB(255, 243, 243, 243),
              prefixIconColor: const Color(0xff14213D),
              hintText: tr(hintText),
              hintStyle: TextStyle(
                color: const Color(0xff14213D).withOpacity(0.5),
                fontSize: 16.sp,
                fontWeight: FontWeight.w300,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10.r),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10.r),
              ),
              prefixIcon: prefixIcon,
            ),
          ),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  String text;
  VoidCallback onpress;
  bool? loading;

  PrimaryButton(
      {required this.text, required this.onpress, this.loading, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 60.h,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r))),
            onPressed: () {
              loading == true ? null : onpress();
            },
            child: loading == true
                ? Container(
                    width: 24.w,
                    height: 24.h,
                    padding: const EdgeInsets.all(2.0),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : GradientText(
                    "Login",
                    style: textStyle,
                    gradient: gradientColor,
                  )),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  String text;
  VoidCallback onpress;
  bool? loading;

  SecondaryButton(
      {required this.text, required this.onpress, this.loading, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        height: 60.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
          gradient: gradientColor,
        ),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r))),
            onPressed: () {
              loading == true ? null : onpress();
            },
            child: loading == true
                ? Container(
                    width: 24.w,
                    height: 24.h,
                    padding: const EdgeInsets.all(2.0),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(text, style: whiteText).tr()),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style).tr(),
    );
  }
}

class InputTextField extends StatelessWidget {
  String hintText;
  TextEditingController controller;
  IconData icon;
  bool enable;
  InputTextField(
      {required this.hintText,
      required this.controller,
      required this.icon,
      this.enable = true,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: TextField(
        textCapitalization: TextCapitalization.words,
        enabled: enable,
        controller: controller,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w300,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5)),
          hintText: hintText.tr(),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16.sp,
            fontWeight: FontWeight.w300,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.3),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(9),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(9),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      ),
    );
  }
}

var logoWhite = Image.asset(
  'assets/images/syndeasewhite.png',
  width: 220.w,
);

var logo = Image.asset(
  'assets/images/syndease.png',
  width: 220.w,
);

var successImage = Image.asset(
  'assets/images/successphone.png',
  width: 220.w,
);