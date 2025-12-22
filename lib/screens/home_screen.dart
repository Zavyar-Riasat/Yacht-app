import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/yacht_card.dart';
import 'yacht_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Responsive grid columns
    int crossAxisCount = 1;
    if (width > 600) crossAxisCount = 2;
    if (width > 1000) crossAxisCount = 3;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffa1c4fd), Color(0xffc2e9fb)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                "Luxury Yachts",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('yachts')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text(
                        "No yachts available",
                        style: TextStyle(color: Colors.white),
                      ));
                    }

                    final yachts = snapshot.data!.docs;

                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: yachts.length,
                      itemBuilder: (context, index) {
                        final data =
                            yachts[index].data() as Map<String, dynamic>;

                        return YachtCard(
                          name: data['name'] ?? 'No Name',
                          type: data['type'] ?? 'Unknown',
                          location: data['location'] ?? 'Unknown',
                          price: (data['pricePerDay'] ?? 0).toInt(),
                          imageUrl:
                              data['imageUrl'] ?? 'https://picsum.photos/500/300',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => YachtDetailScreen(
                                  name: data['name'] ?? 'No Name',
                                  type: data['type'] ?? 'Unknown',
                                  location: data['location'] ?? 'Unknown',
                                  price: (data['pricePerDay'] ?? 0).toInt(),
                                  imageUrl: data['imageUrl'] ??
                                      'https://picsum.photos/500/300',
                                  description: data['description'] ??
                                      'Luxury yacht with premium facilities.',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
