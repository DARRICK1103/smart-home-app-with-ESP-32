import 'package:ai_home/Data/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class WelcomeText extends StatefulWidget {
  String name;
  String user_id;
  WelcomeText({
    super.key,
    required this.name,
    required this.user_id,
  });

  @override
  State<WelcomeText> createState() => _WelcomeTextState();
}

class _WelcomeTextState extends State<WelcomeText> {
  final database = FirebaseDatabase.instance.ref();
  late Stream<DocumentSnapshot> userDataStream;
  late String userID;
  late Users user;

  @override
  void initState() {
    super.initState();
    setState(() {
      userID = widget.user_id;
    });

    userDataStream =
        FirebaseFirestore.instance.collection('Users').doc(userID).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    print("userID: " + userID);
    return StreamBuilder<DocumentSnapshot>(
      stream: userDataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(""); // Placeholder for loading state
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Access user data from the snapshot
          Users userdata =
              Users.fromJson(snapshot.data!.data() as Map<String, dynamic>, "");

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Text(
                  "Hello, " + userdata.nickname + "!",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                child: Text(
                  'Welcome Home',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              // Add other widgets to display user data as needed
            ],
          );
        }
      },
    );
  }
}
