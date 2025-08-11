import 'package:flutter/material.dart';

Widget buildBottomNavigationBar({
  required int currentIndex,
  required Function(int) onTap,
}) {
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
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon:                   const Image(
            image: AssetImage('assets/images/icon_bus.png'),
            width: 20,
            height: 20,
          ),
          tooltip: 'Pesquisar Linhas',
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          tooltip: 'Veículos em Operação',
          label: '',
        ),
      ],
    ),
  );
}

