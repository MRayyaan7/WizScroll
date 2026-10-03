import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quote.dart';

/// Service layer for reading quotes from Cloud Firestore.
///
/// Queries the `quotes` collection filtered to [active == true],
/// ordered by [createdAt] ascending.
class QuoteService {
  QuoteService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Returns a real-time stream of active quotes.
  Stream<List<Quote>> watchActiveQuotes() {
    return _firestore
        .collection('quotes')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Quote.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// One-shot fetch of active quotes (useful for initial load / pagination).
  Future<List<Quote>> fetchActiveQuotes() async {
    final snapshot = await _firestore
        .collection('quotes')
        .where('active', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Quote.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
