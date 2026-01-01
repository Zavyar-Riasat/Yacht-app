import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';

class YachtDetailScreen extends StatefulWidget {
  final String id;
  final String name;
  final String? type;
  final String location;
  final int price;
  final String imageUrl;
  final String description;

  const YachtDetailScreen({
    super.key,
    required this.id,
    required this.name,
    this.type,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  @override
  State<YachtDetailScreen> createState() => _YachtDetailScreenState();
}

class _YachtDetailScreenState extends State<YachtDetailScreen> {
  DateTime? startDate;
  DateTime? endDate;
  double totalPrice = 0;
  String userRole = 'user';

  // Custom colors
  final Color navyColor = const Color(0xFF0A2540);
  final Color tealColor = const Color(0xFF1CB5E0);
  final Color bgColor = const Color(0xFFF5F7FA);

  Future<void> pickStartDate() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        startDate = date;
        if (endDate != null && endDate!.isBefore(startDate!)) {
          endDate = null;
        }
        calculateTotalPrice();
      });
    }
  }

  Future<void> pickEndDate() async {
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select start date first")),
      );
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: startDate!.add(const Duration(days: 1)),
      firstDate: startDate!,
      lastDate: startDate!.add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        endDate = date;
        calculateTotalPrice();
      });
    }
  }

  void calculateTotalPrice() {
    if (startDate != null && endDate != null) {
      final days = endDate!.difference(startDate!).inDays + 1;
      totalPrice = days * widget.price.toDouble();
    } else {
      totalPrice = 0;
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          widget.name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: navyColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Full-width image
            Image.network(
              widget.imageUrl,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: navyColor)),
                  const SizedBox(height: 8),
                  if (widget.type != null)
                    Text(widget.type!,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(widget.location,
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Text("Price per day: \$${widget.price}",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: tealColor)),
                  const SizedBox(height: 16),
                  Text(widget.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),

                  // Date Pickers
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: pickStartDate,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: tealColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: Text(
                              startDate == null
                                  ? "Select Start Date"
                                  : formatDate(startDate),
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: pickEndDate,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: tealColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: Text(
                              endDate == null
                                  ? "Select End Date"
                                  : formatDate(endDate),
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),

                  // Total Price
                  if (totalPrice > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Total Price: \$${totalPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: tealColor),
                      ),
                    ),

                  // Book Now Button
                  // Real-time availability check and Book Now
                  StreamBuilder<List<BookingModel>>(
                    stream: BookingService().streamApprovedBookingsForYacht(widget.id),
                    builder: (context, approvedSnap) {
                      bool rangeConflicts = false;
                      if (approvedSnap.hasData && startDate != null && endDate != null) {
                        final approved = approvedSnap.data!;
                        for (final BookingModel b in approved) {
                          final bStart = b.startDate;
                          final bEnd = b.endDate;
                          if (bStart != null && bEnd != null) {
                            if (!(endDate!.isBefore(bStart) || startDate!.isAfter(bEnd))) {
                              rangeConflicts = true;
                              break;
                            }
                          }
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (rangeConflicts)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'This yacht is not available for the selected dates.',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: rangeConflicts
                                  ? null
                                  : () async {
                                // Prevent booking if user is not authenticated
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please login to book')),
                                  );
                                  return;
                                }

                                // Check role; admins are not allowed to book
                                final messenger = ScaffoldMessenger.of(context);
                                final navigator = Navigator.of(context);
                                final role = await AuthService().getUserRole(user.uid);
                                if (role == 'admin') {
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Admins cannot make bookings')),
                                  );
                                  return;
                                }

                                if (startDate == null || endDate == null) {
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Please select start and end dates')),
                                  );
                                  return;
                                }

                                // Final availability check to avoid race condition
                                final available = await BookingService().isYachtAvailable(widget.id, startDate!, endDate!);
                                if (!available) {
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('This yacht is not available for the selected dates.')),
                                  );
                                  return;
                                }

                                // Create booking model and persist, include yacht snapshot fields
                                final booking = BookingModel(
                                  userId: user.uid,
                                  yachtId: widget.id,
                                  yachtName: widget.name,
                                  yachtImage: widget.imageUrl,
                                  yachtLocation: widget.location,
                                  pricePerDay: widget.price.toDouble(),
                                  // Use current time as bookingDate (server timestamp stored separately)
                                  bookingDate: DateTime.now(),
                                  startDate: startDate,
                                  endDate: endDate,
                                  status: 'pending',
                                );

                                try {
                                  await BookingService().createBooking(booking);
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Booking created — pending approval')),
                                  );

                                  if (!mounted) return;
                                  // Navigate to user dashboard to view bookings
                                  navigator.pushReplacementNamed('/user-dashboard');
                                } catch (e) {
                                  messenger.showSnackBar(
                                    SnackBar(content: Text('Booking failed: $e')),
                                  );
                                }
                              },
                              child: const Text('Book Now'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
