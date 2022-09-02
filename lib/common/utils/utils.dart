import 'dart:io';

import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}

Future<File?> pickImageFromCamera(BuildContext context) async {
  File? image;
  try {
    final pickImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickImage != null) {
      image = File(pickImage.path);
    }
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return image;
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickImage != null) {
      image = File(pickImage.path);
    }
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return image;
}

Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? video;
  try {
    final pickVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickVideo != null) {
      video = File(pickVideo.path);
    }
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return video;
}

Future<GiphyGif?> pickGIF(BuildContext context) async {
  // SHnLHfSLAF334M5VVLiQRSOsipt5WYIB
  GiphyGif? gif;
  try {
    gif = await Giphy.getGif(
      context: context,
      apiKey: 'SHnLHfSLAF334M5VVLiQRSOsipt5WYIB',
    );
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return gif;
}
