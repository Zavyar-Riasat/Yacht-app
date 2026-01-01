import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/booking_model.dart';
import '../services/booking_service.dart';
import 'booking_detail_screen.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final uid = user.uid;
    final isWide = MediaQuery.of(context).size.width >= 700;

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
            return const _EmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 12,
              vertical: 12,
            ),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return _BookingCard(
                booking: bookings[index],
                isWide: isWide,
              );
            },
          );
        },
      ),
    );
  }
}

/* ---------------- BOOKING CARD ---------------- */

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isWide;

  const _BookingCard({
    required this.booking,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd().format(booking.bookingDate);

    final statusColor = booking.status == 'approved'
        ? Colors.green
        : booking.status == 'rejected'
            ? Colors.red
            : Colors.orange;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingDetailScreen(booking: booking),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _YachtImage(imageUrl: booking.yachtImage),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.yachtName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      booking.yachtLocation,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'PKR ${booking.pricePerDay.toStringAsFixed(0)} / day',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Booked on $dateStr',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: statusColor.withAlpha((0.12 * 255).round()),
                side: BorderSide(color: statusColor.withAlpha((0.4 * 255).round())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------- IMAGE ---------------- */

class _YachtImage extends StatelessWidget {
  final String imageUrl;

  const _YachtImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 90,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 90,
          height: 80,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported),
        ),
      ),
    );
  }
}

/* ---------------- EMPTY STATE ---------------- */

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.sailing, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No bookings yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Book a yacht and your bookings will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
