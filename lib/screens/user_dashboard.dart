import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/booking_service.dart';
import '../models/booking_model.dart';
import 'package:intl/intl.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Shouldn't happen; redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final uid = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: BookingService().getUserBookings(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('You have no bookings yet', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Book a yacht to see it here.'),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              final dateStr = DateFormat.yMMMd().format(b.bookingDate);

              Color badgeColor;
              if (b.status == 'approved') {
                badgeColor = Colors.green;
              } else if (b.status == 'rejected') {
                badgeColor = Colors.red;
              } else {
                badgeColor = Colors.orange;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      b.yachtImage.isNotEmpty ? b.yachtImage : '',
                      width: 84,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 84,
                        height: 64,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(b.yachtName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(b.yachtLocation),
                      const SizedBox(height: 4),
                      Text('PKR ${b.pricePerDay.toStringAsFixed(0)}/day', style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 6),
                      Text('Booking Date: $dateStr', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: badgeColor.withAlpha((0.15 * 255).round()), borderRadius: BorderRadius.circular(8)),
                    child: Text(b.status.toUpperCase(), style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold)),
                  ),
                  onTap: () {
                    // Show details modal
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(b.yachtName),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(b.yachtImage, width: double.infinity, height: 160, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
                            const SizedBox(height: 8),
                            Text('Location: ${b.yachtLocation}'),
                            const SizedBox(height: 6),
                            Text('Price: PKR ${b.pricePerDay.toStringAsFixed(0)}/day'),
                            const SizedBox(height: 8),
                            Text('Booking Date: $dateStr'),
                            const SizedBox(height: 8),
                            Text('Status: ${b.status}'),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
