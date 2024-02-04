import 'package:flutter/material.dart';
import 'dart:io';

class ProfilePhoto extends StatelessWidget {
  final String? url;
  final File? pickedImage;

  ProfilePhoto({Key? key, this.url, this.pickedImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Photo",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: url != null
            ? Image.network(url!)
            : pickedImage != null
                ? Image.file(pickedImage!)
                : Text("No image selected"),
      ),
    );
  }
}
