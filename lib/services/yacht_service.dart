import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/yacht_model.dart';

class YachtService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Future<List<Yacht>> getAllYachts() async {
    final snapshot = await _firestore.collection('yachts').get();

    return snapshot.docs
        .map((doc) => Yacht.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  static Future<void> addYacht(Yacht yacht) async {
    await _firestore.collection('yachts').add(yacht.toMap());
  }

  static Future<void> updateYacht(Yacht yacht) async {
    await _firestore
        .collection('yachts')
        .doc(yacht.id)
        .update(yacht.toMap());
  }

  static Future<void> deleteYacht(String id) async {
    await _firestore.collection('yachts').doc(id).delete();
  }
}
