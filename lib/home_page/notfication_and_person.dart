import 'package:ai_home/notification/notification.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final Function onTapPerson;

  const TopBar({required this.onTapPerson});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              onTapPerson();
            },
            icon: const Icon(Icons.person, size: 30),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
            icon: Icon(Icons.notifications, size: 30),
          ),
        ],
      ),
    );
  }
}
