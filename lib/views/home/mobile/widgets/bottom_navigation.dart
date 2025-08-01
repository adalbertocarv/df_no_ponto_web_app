import 'package:flutter/material.dart';

Widget buildBottomNavigationBar() {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF4A6FA5),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF4A6FA5),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_outline),
          label: '',
        ),
      ],
    ),
  );
}
