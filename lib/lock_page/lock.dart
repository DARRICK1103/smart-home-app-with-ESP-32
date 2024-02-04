import 'package:ai_home/Data/enroll_person.dart';
import 'package:ai_home/firebase/database_service.dart';
import 'package:ai_home/lock_page/info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class DoorAcess extends StatefulWidget {
  @override
  State<DoorAcess> createState() => _DoorAcessState();
}

class _DoorAcessState extends State<DoorAcess> {
  EnrollDatabaseService enrollDatabaseService = EnrollDatabaseService();
  final database = FirebaseDatabase.instance.ref();
  List<String> idList = [];
  var enroll_data;
  var height, width;
  late bool showDelete = false;
  List<Enroll_person> list = [];
  @override
  void initState() {
    super.initState();
    // _activateListener();
  }

  int _currentId = 0;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(children: [
        Container(
          color: Colors.black,
          height: height,
          width: width,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(),
                height: height * 0.25,
                width: width,
                child: Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 35),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  showDelete = !showDelete;
                                });
                              },
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 23,
                          bottom: 9,
                          left: 10,
                        ),
                        child: Text(
                          "Smart Door Access",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 25,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 7,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              "No 118, Jalan Oz 2",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // white space face enrollment
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                height: height * 0.75,
                width: width,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 24,
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: EnrollDatabaseService().getEnroll(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // return CircularProgressIndicator(); // Loading indicator while data is being fetched
                          }

                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          if (snapshot.hasData && snapshot.data != null) {
                            idList = [];
                            list = snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              idList.add(document.id);
                              return document.data() as Enroll_person;
                            }).toList();
                          } else if (snapshot.hasError) {
                            print('Error: ${snapshot.error}');
                          }

                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: list.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return RoundedCard(
                                      data: list[index],
                                      onDelete: () {
                                        print(idList[index]);
                                        // Call the function to delete an item from the list
                                        enrollDatabaseService
                                            .deleteEnrollUser(idList[index]);
                                        final RemoveNameReference =
                                            FirebaseDatabase.instance
                                                .ref('Hardware/Remove/Name');
                                        String name = list[index].name;
                                        final RemoveRef = FirebaseDatabase
                                            .instance
                                            .ref('Hardware/Remove/isDelete');

                                        RemoveNameReference.set(name);
                                        RemoveRef.set(true);
                                        // idList.removeAt(index);
                                      },
                                      showDelete: showDelete,
                                    );
                                  },
                                ),
                                SizedBox(
                                  height: 80,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FaceInfo()),
              );
            },
            child: Icon(Icons.add),
          ),
        ),
      ]),
    );
  }
}

class RoundedCard extends StatelessWidget {
  final Enroll_person data;
  final Function onDelete; // Add onDelete callback
  final bool showDelete;

  RoundedCard({
    required this.data,
    required this.onDelete,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Left: Photo
            Container(
              margin: EdgeInsets.only(right: 10),
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  bottomLeft: Radius.circular(12.0),
                ),
                image: DecorationImage(
                  image: AssetImage('images/profile.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Right: Title and Subtitle
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          data.gender == "Male"
                              ? Icons.male_rounded
                              : Icons.female_rounded,
                          color:
                              data.gender == "Male" ? Colors.blue : Colors.pink,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(data.age + " years old")
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: showDelete,
              child: IconButton(
                onPressed: () {
                  onDelete(); // Trigger the onDelete callback
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
