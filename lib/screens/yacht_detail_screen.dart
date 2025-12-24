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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Prevent booking if user is not authenticated
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please login to book')),
                          );
                          return;
                        }

                        // Check role; admins are not allowed to book
                        final role = await AuthService().getUserRole(user.uid);
                        if (role == 'admin') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Admins cannot make bookings')),
                          );
                          return;
                        }

                        if (startDate == null || endDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select start and end dates')),
                          );
                          return;
                        }

                        final email = user.email ?? 'unknown@example.com';

                        // Create Booking
                        Booking myBooking = Booking(
                          userEmail: email,
                          yachtName: widget.name,
                          bookingDate: startDate!,
                          startTime: startDate!,
                          endTime: endDate!,
                          totalPrice: totalPrice,
                          status: 'pending',
                        );

                        try {
                          await BookingService().addBooking(myBooking);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Booking added successfully!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Booking failed: $e')),
                          );
                        }
                      },
                      child: const Text('Book Now'),
                    ),
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
