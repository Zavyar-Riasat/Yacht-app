import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  String userId;
  String yachtId;
  DateTime bookingDate; // start date
  DateTime startTime;
  DateTime endTime;
  double totalPrice;
  String status;
  String? notes;
  Timestamp? timestamp;

  Booking({
    required this.userId,
    required this.yachtId,
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
      'userId': userId,
      'yachtId': yachtId,
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
