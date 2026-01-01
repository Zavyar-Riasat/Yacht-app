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
    DateTime parseBookingDate(dynamic raw) {
      if (raw == null) return DateTime.now();
      if (raw is Timestamp) return raw.toDate();
      if (raw is DateTime) return raw;
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
      if (raw is String) {
        try {
          return DateTime.parse(raw);
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return BookingModel(
      id: documentId,
      userId: map['userId'] as String? ?? '',
      yachtId: map['yachtId'] as String? ?? '',
      yachtName: map['yachtName'] as String? ?? '',
      yachtImage: map['yachtImage'] as String? ?? '',
      yachtLocation: map['yachtLocation'] as String? ?? '',
      pricePerDay: (map['pricePerDay'] is num) ? (map['pricePerDay'] as num).toDouble() : 0.0,
      bookingDate: parseBookingDate(map['bookingDate']),
      status: map['status'] as String? ?? 'pending',
      timestamp: map['timestamp'] as Timestamp?,
    );
  }
}
