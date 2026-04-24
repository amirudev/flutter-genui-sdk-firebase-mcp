import 'package:flutter/material.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/category_selector.dart';
import '../widgets/listing_card.dart';
import '../models/product.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const custom.AirbnbSearchBar(),
            const CategorySelector(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: mockProducts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: ListingCard(product: mockProducts[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
