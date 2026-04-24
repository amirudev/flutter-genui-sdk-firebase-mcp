class Product {
  final String id;
  final String title;
  final String location;
  final List<String> images;
  final double rating;
  final double price;
  final String dateRange;

  Product({
    required this.id,
    required this.title,
    required this.location,
    required this.images,
    required this.rating,
    required this.price,
    required this.dateRange,
  });
}

final List<Product> mockProducts = [
  Product(
    id: '1',
    title: 'Modern Minimalist Watch',
    location: 'Design Quarter',
    images: ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800'],
    rating: 4.85,
    price: 120.0,
    dateRange: 'Oct 24 – 29',
  ),
  Product(
    id: '2',
    title: 'Wireless Over-Ear Headphones',
    location: 'Audio Tech Hub',
    images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800'],
    rating: 4.92,
    price: 250.0,
    dateRange: 'Nov 1 – 6',
  ),
  Product(
    id: '3',
    title: 'Mechanical Keyboard (RGB)',
    location: 'Gamer Street',
    images: ['https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=800'],
    rating: 4.75,
    price: 85.0,
    dateRange: 'Oct 15 – 20',
  ),
  Product(
    id: '4',
    title: 'Premium Leather Sneakers',
    location: 'Fashion Avenue',
    images: ['https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800'],
    rating: 4.80,
    price: 145.0,
    dateRange: 'Dec 5 – 10',
  ),
  Product(
    id: '5',
    title: 'Vintage Film Camera',
    location: 'Artist Corner',
    images: ['https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800'],
    rating: 4.65,
    price: 320.0,
    dateRange: 'Sep 10 – 15',
  ),
  Product(
    id: '6',
    title: 'Minimalist Canvas Backpack',
    location: 'Traveler Hub',
    images: ['https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800'],
    rating: 4.70,
    price: 65.0,
    dateRange: 'Oct 1 – 5',
  ),
  Product(
    id: '7',
    title: 'Portable Bluetooth Speaker',
    location: 'Audio Tech Hub',
    images: ['https://images.unsplash.com/photo-1608156639585-b3a032ef9689?w=800'],
    rating: 4.88,
    price: 45.0,
    dateRange: 'Nov 12 – 17',
  ),
  Product(
    id: '8',
    title: 'Smart LED Desk Lamp',
    location: 'Workplace Essentials',
    images: ['https://images.unsplash.com/photo-1534073828943-f801091bb18c?w=800'],
    rating: 4.55,
    price: 35.0,
    dateRange: 'Oct 20 – 25',
  ),
];
