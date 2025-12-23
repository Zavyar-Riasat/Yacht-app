import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBookingPage extends StatelessWidget {
  const AdminBookingPage({super.key});

  final Color navyColor = const Color(0xFF0A2540);
  final Color bgColor = const Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    final bookingsCollection = FirebaseFirestore.instance.collection('bookings');

    return Scaffold(
      backgroundColor: bgColor,
    //   appBar: AppBar(
    //     title: const Text("All Bookings", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    //     backgroundColor: navyColor,
    //     centerTitle: true,
    //     iconTheme: const IconThemeData(color: Colors.white),
    //   ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingsCollection.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No bookings found"));
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;

              final bookingDate = (data['bookingDate'] as Timestamp).toDate();
              final startTime = (data['startTime'] as Timestamp).toDate();
              final endTime = (data['endTime'] as Timestamp).toDate();
              final timestamp = (data['timestamp'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Booking ID: ${bookings[index].id}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("User ID: ${data['userId']}"),
                      Text("Yacht ID: ${data['yachtId']}"),
                      const SizedBox(height: 4),
                      Text("Booking Date: $bookingDate"),
                      Text("Start Time: $startTime"),
                      Text("End Time: $endTime"),
                      const SizedBox(height: 4),
                      Text("Total Price: \$${data['totalPrice']}"),
                      Text("Status: ${data['status']}"),
                      const SizedBox(height: 4),
                      Text("Created at: $timestamp",
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
