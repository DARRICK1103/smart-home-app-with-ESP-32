import 'package:ai_home/CCTV/streaming.dart';
import 'package:ai_home/Data/notification.dart';
import 'package:ai_home/firebase/database_service.dart';
import 'package:ai_home/lock_page/info.dart';
import 'package:ai_home/lock_page/lock.dart';
import 'package:ai_home/light/light.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class Row1 extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  var height;

  Row1({Key? key, required this.height}) : super(key: key);

  @override
  State<Row1> createState() => _Row1State();
}

class _Row1State extends State<Row1> {
  //Row1({super.key});
  bool isLightOn = false;
  bool isDoorLock = false;
  // ignore: non_constant_identifier_names
  int brightness_level = 0;
  NotificationDatabaseService notificationDatabaseService =
      NotificationDatabaseService();
  final _database = FirebaseDatabase.instance.ref();
  String personName = "";
  void sendNotification(notification notification) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'basic_channel',
        title: notification.title,
        body: notification.content,
        notificationLayout: NotificationLayout.Default,
        bigPicture: notification.url,
        displayOnForeground: true,
        displayOnBackground: true,
        payload: {'datetime': notification.datetime},
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Initialize Firebase Realtime Database reference
    DatabaseReference doorStatusRef =
        FirebaseDatabase.instance.ref().child('ESP 32 WROOM').child('DoorLock');

    DatabaseReference lightStatusRef = FirebaseDatabase.instance
        .ref()
        .child('ESP 32 WROOM')
        .child('Light')
        .child('LightOn');

    DatabaseReference brightnessStatusRef = FirebaseDatabase.instance
        .ref()
        .child('ESP 32 WROOM')
        .child('Light')
        .child('Brightness');

    DatabaseReference recogniseStatusRef =
        FirebaseDatabase.instance.ref().child('Hardware').child('isRecognise');

    DatabaseReference fireStatusRef = FirebaseDatabase.instance
        .ref()
        .child('ESP 32 WROOM')
        .child('FireDetected');

    // Listen for changes in the door status
    doorStatusRef.onValue.listen((DatabaseEvent event) {
      print("check door lock");
      print(event.snapshot.value);
      // Update the isDoorOpen state based on the data in the database
      setState(() {
        isDoorLock = event.snapshot.value.toString() ==
            'true'; // Adjust this based on your data structure
        print("Updated isDoorLock: $isDoorLock");
      });
      if (isDoorLock == true) {
        _database.child("Hardware").child("isRecognise").set(false);
      }
    });

    lightStatusRef.onValue.listen((DatabaseEvent event) {
      print("light here");
      print(event.snapshot.value);
      setState(() {
        isLightOn = event.snapshot.value.toString() == 'true';
        print("Updated isLightOn: $isLightOn");
      });
    });

    brightnessStatusRef.onValue.listen((DatabaseEvent event) {
      print(event.snapshot.value);
      setState(() {
        brightness_level = int.parse(event.snapshot.value.toString());
        print("Updated brightness: $brightness_level");
      });
    });

    recogniseStatusRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value.toString() == "true") // is Recognise
      {
        _database.child("ESP 32 WROOM").child("DoorLock").set(false); // unlock

        fetchData();
/*
        notification Notification = notification(
            title: "Fire Detected!",
            content: "Alert! There is a fire detected. Take necessary actions.",
            url:
                "https://firebasestorage.googleapis.com/v0/b/esp-32-d9503.appspot.com/o/face.png?alt=media&token=ba5eebb1-6b9c-45eb-8f0d-b29e4a99bd51",
            datetime: formattedDateTime);
            */
      }
    });
    fireStatusRef.onValue.listen((DatabaseEvent event) {
      print(event.snapshot.value);
      if (event.snapshot.value.toString() == "true") {
        DateTime currentTime = DateTime.now();
        String formattedDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(currentTime);
        notification Notification = notification(
            title: "Fire Detected",
            content: "Alert! There is a fire detected. Take necessary actions.",
            url:
                "https://firebasestorage.googleapis.com/v0/b/esp-32-d9503.appspot.com/o/fire.png?alt=media&token=50691abb-ea77-48c8-b3fa-b988df9ed5ea",
            datetime: formattedDateTime);
        notificationDatabaseService.addEnrollUsers(Notification);
        sendNotification(Notification);
        showConfirmationDialog(context);
      }
    });
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fire Detected'),
          content: Text('Do you want to call firefighters?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                callFirefighters();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Call'),
            ),
          ],
        );
      },
    );
  }

  final String emergencyNumber = '999';
  void callFirefighters() async {
    String url = 'tel:$emergencyNumber';
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  fetchData() async {
    try {
      final snapshot = await _database.child("Hardware/Message").get();
      print("object");
      print(snapshot.value);

      setState(() {
        personName = snapshot.value.toString();
      });

      print("huidsasd  " + personName);

      // Your remaining code here...
      DateTime currentTime = DateTime.now();
      String formattedDateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(currentTime);
      notification Notification = notification(
          title: "Access Granted",
          content: "Welcome, $personName! Access granted. Door unlocked.",
          url:
              "https://firebasestorage.googleapis.com/v0/b/esp-32-d9503.appspot.com/o/face.png?alt=media&token=ba5eebb1-6b9c-45eb-8f0d-b29e4a99bd51",
          datetime: formattedDateTime);
      notificationDatabaseService.addEnrollUsers(Notification);
      sendNotification(Notification);
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  // Callback function to update isDoorOpen
  void updateLightState(bool newIsLightOn) {
    FirebaseDatabase.instance.ref().child('ESP 32 WROOM/Light').update({
      'LightOn':
          newIsLightOn.toString(), // Adjust this based on your data structure
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        SizedBox(
          width: (screenWidth / 2) - 33,
          height: (widget.height / 2) - 30,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DoorAcess()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero, // Remove padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDoorLock ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0)
                        .copyWith(top: 10.0),
                    child: Container(
                      alignment: Alignment.center,
                      child: Image.asset("images/lock.png"),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 15),
                        child: Text(
                          "Smart Lock",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDoorLock ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Transform.rotate(
                        angle: -90 * 3.141592653589793 / 180,
                        child: Switch(
                          value: isDoorLock,
                          onChanged: (value) {
                            FirebaseDatabase.instance
                                .ref()
                                .child('ESP 32 WROOM')
                                .update({
                              'DoorLock': value
                                  .toString(), // Adjust this based on your data structure
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                ],
              ),
            ),
          ),
        ),

        /*
        Container(
          width: (screenWidth / 2) - 35,
          height: (widget.height / 2) - 33,
          color: Colors.green,
          margin: const EdgeInsets.only(top: 10),
          child: const Center(
            child: SizedBox(
              width: 100,
              height: 20,
              child: Icon(Icons.lock),
            ),
          ),
        ),
        */
        Container(
          width: (screenWidth / 2) - 33,
          height: (widget.height / 2) - 30,
          margin: const EdgeInsets.only(top: 15),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SmartLight(
                    lightData: LightData(isLightOn: isLightOn),
                    updateLightState: updateLightState,
                    brightnessLevel: brightness_level,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero, // Remove padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isLightOn ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0)
                        .copyWith(top: 10.0),
                    child: Container(
                      alignment: Alignment.center,
                      child: Image.asset("images/stand_light.png"),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(left: 15),
                          child: Text(
                            "Light Bulb",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isLightOn ? Colors.white : Colors.black),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Transform.rotate(
                        angle: -90 * 3.141592653589793 / 180,
                        child: Switch(
                          value: isLightOn,
                          onChanged: (value) {
                            FirebaseDatabase.instance
                                .ref()
                                .child('ESP 32 WROOM/Light')
                                .update({
                              'LightOn': value
                                  .toString(), // Adjust this based on your data structure
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
        /*
        Container(
          width: (screenWidth / 2) - 33,
          height: (widget.height / 2) - 30,
          margin: const EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            color: isLightOn ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0)
                    .copyWith(top: 10.0),
                child: Container(
                  alignment: Alignment.center,
                  child: Image.asset("images/thermostat.png"),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Light Bulb",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isLightOn ? Colors.white : Colors.black),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Transform.rotate(
                    angle: -90 * 3.141592653589793 / 180,
                    child: Switch(
                      value: isLightOn,
                      onChanged: (value) {
                        setState(() {
                          isLightOn = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 6,
              ),
            ],
          ),
        ),
        */
      ],
    );
  }

  gradiant() {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
            Colors.black,
            Colors.black54,
          ])),
    );
  }
}

// ignore: must_be_immutable
class Row2 extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  var height;

  Row2({Key? key, required this.height}) : super(key: key);

  @override
  State<Row2> createState() => _Row2State();
}

class _Row2State extends State<Row2> {
  bool isCCTVOn = false;
  bool isBuzzerOn = false;
  //const Row2({super.key});

  @override
  void initState() {
    super.initState();
    // Initialize Firebase Realtime Database reference
    DatabaseReference fireStatusRef = FirebaseDatabase.instance
        .ref()
        .child('ESP 32 WROOM')
        .child('BuzzerRing');

    fireStatusRef.onValue.listen((DatabaseEvent event) {
      print("Buzzer");
      print(event.snapshot.value);
      setState(() {
        isBuzzerOn = event.snapshot.value.toString() == 'true';
        print("Updated isLightOn: $isBuzzerOn");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          width: (screenWidth / 2) - 35,
          height: (widget.height / 2) - 38,
          child: ElevatedButton(
            onPressed: () {
              if (isCCTVOn) {
                Navigator.push(
                  context,
                  // Streaming
                  MaterialPageRoute(builder: (context) => MyImageWidget()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero, // Remove padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isCCTVOn ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0)
                        .copyWith(top: 10.0),
                    child: Container(
                      alignment: Alignment.center,
                      child: Image.asset("images/cctv.png"),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(left: 15),
                          child: Text(
                            "CCTV",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isCCTVOn ? Colors.white : Colors.black),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Transform.rotate(
                        angle: -90 * 3.141592653589793 / 180,
                        child: Switch(
                          value: isCCTVOn,
                          onChanged: (value) {
                            setState(() {
                              isCCTVOn = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: (screenWidth / 2) - 35,
          height: (widget.height / 2) - 40,
          margin: const EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            color: isBuzzerOn ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0)
                    .copyWith(top: 10.0),
                child: Container(
                  alignment: Alignment.center,
                  child: Image.asset("images/alarm.png"),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Alarm",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isBuzzerOn ? Colors.white : Colors.black),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Transform.rotate(
                    angle: -90 * 3.141592653589793 / 180,
                    child: Switch(
                      value: isBuzzerOn,
                      onChanged: (value) {
                        FirebaseDatabase.instance
                            .ref()
                            .child('ESP 32 WROOM')
                            .update({
                          'BuzzerRing': value
                              .toString(), // Adjust this based on your data structure
                        });
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
