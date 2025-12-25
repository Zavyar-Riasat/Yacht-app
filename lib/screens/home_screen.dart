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
  List<Yacht> filteredYachts = [];
  bool isLoading = true;
  String userRole = 'user';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser == null) {
      final navigator = Navigator.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return;
    }

    fetchUserRole();
    fetchYachts();
    searchController.addListener(_onSearchChanged);
  }

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
        filteredYachts = List.from(loadedYachts);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged() {
    final q = searchController.text.trim();
    if (q.isEmpty) {
      setState(() => filteredYachts = List.from(yachts));
      return;
    }

    final lower = q.toLowerCase();
    setState(() {
      filteredYachts = yachts
          .where((y) =>
              y.location.toLowerCase().contains(lower) ||
              y.name.toLowerCase().contains(lower))
          .toList();
    });
  }

  Future<void> logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    await _auth.signOut();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: const Text(
          'Luxury Yachts',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          if (userRole == 'admin')
            IconButton(
              tooltip: 'Admin Dashboard',
              icon: const Icon(Icons.dashboard, color: Colors.white),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final uid = _auth.currentUser!.uid;
                final doc =
                    await _firestore.collection('users').doc(uid).get();
                if (!mounted) return;
                if (doc['role'] == 'admin') {
                  navigator.push(
                    MaterialPageRoute(builder: (_) => const AdminDashboard()),
                  );
                } else {
                  messenger.showSnackBar(
                      const SnackBar(content: Text('Access denied')));
                }
              },
            ),
          if (userRole == 'user')
            IconButton(
              tooltip: 'My Dashboard',
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/user-dashboard');
              },
            ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : yachts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_boat,
                          size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No yachts available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search Bar
                    Container(
                      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                      color: Colors.white,
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by location or yacht name...',
                          prefixIcon: const Icon(Icons.search,
                              color: Colors.teal),
                          suffixIcon: searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.grey),
                                  onPressed: () {
                                    searchController.clear();
                                  },
                                ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Yacht Count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Yachts (${filteredYachts.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          if (filteredYachts.isEmpty)
                            TextButton.icon(
                              onPressed: fetchYachts,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Refresh'),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Yacht List/Grid
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 20 : 16,
                          vertical: 8,
                        ),
                        child: isLargeScreen && filteredYachts.length > 1
                            ? _gridView()
                            : _listView(),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _listView() {
    return ListView.builder(
      itemCount: filteredYachts.length,
      itemBuilder: (context, index) {
        final yacht = filteredYachts[index];
        return _yachtCard(yacht);
      },
    );
  }

  Widget _gridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.4,
      ),
      itemCount: filteredYachts.length,
      itemBuilder: (context, index) {
        final yacht = filteredYachts[index];
        return _yachtCard(yacht, isGrid: true);
      },
    );
  }

  Widget _yachtCard(Yacht yacht, {bool isGrid = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                yacht.imageUrl,
                height: isGrid ? 340 : 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: isGrid ? 140 : 160,
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      Icons.directions_boat,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: isGrid ? 140 : 160,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.teal),
                    ),
                  );
                },
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    yacht.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          yacht.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${yacht.pricePerDay.toInt()}/day',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: yacht.available
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          yacht.available ? 'Available' : 'Booked',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: yacht.available ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
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