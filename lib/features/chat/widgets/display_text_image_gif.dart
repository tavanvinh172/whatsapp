import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/common/enums/message_enum.dart';

class DisplayTextGIF extends StatelessWidget {
  const DisplayTextGIF({Key? key, required this.message, required this.type})
      : super(key: key);
  final String message;
  final MessageEnum type;
  @override
  Widget build(BuildContext context) {
    return type == MessageEnum.text
        ? Text(
            message,
            style: const TextStyle(
              fontSize: 16,
            ),
          )
        : CachedNetworkImage(
            imageUrl: message,
          );
  }
}
