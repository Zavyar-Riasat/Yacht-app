import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/admin_dashboard.dart';
import '../models/yacht_model.dart';
import '../screens/yacht_detail_screen.dart';
import '../screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Yacht> yachts = [];
  bool isLoading = true;
  String userRole = 'user'; // default role

  static const Color primaryColor = Color(0xFF0A2540);
  static const Color accentColor = Color(0xFF1CB5E0);
  static const Color bgColor = Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    // Protect route: if not authenticated, send to login
    if (_auth.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return;
    }

    fetchUserRole();
    fetchYachts();
  }

  // 🔹 Fetch current user's role
  Future<void> fetchUserRole() async {
    try {
      final uid = _auth.currentUser!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      setState(() {
        userRole = doc['role'] ?? 'user';
      });
    } catch (e) {
      debugPrint('Error fetching user role: $e');
    }
  }

  // 🔹 Fetch yachts
  Future<void> fetchYachts() async {
    try {
      final snapshot = await _firestore.collection('yachts').get();

      final loadedYachts = snapshot.docs.map((doc) {
        final data = doc.data();
        return Yacht(
          id: doc.id,
          name: data['name'] ?? '',
          location: data['location'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          description: data['description'] ?? '',
          pricePerDay: (data['pricePerDay'] ?? 0).toDouble(),
          capacity: data['capacity'] ?? 0,
          available: data['available'] ?? false,
        );
      }).toList();

      setState(() {
        yachts = loadedYachts;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => isLoading = false);
    }
  }

  // 🔹 Logout
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text(
          'Luxury Yachts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // 🔹 Admin Dashboard button (only for admin)
          if (userRole == 'admin')
            IconButton(
              tooltip: 'Admin Dashboard',
              icon: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
              ),
              onPressed: () async {
                // Double-check role before navigating
                final uid = _auth.currentUser!.uid;
                final doc = await _firestore.collection('users').doc(uid).get();
                if (doc['role'] == 'admin') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboard()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Access denied')),
                  );
                }
              },
            ),

          // 🔹 Logout button
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () => logout(context),
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : yachts.isEmpty
              ? const Center(child: Text('No yachts available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: yachts.length,
                  itemBuilder: (context, index) {
                    final yacht = yachts[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => YachtDetailScreen(
                                id: yacht.id,
                                name: yacht.name,
                                location: yacht.location,
                                imageUrl: yacht.imageUrl,
                                description: yacht.description,
                                price: yacht.pricePerDay.toInt(),
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            // IMAGE
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(16),
                              ),
                              child: Image.network(
                                yacht.imageUrl,
                                width: 120,
                                height: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                ),
                              ),
                            ),

                            // CONTENT
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      yacht.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      yacht.location,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'PKR ${yacht.pricePerDay.toInt()}/day',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: accentColor,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.grey.shade500,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
