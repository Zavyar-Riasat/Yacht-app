import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestYachtsScreen extends StatelessWidget {
  const TestYachtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Yachts')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('yachts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final yachts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: yachts.length,
            itemBuilder: (context, index) {
              final yacht = yachts[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(yacht['name'] ?? 'No Name'),
                subtitle: Text('Type: ${yacht['type'] ?? 'Unknown'}'),
              );
            },
          );
        },
      ),
    );
  }
}
