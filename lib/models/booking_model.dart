import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  String userEmail;   // 👈 changed from userId to userEmail
  String yachtName;   // 👈 changed from yachtId to yachtName
  DateTime bookingDate; // start date
  DateTime startTime;
  DateTime endTime;
  double totalPrice;
  String status;
  String? notes;
  Timestamp? timestamp;

  Booking({
    required this.userEmail,   // 👈 updated
    required this.yachtName,   // 👈 updated
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    this.notes,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userEmail,       // 👈 Firestore field remains 'userId' but stores email
      'yachtId': yachtName,      // 👈 Firestore field remains 'yachtId' but stores name
      'bookingDate': Timestamp.fromDate(bookingDate),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'totalPrice': totalPrice,
      'status': status,
      if (notes != null) 'notes': notes,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }
}
