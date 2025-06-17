import 'package:flutter/material.dart';

extension IconParser on String {
  IconData toIconData() {
    switch (this) {
      case 'cake': return Icons.cake;
      case 'local_dining': return Icons.local_dining;
      case 'emoji_food_beverage': return Icons.emoji_food_beverage;
      case 'icecream': return Icons.icecream;
      case 'bakery_dining': return Icons.bakery_dining;
      case 'liquor': return Icons.liquor;
      default: return Icons.category;
    }
  }
}