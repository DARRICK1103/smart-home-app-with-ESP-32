import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

// microphone and background wave
class BottomPart extends StatefulWidget {
  final Function(String) onStringReceived;
  final Function(bool) onBoolReceived;

  const BottomPart({
    super.key,
    required this.onStringReceived,
    required this.onBoolReceived,
  });

  @override
  State<BottomPart> createState() => _BottomPartState();
}

class _BottomPartState extends State<BottomPart> {
  void sendStringToFirstClass() {
    widget.onStringReceived(text);
  }

  void sendBoolToFirstClass() {
    print("Sending Bool to FirstClass");
    // Invoke the callback in the first class with the boolean value
    widget.onBoolReceived(display);
  }

  bool display = false;
  SpeechToText speechToText = SpeechToText();
  var text;
  bool isListening = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          width: MediaQuery.of(context).size.width,
          child: BackgroundWave(),
        ),
        Center(
          child: AvatarGlow(
            animate: isListening,
            // microphone
            glowColor: Colors.black,
            endRadius: 70.0,
            repeat: true,
            duration: const Duration(milliseconds: 1000),
            showTwoGlows: true,
            child: GestureDetector(
              onTapDown: (details) async {
                if (!isListening) {
                  var available = await speechToText.initialize();
                  if (available) {
                    setState(() {
                      display = true;
                    });
                    sendBoolToFirstClass();
                    setState(() {
                      isListening = true;

                      speechToText.listen(
                        onResult: (result) {
                          setState(() {
                            text = result.recognizedWords;
                            print(text);
                            sendStringToFirstClass();
                          });
                        },
                      );
                    });
                  }
                }
              },
              onTapUp: (details) {
                if (text != null) {
                  if (text.toLowerCase().contains("light") &&
                      text.toLowerCase().contains("on")) {
                    print('on the light');
                    // Perform actions for turning the light on
                    FirebaseDatabase.instance
                        .ref()
                        .child('ESP 32 WROOM/Light')
                        .update({
                      'LightOn': true
                          .toString(), // Adjust this based on your data structure
                    });

                    // Add your logic to control the light here
                  }

                  if (text.toLowerCase().contains("light") &&
                      text.toLowerCase().contains("off")) {
                    // Perform actions for turning the light on
                    FirebaseDatabase.instance
                        .ref()
                        .child('ESP 32 WROOM/Light')
                        .update({
                      'LightOn': false
                          .toString(), // Adjust this based on your data structure
                    });

                    // Add your logic to control the light here
                  }

                  // alarm
                  if (text.toLowerCase().contains("alarm") &&
                      text.toLowerCase().contains("on")) {
                    print('on the light');
                    // Perform actions for turning the light on
                    FirebaseDatabase.instance
                        .ref()
                        .child('ESP 32 WROOM')
                        .update({
                      'BuzzerRing': true
                          .toString(), // Adjust this based on your data structure
                    });

                    // Add your logic to control the light here
                  }

                  if (text.toLowerCase().contains("alarm") &&
                      text.toLowerCase().contains("off")) {
                    // Perform actions for turning the light on
                    FirebaseDatabase.instance
                        .ref()
                        .child('ESP 32 WROOM')
                        .update({
                      'BuzzerRing': false
                          .toString(), // Adjust this based on your data structure
                    });

                    // Add your logic to control the light here
                  }

                  // door lock
                  if (text.toLowerCase().contains("door") &&
                      (text.toLowerCase().contains("lock") ||
                          text.toLowerCase().contains("on"))) {
                    print('on the light');
                    // Perform actions for turning the light on
                    FirebaseDatabase.instance
                        .ref()
                        .child('ESP 32 WROOM')
                        .update({
                      'DoorLock': true
                          .toString(), // Adjust this based on your data structure
                    });

                    // Add your logic to control the light here
                  }

                  if (text.toLowerCase().contains("door") &&
                      (text.toLowerCase().contains("unlock") ||
                          text.toLowerCase().contains("off"))) {
                    // Perform actions for turning the light on
                    FirebaseDatabase.instance
                        .ref()
                        .child('ESP 32 WROOM')
                        .update({
                      'DoorLock': false
                          .toString(), // Adjust this based on your data structure
                    });

                    // Add your logic to control the light here
                  }
                }

                setState(() {
                  isListening = false;
                });
                setState(() {
                  display = false;
                });
                sendBoolToFirstClass();
                text = "";
                sendStringToFirstClass();
                speechToText.stop();
              },
              child: CircleAvatar(
                backgroundColor: Colors.black,
                radius: 35,
                child: Icon(
                  isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                ),
              ),
              /*
              child: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {},
                child: Icon(
                  isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 33,
                ),
              ),
              */
            ),
          ),
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class BackgroundWave extends StatelessWidget {
  var isListening = false;
  // BackgroundWave({Key? key, required this.height}) : super(key: key);
  BackgroundWave({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomBar();
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40,
        ),
        SizedBox(
          child: ClipPath(
              clipper: BackgroundWaveClipper(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
              )),
        ),
      ],
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  var islistening = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AvatarGlow(
        endRadius: 75.0,
        animate: false,
        duration: const Duration(milliseconds: 2000),
        glowColor: Colors.black,
        repeat: true,
        repeatPauseDuration: const Duration(milliseconds: 100),
        showTwoGlows: true,
        child: GestureDetector(
          onTapDown: (details) {
            setState(() {
              islistening = true;
            });
          },
          onTapUp: (details) {
            setState(() {
              islistening = false;
            });
          },
          child: const CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 35,
            child: Icon(
              Icons.mic,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class BackgroundWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    final p0 = size.height;
    final p1 = size.width;
    path.lineTo(0.0, p0);
    path.lineTo(p1, p0);
    path.lineTo(p1, p0 * 0.05);

    final controlPoint1 = Offset(size.width * 0.85, size.height * -0.1);
    final endPoint1 = Offset(size.width * 0.75, size.height * 0.3);

    path.quadraticBezierTo(
        controlPoint1.dx, controlPoint1.dy, endPoint1.dx, endPoint1.dy);

    final controlPoint2 = Offset(size.width * 0.5, size.height * 1.3);
    final endPoint2 = Offset(size.width * 0.25, size.height * 0.3);

    path.quadraticBezierTo(
        controlPoint2.dx, controlPoint2.dy, endPoint2.dx, endPoint2.dy);

    final controlPoint3 = Offset(size.width * 0.15, size.height * -0.1);
    final endPoint3 = Offset(size.width * 0.0, size.height * 0.05);

    path.quadraticBezierTo(
        controlPoint3.dx, controlPoint3.dy, endPoint3.dx, endPoint3.dy);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(BackgroundWaveClipper oldClipper) => oldClipper != this;
}
