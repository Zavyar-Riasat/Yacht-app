import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/yacht_model.dart';

class YachtService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Yacht>> getYachts() {
    return _firestore.collection('yachts').snapshots().map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) => Yacht.fromFirestore(doc.data(), doc.id),
        ).toList();
      },
    );
  }
}
