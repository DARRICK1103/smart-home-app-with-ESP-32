import 'package:ai_home/Data/notification.dart';
import 'package:ai_home/firebase/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<notification> list = [];
  final NotificationDatabaseService _notificationDatabaseService =
      NotificationDatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: NotificationDatabaseService().getEnrollByTime(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.hasData && snapshot.data != null) {
            list = snapshot.data!.docs.map((DocumentSnapshot document) {
              return document.data() as notification;
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
                  itemBuilder: (BuildContext context, int index) {
                    return NotificationCard(
                      data: list[index],
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
    );
  }
}

class NotificationCard extends StatelessWidget {
  final notification data;

  const NotificationCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with your Card or custom widget
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0), // Adjust padding as needed
        title: Text(
          data.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.datetime,
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 5.0),
            Text(data.content),
            SizedBox(height: 8.0), // Adjust spacing between title and subtitle
          ],
        ),
        leading: Image.network(
          data.url,
          width: 50,
          height: 50,
        ),
      ),
    );
  }
}
