import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gemini_chatbot/utility/assets_manager.dart';

class BuildDisplayImage extends StatelessWidget {
  const BuildDisplayImage(
      {super.key,
      required this.file,
      required this.userImage,
      required this.onPressed});

  final File? file;
  final String userImage;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50.0,
          backgroundColor: Colors.grey[200],
          backgroundImage: getImagetoShow(),
        ),
        Positioned(
          bottom: 0.0,
          right: 0.0,
          child: IconButton(
            icon: Icon(
              Icons.camera_alt,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }

  getImagetoShow() {
    if (file != null) {
      return FileImage(File(file!.path)) as ImageProvider<Object>;
    } else if (userImage.isNotEmpty) {
      return FileImage(File(userImage)) as ImageProvider<Object>;
    } else {
      return const AssetImage(AssetsManager.userIcon);
    }
  }
}
