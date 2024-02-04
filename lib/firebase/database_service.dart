import 'package:ai_home/Data/enroll_person.dart';
import 'package:ai_home/Data/notification.dart';
import 'package:ai_home/Data/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String Users_Ref = "Users";

class UserDatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _usersRef;

  UserDatabaseService() {
    _usersRef = _firestore.collection(Users_Ref).withConverter<Users>(
        fromFirestore: (snapshots, _) => Users.fromJson(snapshots.data()!, ""),
        toFirestore: (user, _) => user.toJson());
    _firestore.collection(Users_Ref).doc();
  }

  Stream<QuerySnapshot> getUsers() {
    return _usersRef.snapshots();
  }

  void addUsers(Users user) async {
    _usersRef.add(user);
  }

  Future<Users?> getUserByEmail(String email) async {
    try {
      print("Querying for email: $email");
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('Users')
          .where('Email', isEqualTo: email.trim())
          .get();

      if (snapshot.docs.isNotEmpty) {
        print("not emoty");
        String userId = snapshot.docs.first.id;
        // Assuming there is only one user with a given email
        return Users.fromJson(snapshot.docs.first.data(), userId);
      } else {
        print("emptyt");
        return null; // User not found
      }
    } catch (e) {
      print("Error getting user by email: $e");
      return null;
    }
  }

  Future<Users?> getUserByEmailAndPassword(
      String email, String password) async {
    try {
      print("Querying for email: $email");
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('Users')
          .where('Email', isEqualTo: email.trim())
          .where('Password', isEqualTo: password.trim())
          .get();

      if (snapshot.docs.isNotEmpty) {
        String userId = snapshot.docs.first.id;
        print("User found");
        print(userId);
        return Users.fromJson(snapshot.docs.first.data(), userId);
      } else {
        print("User not found");
        return null;
      }
    } catch (e) {
      print("Error getting user by email and password: $e");
      return null;
    }
  }

  Future<void> updateUser(Users updatedUser) async {
    try {
      // Get the reference to the document using the provided documentId
      DocumentReference documentReference = _usersRef.doc(updatedUser.idKey);

      // Update the document with the new data
      await documentReference.update(updatedUser.toJson());
      print("Document updated");
    } catch (e) {
      print("Error updating enroll user: $e");
    }
  }
}

const String Enroll_ref = "Enrollment";

class EnrollDatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _enrollRef;

  EnrollDatabaseService() {
    _enrollRef = _firestore.collection(Enroll_ref).withConverter<Enroll_person>(
        fromFirestore: (snapshots, _) =>
            Enroll_person.fromJson(snapshots.data()!, ""),
        toFirestore: (user, _) => user.toJson());
    _firestore.collection(Enroll_ref).doc();
  }

  Stream<QuerySnapshot> getEnroll() {
    return _enrollRef.snapshots();
  }

  void addEnrollUsers(Enroll_person user) async {
    try {
      await _enrollRef.add(user);
      print("done");
    } catch (e) {
      print("Error adding enroll user: $e");
    }
  }

  Future<void> deleteEnrollUser(String documentId) async {
    try {
      // Get the reference to the document using the provided documentId
      DocumentReference documentReference = _enrollRef.doc(documentId);

      // Delete the document
      await documentReference.delete();
      print("Document deleted");
    } catch (e) {
      print("Error deleting enroll user: $e");
    }
  }

  Future<void> updateEnrollUser(Enroll_person updatedUser) async {
    try {
      // Get the reference to the document using the provided documentId
      DocumentReference documentReference = _enrollRef.doc(updatedUser.id);

      // Update the document with the new data
      await documentReference.update(updatedUser.toJson());
      print("Document updated");
    } catch (e) {
      print("Error updating enroll user: $e");
    }
  }
}

const String Notification_ref = "Notification";

class NotificationDatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _notificationRef;

  NotificationDatabaseService() {
    _notificationRef = _firestore
        .collection(Notification_ref)
        .withConverter<notification>(
            fromFirestore: (snapshots, _) =>
                notification.fromJson(snapshots.data()!),
            toFirestore: (user, _) => user.toJson());
    _firestore.collection(Notification_ref).doc();
  }

  Stream<QuerySnapshot> getEnroll() {
    return _notificationRef.snapshots();
  }

  Stream<QuerySnapshot> getEnrollByTime() {
    return _notificationRef
        .orderBy(
          'Datetime',
          descending: true,
          // Convert the 'Datetime' string to a DateTime object for correct sorting
          // This assumes 'Datetime' is in the format 'yyyy-MM-dd HH:mm:ss'
          // If it's in a different format, adjust the parsing accordingly
          // Also, make sure all your 'Datetime' strings are in a valid date format
          // to avoid runtime errors.
          // This is just a simple example and may not cover all edge cases.
          // You might want to add additional error handling based on your specific needs.
          // For more robust parsing, consider using a package like 'intl'.
          // Example: DateTime.parse(snapshot.data()['Datetime']),
        )
        .snapshots();
  }

  void addEnrollUsers(notification user) async {
    try {
      await _notificationRef.add(user);
      print("done");
    } catch (e) {
      print("Error adding notification: $e");
    }
  }
}
