import 'dart:io';

import 'package:ai_home/Data/enroll_person.dart';
import 'package:ai_home/Data/user.dart';
import 'package:ai_home/drawer/photo.dart';
import 'package:ai_home/firebase/database_service.dart';
import 'package:ai_home/firebase/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyProfile extends StatefulWidget {
  Users user;
  String userID;
  MyProfile({super.key, required this.user, required this.userID});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final nickname_controller = TextEditingController();

  final email_controller = TextEditingController();
  final password_controller = TextEditingController();
  DateTime? _selectedDate;
  File? _pickedImage;
  String? _selectedGender;
  UserDatabaseService userDatabaseService = UserDatabaseService();

  @override
  Widget build(BuildContext context) {
    Users user = widget.user;
    String userID = widget.userID;
    nickname_controller.text = user.nickname;
    email_controller.text = user.email;
    password_controller.text = user.password;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: GestureDetector(
                      onTap: () {
                        if (_pickedImage == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfilePhoto(url: user.photo_url)),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePhoto(
                                      pickedImage: _pickedImage,
                                    )),
                          );
                        }
                      },
                      child: ClipOval(
                        child: SizedBox(
                          width: 94, // Set the width as needed
                          height: 94, // Set the height as needed
                          child: _pickedImage != null
                              ? Image.file(File(_pickedImage!.path),
                                  fit: BoxFit.cover)
                              : Image.network(user.photo_url,
                                  fit: BoxFit
                                      .cover), // Replace with your default image path
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white),
                      child: GestureDetector(
                        onTap: () {
                          _pickImageFromGallery(userID);
                        },
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 45,
              ),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      cursorColor: Colors.white,
                      controller: nickname_controller,
                      style: TextStyle(
                          color: Colors.white), // Set text color to white
                      decoration: InputDecoration(
                        label: Text(
                          "Nickname",
                          style: TextStyle(color: Colors.white),
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline_outlined,
                          color: Colors.white, // Set icon color to white
                        ),
                        hintText: "Enter Your Nickname",
                        hintStyle: TextStyle(
                            color: Colors.white.withOpacity(
                                0.7)), // Set hint text color to a lighter shade of white
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: "Birthday",
                                prefixIcon: Icon(Icons.calendar_today,
                                    color: Colors.white),
                              ),
                              child: Text(
                                _selectedDate != null
                                    ? "${_selectedDate!.toLocal()}"
                                        .split(' ')[0]
                                    : user.birthday,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Gender",
                              prefixIcon: Icon(Icons.person_outline_outlined,
                                  color: Colors.white),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGender ?? user.gender,
                                isDense: true,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedGender = newValue;
                                  });
                                },
                                // Set the dropdown items' text color to white
                                style: TextStyle(color: Colors.black),
                                dropdownColor: Colors.grey[850],
                                items: <String>['Male', 'Female']
                                    .map<DropdownMenuItem<String>>(
                                      (String value) =>
                                          DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      controller: email_controller,
                      style: TextStyle(
                          color: Colors.white), // Set text color to white
                      decoration: InputDecoration(
                        label: Text("Email",
                            style: TextStyle(
                                color: Colors
                                    .white)), // Set label text color to white
                        prefixIcon: Icon(Icons.person_outline_outlined,
                            color: Colors.white), // Set icon color to white
                        hintText: "Enter Your Email",
                        hintStyle: TextStyle(
                            color: Colors.white.withOpacity(
                                0.7)), // Set hint text color to a lighter shade of white
                      ),
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: password_controller,
                      style: TextStyle(
                          color: Colors.white), // Set text color to white
                      decoration: InputDecoration(
                        label: Text("Password",
                            style: TextStyle(
                                color: Colors
                                    .white)), // Set label text color to white
                        prefixIcon: Icon(Icons.person_outline_outlined,
                            color: Colors.white), // Set icon color to white
                        hintText: "Enter Your New Password",
                        hintStyle: TextStyle(
                            color: Colors.white.withOpacity(
                                0.7)), // Set hint text color to a lighter shade of white
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 38,
              ),
              TextButton(
                  onPressed: () async {
                    if (nickname_controller.text.isNotEmpty &&
                        email_controller.text.isNotEmpty &&
                        password_controller.text.isNotEmpty) {
                      // update user data
                      String date;
                      if (_selectedDate != null) {
                        date =
                            "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}";
                      } else {
                        date = user.birthday;
                      }

                      String Url;
                      if (_pickedImage != null) {
                        final ref = FirebaseStorage.instance
                            .ref()
                            .child('usersImages')
                            .child(userID + '.jpg');
                        await ref.putFile(_pickedImage!);
                        Url = await ref.getDownloadURL();
                      } else {
                        Url = user.photo_url;
                      }

                      Users user_data = Users(
                          nickname: nickname_controller.text,
                          birthday: date,
                          gender: _selectedGender ?? user.gender,
                          email: email_controller.text,
                          password: password_controller.text,
                          photo_url: Url,
                          idKey: userID);
                      userDatabaseService.updateUser(user_data);
                      showToast(message: "Successfully updated!");
                    } else {
                      showToast(message: "Please fill up all the fields");
                    }
                  },
                  child: Text(
                    "Save",
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future _pickImageFromGallery(String userID) async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      _pickedImage = File(returnImage!.path);
    });
  }
}
