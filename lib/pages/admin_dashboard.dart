import 'package:flutter/material.dart';
import '../models/yacht_model.dart';
import '../services/yacht_service.dart';
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
  int _currentIndex = 0;
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

  void verifyAdmin() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

      final role = await AuthService().getUserRole(user.uid);
      if (role != 'admin') {
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

  Widget yachtsPage() {
    final isLargeScreen = MediaQuery.of(context).size.width > 768;

    return FutureBuilder<List<Yacht>>(
      future: yachtsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  "Error loading yachts",
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_boat, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No yachts available",
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        } else {
          final yachts = snapshot.data!;
          return Container(
            padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
            child: ListView.builder(
              itemCount: yachts.length,
              itemBuilder: (context, index) {
                final yacht = yachts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Yacht Image
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          image: yacht.imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(yacht.imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.grey[200],
                        ),
                        child: yacht.imageUrl.isEmpty
                            ? Center(
                                child: Icon(
                                  Icons.directions_boat,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                              )
                            : null,
                      ),

                      // Yacht Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      yacht.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '\$${yacht.pricePerDay.toStringAsFixed(0)}/day',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.teal[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      yacht.location,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Capacity: ${yacht.capacity} people',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Action Buttons (Visible!)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            // Edit Button
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditYachtPage(yacht: yacht),
                                    ),
                                  );
                                  refreshList();
                                },
                                icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Delete Button
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Yacht'),
                                      content: Text(
                                          'Are you sure you want to delete "${yacht.name}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await YachtService.deleteYacht(yacht.id);
                                    refreshList();
                                  }
                                },
                                icon: const Icon(Icons.delete, size: 20, color: Colors.white),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Yachts Management' : 'Bookings',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person, size: 18, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'User View',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
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
 
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_boat),
              label: 'Yachts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Bookings',
            ),
          ],
          backgroundColor: Colors.white,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}