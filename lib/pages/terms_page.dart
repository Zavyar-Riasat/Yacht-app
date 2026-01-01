import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/home_screen.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _saving = false;

  Future<void> _acceptTerms() async {
    setState(() => _saving = true);
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'acceptedTerms': true,
      });
    } catch (e) {
      // If update fails, create or set the field
      await _firestore.collection('users').doc(user.uid).set({
        'acceptedTerms': true,
      }, SetOptions(merge: true));
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Terms & Conditions'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 8),
                    Text(
                      'Please read and accept the Terms & Conditions to continue.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Terms & Conditions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Only admin can approve yacht bookings.',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '2. Booking remains pending until admin approval.',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '3. User can cancel booking before approval.',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '4. Admin decisions are final.',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'By clicking "Accept" you agree to these terms. You will be redirected to the app.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: _saving ? null : _acceptTerms,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: _saving
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Accept', style: TextStyle(fontSize: 16,color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
