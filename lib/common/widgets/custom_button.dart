import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({Key? key, required this.text, required this.onPress})
      : super(key: key);
  final String text;
  final VoidCallback onPress;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
            primary: tabColor, minimumSize: const Size(double.infinity, 50)),
        child: Text(
          text,
          style: const TextStyle(color: blackColor),
        ));
  }
}
