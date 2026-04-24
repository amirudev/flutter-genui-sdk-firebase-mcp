import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          title: data['title'] ?? '',
          location: data['location'] ?? '',
          images: List<String>.from(data['images'] ?? []),
          rating: (data['rating'] ?? 0.0).toDouble(),
          price: (data['price'] ?? 0.0).toDouble(),
          dateRange: data['dateRange'] ?? '',
        );
      }).toList();
    });
  }

  Future<void> seedProducts(List<Product> products) async {
    final batch = _db.batch();
    for (var product in products) {
      final docRef = _db.collection('products').doc(product.id);
      batch.set(docRef, {
        'title': product.title,
        'location': product.location,
        'images': product.images,
        'rating': product.rating,
        'price': product.price,
        'dateRange': product.dateRange,
      });
    }
    await batch.commit();
  }
}
