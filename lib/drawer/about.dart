import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          "About",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  "images/logo.png",
                  width: 300,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Introduction",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Our project implements an advanced face recognition system within the smart home ecosystem for enhanced security. Face recognition offers superior security compared to traditional methods like keys or passwords, as it relies on the uniqueness of facial features. Our smart home system integrates voice control for increased convenience.",
              ),
              SizedBox(height: 16),
              Text(
                "Objective",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "I) Provide homeowners with a convenient and secure way to control home access using mobile devices, reducing reliance on traditional keys or access codes.",
              ),
              Text(
                "II) Enable integration with other smart home devices like security cameras, door locks, and alarms to create a comprehensive home security ecosystem.",
              ),
              Text(
                "III) Ensure consistent and accurate identification of authorized individuals while minimizing false positives and negatives.",
              ),
              SizedBox(height: 16),
              Text(
                "Module Developed",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "a) Smart Home Integration: The central hub connecting modules for a unified smart home experience.",
              ),
              Text(
                "b) Face Recognition Module: Manages facial recognition, automated door-locking, and real-time front door monitoring.",
              ),
              Text(
                "c) Remote Control Mobile App: Enables remote control and monitoring of smart home devices.",
              ),
              Text(
                "d) SafeGuard Fire Alert Module: Monitors environmental conditions and triggers emergency responses for fire detection.",
              ),
              SizedBox(height: 16),
              Text(
                "Conclusion",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Our project integrates smart home door locks into a comprehensive system, emphasizing convenience and safety. Accessible via smartphones, these locks identify authorized individuals through face recognition and work synergistically with other security devices, creating a secure and personalized living experience.",
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
