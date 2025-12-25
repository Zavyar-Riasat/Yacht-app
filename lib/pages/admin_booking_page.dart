import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/booking_service.dart';
import '../models/booking_model.dart';
import 'package:intl/intl.dart';

class AdminBookingPage extends StatelessWidget {
  const AdminBookingPage({super.key});

  final Color navyColor = const Color(0xFF0A2540);
  final Color bgColor = const Color(0xFFF5F7FA);

  Future<String> getUserName(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final data = doc.data();
      if (data != null && data['name'] != null && (data['name'] as String).isNotEmpty) {
        return data['name'] as String;
      }
      return data != null && data['email'] != null ? data['email'] as String : userId;
    } catch (e) {
      return userId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: StreamBuilder<List<BookingModel>>(
        stream: BookingService().getAllBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              final bookingDate = DateFormat.yMMMd().format(b.bookingDate);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking ID: ${b.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      FutureBuilder<String>(
                        future: getUserName(b.userId),
                        builder: (context, userSnap) {
                          final userText = userSnap.data ?? b.userId;
                          return Text('User: $userText');
                        },
                      ),
                      Text('Yacht: ${b.yachtName}'),
                      const SizedBox(height: 6),
                      Text('Booking Date: $bookingDate'),
                      const SizedBox(height: 6),
                      Text('Status: ${b.status}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: b.status == 'approved'
                                ? null
                                : () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    await BookingService().updateBookingStatus(b.id!, 'approved');
                                    messenger.showSnackBar(const SnackBar(content: Text('Booking approved')));
                                  },
                            child: const Text('Approve'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: b.status == 'rejected'
                                ? null
                                : () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    await BookingService().updateBookingStatus(b.id!, 'rejected');
                                    messenger.showSnackBar(const SnackBar(content: Text('Booking rejected')));
                                  },
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
