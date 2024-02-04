import 'package:ai_home/Data/user.dart';
import 'package:ai_home/firebase/database_service.dart';
import 'package:ai_home/firebase/firebase_auth.dart';
import 'package:ai_home/firebase/toast.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class signup extends StatefulWidget {
  signup({super.key});

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  final database = FirebaseDatabase.instance.ref();
  late Users user;
  bool isSigningUp = false;
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  TextEditingController genderController = TextEditingController();
  UserDatabaseService databaseService = UserDatabaseService();
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      // Date selected
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<bool> checkEmail(String Email) async {
    Users? fetchedUser = await databaseService.getUserByEmail(Email);

    if (fetchedUser != null) {
      print('User found: ${fetchedUser.toJson()}');
      setState(() {
        user = fetchedUser;
      });
      return true;
    } else {
      print('User not found');

      return false;
    }
  }

  void _signUp() async {
    final Users_list_ref = database.child('Users');

    setState(() {
      isSigningUp = true;
    });
    String name = nameController.text.trim();

    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String gender = selectedGenderIndex == 1 ? 'Female' : 'Male';
    String date =
        "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}";
    // Check not null
    if (name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        gender.isNotEmpty &&
        selectedDate != null) {
      // Check password is the same
      if (password == confirmPassword) {
        try {
          bool gotEmail = await checkEmail(email);
          if (gotEmail == true) // cannot register
          {
            showToast(
                message:
                    "This email account has been registered. Please try again.");
          } else // can register
          {
            String imageUrl;
            if (gender == "Female") {
              imageUrl = 'female_photo.png';
            } else {
              imageUrl = 'male_photo.png';
            }
            final ref = FirebaseStorage.instance.ref(imageUrl);
            String downloadUrl = await ref.getDownloadURL();
            Users user = Users(
                nickname: name,
                birthday: date,
                gender: gender,
                email: email,
                password: password,
                photo_url: downloadUrl,
                idKey: "");
            databaseService.addUsers(user);
            showToast(message: "Sign up successfully!");
            print("New enrollment data have been successfully saved!");
            Navigator.pop(context);
          }
        } catch (e) {
          print('In enoll new data, you got an error! $e');
        }
      } else // Password is not the same
      {
        showToast(message: "Double check your password fields");
      }
    } else // Some fields is empty
    {
      showToast(message: "Please fill up all the fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Sign Up",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    FadeInUp(
                        duration: Duration(milliseconds: 1800),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Color.fromRGBO(143, 148, 251, 1)),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(143, 148, 251, .2),
                                    blurRadius: 20.0,
                                    offset: Offset(0, 10))
                              ]),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Color.fromRGBO(
                                                143, 148, 251, 1)))),
                                child: TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Nickname",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[700])),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromRGBO(143, 148, 251, 1),
                                    ),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => _selectDate(context),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: selectedDate != null
                                          ? "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}"
                                          : "Select Birthday",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[700]),
                                    ),
                                    child: Text(
                                      selectedDate != null
                                          ? "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}"
                                          : "Select Birthday",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    left: 8.0,
                                    top: 8.0,
                                    right: 8.0,
                                    bottom: 15.0),
                                margin: EdgeInsets.only(
                                  top: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromRGBO(143, 148, 251, 1),
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Gender",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(
                                          width: 25,
                                        ),
                                        GenderButton(
                                          label: 'Male',
                                          icon: Icons.male,
                                          onPressed: () {
                                            // Set the selected index to the male button
                                            setState(() {
                                              selectedGenderIndex = 0;
                                            });
                                          },
                                        ),
                                        SizedBox(width: 10),
                                        GenderButton(
                                          label: 'Female',
                                          icon: Icons.female,
                                          onPressed: () {
                                            // Set the selected index to the female button
                                            setState(() {
                                              selectedGenderIndex = 1;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Color.fromRGBO(
                                                143, 148, 251, 1)))),
                                child: TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Email Address",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[700])),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Color.fromRGBO(
                                                143, 148, 251, 1)))),
                                padding: EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Password",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[700])),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: confirmPasswordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Confirm Password",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[700])),
                                ),
                              )
                            ],
                          ),
                        )),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    FadeInUp(
                      duration: Duration(milliseconds: 2000),
                      child: GestureDetector(
                        onTap: () {
                          _signUp();
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(0, 0, 0, 1), // Dark black color
                                Color.fromRGBO(0, 0, 0,
                                    0.6), // Semi-transparent dark black color
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 42,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

int selectedGenderIndex = 0; // Default to Male

class GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function onPressed;

  const GenderButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedGenderIndex == 0 && label == 'Male' ||
        selectedGenderIndex == 1 && label == 'Female';

    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black,
            ),
            SizedBox(width: 5.0),
            Text(
              label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
