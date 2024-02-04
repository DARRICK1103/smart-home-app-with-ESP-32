import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ScaningFace extends StatefulWidget {
  const ScaningFace({super.key});

  @override
  State<ScaningFace> createState() => _ScanFaceState();
}

class _ScanFaceState extends State<ScaningFace> {
  final databaseReference = FirebaseDatabase.instance.ref('Hardware/isEnroll');

  late StreamSubscription _databaseReference;
  @override
  void initState() {
    super.initState();
    _databaseReference = databaseReference.onValue.listen((event) {
      if (event.snapshot.value.toString() == "false") // isEnroll done
      {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    });
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 205,
              height: 218,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ), // Rounded corners
                border: Border.all(
                  color: Colors.black, // Border color
                  width: 2.0, // Border width
                ),
              ),
              child: Center(
                child: ScanningRoundedContainerWithImage(),
              ),
            ),
            SizedBox(
              height: 18,
            ),
            Text("Please stand in front of the camera..."),
          ],
        ),
      ),
    );
  }
}

class ScanningRoundedContainerWithImage extends StatefulWidget {
  @override
  _ScanningRoundedContainerWithImageState createState() =>
      _ScanningRoundedContainerWithImageState();
}

class _ScanningRoundedContainerWithImageState
    extends State<ScanningRoundedContainerWithImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: ScanningLinePainter(animation: _controller),
        child: Center(
          child: Image.asset(
            'images/camera.png', // Replace with the path to your image
            width: 150, // Adjust the width as needed
            height: 150, // Adjust the height as needed
            fit: BoxFit.cover, // Adjust the fit as needed
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ScanningLinePainter extends CustomPainter {
  final Animation<double> animation;

  ScanningLinePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green // Line color
      ..strokeWidth = 2.0;

    final double lineHeight = size.height * animation.value;
    canvas.drawLine(
        Offset(0, lineHeight), Offset(size.width, lineHeight), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
