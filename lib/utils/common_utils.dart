import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:r_w_r/constants/color_constants.dart';

import '../components/app_loader.dart';
import '../constants/api_constants.dart';
import 'color.dart';

class CommonUtils {
 static bool isProd= bool.fromEnvironment('dart.vm.product');
  static void goToScreen(BuildContext context, Widget className) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => className));
  }

  static commonTextLabelsStyle({double fontSize = 14}) {
    return TextStyle(
      fontFamily: AppConstants.ptSansFont,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    );
  }

  static commonInputTextStyle({Color color=Colors.black,double size=14,FontWeight fWeight=FontWeight.w500}) {
    return TextStyle(
      fontFamily: AppConstants.ptSansFont,
      fontSize: size,
      fontWeight: fWeight,
      color:color,
    );
  }

  static commonHintTextStyle() {
    return TextStyle(
      fontFamily: AppConstants.ptSansFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFFB1B1B1),
    );
  }

  static commonInputBoxDecoration({Color color=Colors.transparent}) {
    return BoxDecoration(
      color: color,
      border: Border.all(color: ColorConstants.inputFieldBorderColor),
      borderRadius: BorderRadius.circular(6),
    );
  }

  static commonGradientBorderButton(
      {required String text, required void Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradientFirst,
              gradientSecond,
              // gradientThird,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Container(
          width: 80,
          height: 25,
          margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'browse',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget commonFileUploadWidget({
    required String title,
    required String from,
    required Size size,
    required List<XFile?> images,
    required String type,
    required void Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: CommonUtils.commonTextLabelsStyle(),
        ),
        SizedBox(height: 8),
        Container(
          width: size.width,
          decoration: BoxDecoration(
            border: Border.all(color: ColorConstants.inputFieldBorderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 32,
                color: Color(0xFF8B5CF6),
              ),
              SizedBox(height: 8),
              Text(
                'select your file or drag and drop',
                style: CommonUtils.commonTextLabelsStyle(),
              ),
              SizedBox(height: 4),
              Text(
                'png, pdf, jpg, docx accepted',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: AppConstants.ptSansFont,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),
              CommonUtils.commonGradientBorderButton(
                text: "browse",
                onTap: onTap,
              ),
              if (images.isNotEmpty)
                showAadhaarCardImages(images: images)
              else
                SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  static commonTitleStyle(
      {double? fontSize, FontWeight? weight, Color? color}) {
    return TextStyle(
      fontFamily: AppConstants.ptSansFont,
      fontSize: fontSize ?? 18,
      fontWeight: weight ?? FontWeight.w700,
      color: color ?? ColorConstants.black2,
    );
  }

  static loadNextButton({bool isBlack = true}) {
    return SvgPicture.asset(
      "assets/svg/next_fill.svg",
      width: 24,
      height: 24,
      color: isBlack?Colors.black:Colors.white,
    );
  }
}

class showAadhaarCardImages extends StatefulWidget {
  final List<XFile?> images;

  const showAadhaarCardImages({required this.images, super.key});

  @override
  State<showAadhaarCardImages> createState() => _showAadhaarCardImagesState();
}

class _showAadhaarCardImagesState extends State<showAadhaarCardImages> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 100,
      width: double.infinity,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.images.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                  clipBehavior: Clip.hardEdge,
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.grey.shade400,
                    border: Border.all(color: AppColors.blue, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Image.file(
                      File(widget.images[index]?.path ?? ""),
                      width: 50,
                      fit: BoxFit.cover,
                      height: 50,
                    ),
                  )),
              Positioned(
                  right: 5,
                  top: 12,
                  child: GestureDetector(
                    onTap: () {
                      widget.images.removeAt(index);
                      updateState();
                    },
                    child: SvgPicture.asset(
                      "assets/svg/cross.svg",
                      width: 15,
                      height: 15,
                    ),
                  ))
            ],
          );
        },
      ),
    );
  }

  void updateState() {
    setState(() {});
  }
}
