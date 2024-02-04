import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class capturePerson extends StatefulWidget {
  const capturePerson({super.key});

  @override
  State<capturePerson> createState() => _capturePersonState();
}

class _capturePersonState extends State<capturePerson> {
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  late Future<void> _initializeControllerFuture;
  int direction = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();

    cameraController = CameraController(
      cameras[direction],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    return cameraController.initialize();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> flipCamera() async {
    await cameraController.dispose();
    direction = 1 - direction; // Toggle between 0 and 1
    await initializeCamera();
    setState(() {
      _initializeControllerFuture = cameraController.initialize();
    });
  }

  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(cameraController),
          GestureDetector(
            onTap: () {
              setState(() {
                direction = direction == 0 ? 1 : 0;
                startCamera(direction);
              });
            },
            child: button(Icons.flip_camera_ios_outlined, Alignment.bottomLeft),
          ),
          GestureDetector(
            onTap: () {
              cameraController.takePicture().then((XFile? file) {
                if (mounted) {
                  if (file != null) {
                    print("Picture saved to ${file.path}");
                  }
                }
              });
            },
            child: button(Icons.camera_alt_outlined, Alignment.bottomCenter),
          ),
          const Align(
            alignment: Alignment.topCenter,
            child: Text(
              "My Camera",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
  */
  Widget _buildCameraPreview() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (cameraController.value.isInitialized) {
            return CameraPreview(cameraController);
          } else {
            return Text('Error initializing camera');
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Enrollment'),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              flipCamera();
            },
            child: button(Icons.flip_camera_ios_outlined, Alignment.bottomLeft),
          ),
          GestureDetector(
            onTap: () {
              cameraController.takePicture().then((XFile? file) {
                if (mounted) {
                  if (file != null) {
                    print("Picture saved to ${file.path}");
                  }
                }
              });
            },
            child: button(Icons.camera_alt_outlined, Alignment.bottomCenter),
          ),
        ],
      ),
    );
  }

  Widget button(IconData icon, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(
          left: 20,
          bottom: 20,
        ),
        height: 50,
        width: 50,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(2, 2),
                blurRadius: 10,
              )
            ]),
        child: Center(
          child: Icon(
            icon,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
