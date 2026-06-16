import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategorySelector extends StatefulWidget {
  const CategorySelector({super.key});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Trending', 'icon': FontAwesomeIcons.fire},
    {'label': 'Luxury', 'icon': FontAwesomeIcons.gem},
    {'label': 'Tech', 'icon': FontAwesomeIcons.microchip},
    {'label': 'Fashion', 'icon': FontAwesomeIcons.shirt},
    {'label': 'Home', 'icon': FontAwesomeIcons.house},
    {'label': 'Gaming', 'icon': FontAwesomeIcons.gamepad},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 0.5),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 32),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    _categories[index]['icon'],
                    size: 20,
                    color: isSelected ? Colors.black : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _categories[index]['label'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8), // For the border space
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
