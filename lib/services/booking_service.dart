import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';

class BookingService {
  final CollectionReference bookings =
      FirebaseFirestore.instance.collection('bookings');

  /// Create booking document in Firestore. Sets server timestamp if not provided.
  Future<void> createBooking(BookingModel booking) async {
    final map = booking.toMap();
    // Ensure the booking is always attributed to the currently authenticated user
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid != null) {
      map['userId'] = currentUid;
    }
    // Always set server timestamp to avoid null timestamps
    map['timestamp'] = FieldValue.serverTimestamp();
    await bookings.add(map);
  }

  /// Stream of bookings for a given user id (uid).
  ///
  /// Some older booking documents may store the user's email in the
  /// 'userId' field (legacy). To handle both cases, optionally provide
  /// `userEmail`. When both `userId` and `userEmail` are provided the
  /// query uses `whereIn` to match either value.
  Stream<List<BookingModel>> getUserBookings(String userId) {
    // Query by userId only (no orderBy) so documents without a server
    // 'timestamp' (legacy or just-written) are still returned. We sort
    // client-side by the timestamp (falling back to bookingDate) so the
    // StreamBuilder receives immediate results and documents don't disappear
    // while the server timestamp is being resolved.
    final q = bookings.where('userId', isEqualTo: userId);
    return q.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => BookingModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();

      list.sort((a, b) {
        final aMillis = a.timestamp?.toDate().millisecondsSinceEpoch ?? a.bookingDate.millisecondsSinceEpoch;
        final bMillis = b.timestamp?.toDate().millisecondsSinceEpoch ?? b.bookingDate.millisecondsSinceEpoch;
        return bMillis.compareTo(aMillis); // descending
      });

      return list;
    });
  }

  /// Stream of all bookings (for admin)
  Stream<List<BookingModel>> getAllBookings() {
    // Return all bookings stream; sort client-side to include docs without server timestamps.
    final q = bookings;
    return q.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => BookingModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();

      list.sort((a, b) {
        final aMillis = a.timestamp?.toDate().millisecondsSinceEpoch ?? a.bookingDate.millisecondsSinceEpoch;
        final bMillis = b.timestamp?.toDate().millisecondsSinceEpoch ?? b.bookingDate.millisecondsSinceEpoch;
        return bMillis.compareTo(aMillis);
      });

      return list;
    });
  }

  /// Update booking status to 'approved' or 'rejected' etc.
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await bookings.doc(bookingId).update({'status': status});
  }
}
