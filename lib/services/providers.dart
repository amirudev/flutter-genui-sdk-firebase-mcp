import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import 'firestore_service.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getProducts();
});
