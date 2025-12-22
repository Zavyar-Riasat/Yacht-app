import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  final CollectionReference bookings =
      FirebaseFirestore.instance.collection('bookings');

  Future<void> addBooking(Booking booking) async {
    Map<String, dynamic> bookingMap = booking.toMap();
    bookingMap['timestamp'] ??= FieldValue.serverTimestamp();
    await bookings.add(bookingMap);
  }
}
