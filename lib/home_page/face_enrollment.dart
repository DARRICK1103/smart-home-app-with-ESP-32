import 'package:flutter/material.dart';

class ShowFaceID extends StatelessWidget {
  const ShowFaceID({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add),
            label: Text('Add'),
          ),
          Text("Face Enrollment"),
        ],
      ),
    );
  }
}

class FaceID extends StatefulWidget {
  const FaceID({super.key});

  @override
  State<FaceID> createState() => _FaceIDState();
}

class _FaceIDState extends State<FaceID> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class FaceContainer extends StatelessWidget {
  const FaceContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Icon(Icons.photo),
          Column(
            children: [],
          )
        ],
      ),
    );
  }
}
