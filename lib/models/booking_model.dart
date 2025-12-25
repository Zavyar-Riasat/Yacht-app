import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String? id;
  final String userId; // Firebase UID of user
  final String yachtId; // Yacht document id
  final String yachtName;
  final String yachtImage;
  final String yachtLocation;
  final double pricePerDay;
  final DateTime bookingDate;
  final String status; // pending | approved | rejected
  final Timestamp? timestamp;

  BookingModel({
    this.id,
    required this.userId,
    required this.yachtId,
    required this.yachtName,
    required this.yachtImage,
    required this.yachtLocation,
    required this.pricePerDay,
    required this.bookingDate,
    required this.status,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'yachtId': yachtId,
      'yachtName': yachtName,
      'yachtImage': yachtImage,
      'yachtLocation': yachtLocation,
      'pricePerDay': pricePerDay,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'status': status,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BookingModel(
      id: documentId,
      userId: map['userId'] as String? ?? '',
      yachtId: map['yachtId'] as String? ?? '',
      yachtName: map['yachtName'] as String? ?? '',
      yachtImage: map['yachtImage'] as String? ?? '',
      yachtLocation: map['yachtLocation'] as String? ?? '',
      pricePerDay: (map['pricePerDay'] is num) ? (map['pricePerDay'] as num).toDouble() : 0.0,
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      status: map['status'] as String? ?? 'pending',
      timestamp: map['timestamp'] as Timestamp?,
    );
  }
}
