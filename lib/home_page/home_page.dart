import 'package:ai_home/Data/user.dart';
import 'package:ai_home/drawer/about.dart';
import 'package:ai_home/drawer/photo.dart';
import 'package:ai_home/drawer/profile.dart';
import 'package:ai_home/firebase/database_service.dart';
import 'package:ai_home/home_page/background_wave.dart';
import 'package:ai_home/home_page/first_row_devices.dart';
import 'package:ai_home/home_page/notfication_and_person.dart';
import 'package:ai_home/home_page/welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  Users user;
  HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final database = FirebaseDatabase.instance.ref();
  late Stream<DocumentSnapshot> userDataStream;
  late String userID;
  int _selectedIndex = 0;
  late String username = "";
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  String receivedString = "";

  void receiveStringFromSecondClass(String message) {
    setState(() {
      receivedString = message;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      userID = widget.user.idKey;
    });

    userDataStream =
        FirebaseFirestore.instance.collection('Users').doc(userID).snapshots();
  }

  void _onTappedItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool receivedBool = false;

  void receiveBoolFromSecondClass(bool value) {
    setState(() {
      receivedBool = value;
      print("Received Bool: $receivedBool");
    });
  }

  @override
  Widget build(BuildContext context) {
    Users user = widget.user;
    print(user.photo_url);
    double screenHeight = MediaQuery.of(context).size.height;
    double topHeight = screenHeight - 200;

    return WillPopScope(
      onWillPop: () async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Exit App'),
                content: Text('Do you really want to exit the app?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Yes'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            children: [
              // Define header for drawer
              StreamBuilder<DocumentSnapshot>(
                stream: userDataStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // return CircularProgressIndicator(); // or a loading indicator
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text(
                        'Document does not exist'); // Handle the case when the document doesn't exist
                  }

                  // Assuming User.fromJson is a method to convert data to your User object
                  Users userdata = Users.fromJson(
                      snapshot.data!.data() as Map<String, dynamic>, "");
                  user = userdata;
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProfilePhoto(url: user.photo_url)),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                userdata.photo_url,
                                width: 94,
                                height: 94,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userdata.nickname,
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              userdata.gender == "Male"
                                  ? Icons.male
                                  : Icons.female,
                              color: user.gender == "Male"
                                  ? Colors.blue
                                  : Colors.pink,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Define drawer item
              ListTile(
                title: Text('Home'),
                selected: _selectedIndex == 0,

                // Register tile to onTop
                onTap: () {
                  // Update state of the app
                  _onTappedItem(0);

                  // Then, close drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Profile'),
                selected: _selectedIndex == 1,
                onTap: () {
                  // Update state of the app
                  _onTappedItem(1);
                  // Then, close drawer
                  //Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyProfile(
                              user: user,
                              userID: userID,
                            )),
                  );
                },
              ),
              ListTile(
                title: Text('About'),
                selected: _selectedIndex == 2,
                onTap: () {
                  // Update state of the app
                  _onTappedItem(2);
                  // Then, close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutApp()),
                  );
                },
              ),
            ],
          ),
        ),
        key: _globalKey,
        body: Stack(
          children: [
            Column(
              children: [
                Opacity(
                  opacity: receivedBool == true ? 0.7 : 1,
                  child: TopPart(
                    height: topHeight,
                    onTapPerson: () {
                      _globalKey.currentState?.openDrawer();
                    },
                    name: username.isEmpty ? user.nickname : username,
                    userID: user.idKey,
                  ),
                ),
                Expanded(
                    child: Container()), // This will fill the remaining space
                BottomPart(
                  onStringReceived: receiveStringFromSecondClass,
                  onBoolReceived: receiveBoolFromSecondClass,
                ),
              ],
            ),
            Visibility(
              visible: receivedBool,
              child: Positioned(
                bottom: MediaQuery.of(context).size.height / 2 - 220,
                left: (MediaQuery.of(context).size.width - 250) / 2,
                child: Center(
                  child: Container(
                    height: 100,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        receivedString + "...",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class TopPart extends StatelessWidget {
  // const TopPart({super.key});
  // ignore: prefer_typing_uninitialized_variables
  var height;
  String name;
  String userID;
  final Function onTapPerson;
  TopPart(
      {required this.height,
      required this.onTapPerson,
      required this.name,
      required this.userID});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: TopBar(
              onTapPerson: onTapPerson,
            ), // height: 40
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: WelcomeText(
              name: name,
              user_id: userID,
            ), // height: 45
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
            child: Devices(
              height: height - 90,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class Devices extends StatelessWidget {
  // const Devices({super.key});
  // ignore: prefer_typing_uninitialized_variables
  var height;
  Devices({Key? key, required this.height}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row1(
          height: height,
        ),
        Container(
          margin:
              const EdgeInsets.only(left: 16.0), // Adjust the margin as needed
          child: Row2(
            height: height,
          ),
        ),
      ],
    );
  }
}
