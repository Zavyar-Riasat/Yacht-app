import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class YachtDetailScreen extends StatefulWidget {
  final String name;
  final String type;
  final String location;
  final int price;
  final String imageUrl;
  final String description;

  const YachtDetailScreen({
    super.key,
    required this.name,
    required this.type,
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

  // Pick start date
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

  // Pick end date
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

  // Calculate total price based on days
  void calculateTotalPrice() {
    if (startDate != null && endDate != null) {
      final days = endDate!.difference(startDate!).inDays + 1;
      totalPrice = days * widget.price.toDouble();
    } else {
      totalPrice = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              widget.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.type),
                  const SizedBox(height: 4),
                  Text(widget.location),
                  const SizedBox(height: 16),
                  Text("Price per day: \$${widget.price}",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  const SizedBox(height: 16),
                  Text(widget.description),
                  const SizedBox(height: 24),

                  // Date Pickers
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: pickStartDate,
                        child: Text(startDate == null
                            ? "Select Start Date"
                            : "${startDate!.day}-${startDate!.month}-${startDate!.year}"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: pickEndDate,
                        child: Text(endDate == null
                            ? "Select End Date"
                            : "${endDate!.day}-${endDate!.month}-${endDate!.year}"),
                      ),
                    ],
                  ),

                  // Total Price
                  if (totalPrice > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Total Price: \$${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (startDate == null || endDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Please select start and end dates")),
                          );
                          return;
                        }

                        Booking myBooking = Booking(
                          userId: "user_001", // replace with actual user ID
                          yachtId: widget.name, // replace with actual yacht ID
                          bookingDate: startDate!,
                          startTime: startDate!,
                          endTime: endDate!,
                          totalPrice: totalPrice,
                          status: "pending",
                        );

                        try {
                          await BookingService().addBooking(myBooking);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Booking added successfully!")),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Booking failed: $e")),
                          );
                        }
                      },
                      child: const Text("Book Now"),
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
