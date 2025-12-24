import 'package:flutter/material.dart';
import '../models/yacht_model.dart';
import '../services/yacht_service.dart';
import '../widgets/yacht_card.dart';
import '../screens/home_screen.dart';
import 'add_yacht.dart';
import 'edit_yacht.dart';
import 'admin_booking_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<List<Yacht>> yachtsFuture;
  int _currentIndex = 0; // 0 = Yachts, 1 = Bookings
  final Color tealColor = const Color(0xFF1CB5E0);

  @override
  void initState() {
    super.initState();
    yachtsFuture = YachtService.getAllYachts();
    verifyAdmin();
  }

  void refreshList() {
    setState(() {
      yachtsFuture = YachtService.getAllYachts();
    });
  }

  /// Ensure only admin users can stay on this page.
  void verifyAdmin() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

      final role = await AuthService().getUserRole(user.uid);
      if (role != 'admin') {
        // Not an admin — redirect to user home
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access denied: Admins only')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    });
  }

  // Yacht list page
  Widget yachtsPage() {
    return FutureBuilder<List<Yacht>>(
      future: yachtsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No yachts available"));
        } else {
          final yachts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: yachts.length,
            itemBuilder: (context, index) {
              final yacht = yachts[index];
              return Stack(
                children: [
                  YachtCard(
                    name: yacht.name,
                    location: yacht.location,
                    price: yacht.pricePerDay,
                    imageUrl: yacht.imageUrl,
                    onTap: () {},
                  ),
                  Positioned(
                    top: 10,
                    right: 20,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditYachtPage(yacht: yacht),
                              ),
                            );
                            refreshList();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await YachtService.deleteYacht(yacht.id);
                            refreshList();
                          },
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: tealColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.directions_boat, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'User View',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Body changes based on bottom navigation
      body: _currentIndex == 0 ? yachtsPage() : const AdminBookingPage(),

      // Floating button only on Yachts page
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddYachtPage()),
                );
                refreshList();
              },
              backgroundColor: tealColor,
              icon: const Icon(Icons.add),
              label: const Text("Add Yacht"),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom navigation bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
              icon: const Icon(Icons.directions_boat,
                  color: Colors.black87), // Icon color
              label: const Text(
                "Yachts",
                style: TextStyle(color: Colors.black87),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
              icon: const Icon(Icons.receipt_long, color: Colors.black87),
              label: const Text(
                "Bookings",
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
