import 'package:flutter/material.dart';

Widget buildHeroSection(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.6,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF4A6FA5).withOpacity(0.8),
          const Color(0xFF354F7A).withOpacity(0.8),
        ],
      ),
      image: const DecorationImage(
        image: AssetImage('/images/brasilia.png'),
        fit: BoxFit.fitWidth,
        colorFilter: ColorFilter.mode(
          Colors.black26,
          BlendMode.darken,
        ),
      ),
    ),
    child: Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Digite a linha que deseja consultar',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    ),
  );
}
