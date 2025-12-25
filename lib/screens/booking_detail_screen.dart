import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd().format(booking.bookingDate);

    Color badgeColor;
    if (booking.status == 'approved') {
      badgeColor = Colors.green;
    } else if (booking.status == 'rejected') {
      badgeColor = Colors.red;
    } else {
      badgeColor = Colors.orange;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                booking.yachtImage,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported, size: 64),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(booking.yachtName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(booking.yachtLocation, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            Text('PKR ${booking.pricePerDay.toStringAsFixed(0)}/day', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: badgeColor.withAlpha((0.15 * 255).round()), borderRadius: BorderRadius.circular(8)),
                  child: Text(booking.status.toUpperCase(), style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text('Booking Date: $dateStr', style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 24),
            if (booking.status == 'pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Cancel booking?'),
                        content: const Text('Are you sure you want to cancel this booking?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('No')),
                          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Yes')),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        await BookingService().cancelBooking(booking.id!);
                        messenger.showSnackBar(const SnackBar(content: Text('Booking cancelled')));
                        navigator.pop();
                      } catch (e) {
                        messenger.showSnackBar(SnackBar(content: Text('Cancel failed: $e')));
                      }
                    }
                  },
                  child: const Text('Cancel Booking'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
