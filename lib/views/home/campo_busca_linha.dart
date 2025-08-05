import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class CampoBuscaLinha extends StatefulWidget {
  const CampoBuscaLinha({
    super.key,
    required this.onQueryChanged,
  });

  final ValueChanged<String> onQueryChanged;

  @override
  State<CampoBuscaLinha> createState() => _CampoBuscaLinhaState();
}

class _CampoBuscaLinhaState extends State<CampoBuscaLinha> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  // exemplos que aparecerão um após o outro
  static const _exemplos = [
    'Digite a linha que deseja consultar',
    'ex: 0.110',
    'ex: 0.898',
    'ex: 128.1',
    'ex: Gama',
    'ex: Taguatinga Sul',
  ];

  int _index = 0;
  Timer? _trocaTimer;

  @override
  void initState() {
    super.initState();

    // troca o exemplo a cada 4 s
    _trocaTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _exemplos.length);
    });

    // rebuilda para esconder/mostrar animação
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _trocaTimer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // ----------- HINT ANIMADO (só quando vazio) -----------
          if (_controller.text.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 56, right: 56),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
                child: AnimatedTextKit(
                  key: ValueKey(_index), // reinicia animação quando muda
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      _exemplos[_index],
                      speed: const Duration(milliseconds: 80),
                    ),
                  ],
                ),
              ),
            ),

          // ----------------- TEXTFIELD REAL -----------------
          TextField(
            controller: _controller,
            focusNode: _focus,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              // sem hintText aqui!
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              border: InputBorder.none,
              // botão “×”
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  _controller.clear();
                  widget.onQueryChanged('');
                  _focus.requestFocus();
                },
              ),
            ),
            onChanged: widget.onQueryChanged,
          ),
        ],
      ),
    );
  }
}
