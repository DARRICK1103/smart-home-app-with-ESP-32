import 'dart:async';
import 'dart:convert';
import 'package:ai_home/firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MyImageWidget extends StatefulWidget {
  @override
  _MyImageWidgetState createState() => _MyImageWidgetState();
}

class _MyImageWidgetState extends State<MyImageWidget> {
  final databaseReference = FirebaseDatabase.instance.ref('Hardware/Live');
  String imageData = '';
  late StreamSubscription _databaseReference;

  @override
  void initState() {
    super.initState();
    // Set up the event listener for changes in the Firebase Realtime Database

    _databaseReference = databaseReference.onValue.listen((event) {
      // Handle changes in the database
      setState(() {
        // Assuming your data is a string, adjust this part accordingly
        imageData = event.snapshot.value.toString();
      });
    });

    // Fetch initial image data from Firebase
    getImageData().then((data) {
      setState(() {
        imageData = data;
      });
    });
  }

  Future<String> getImageData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('Hardware/Live');
    DatabaseEvent snapshot = await ref.once();
    return snapshot.snapshot.value.toString();
  }

  @override
  void deactivate() {
    // Clean up resources and stop listening to the database when the widget is disposed

    _databaseReference.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Live Streaming',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: imageData.isNotEmpty
            ? Image.memory(
                base64Decode(imageData),
                width: 400, // Adjust the width as needed
                height: 400, // Adjust the height as needed
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
