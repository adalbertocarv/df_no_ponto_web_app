import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../models/pesquisa_linha/pesquisa_linha_model.dart';
import '../../../../services/pesquisa_linha/pesquisa_linha.dart';
import '../../../resultado_linha/resultado_linha.dart';

/// ---------- UTILIDADE (debounce) ----------
class _Debouncer {
  _Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() => _timer?.cancel();
}

/// ---------- WIDGET ----------
class SecaoHero extends StatefulWidget {
  const SecaoHero({super.key});

  @override
  State<SecaoHero> createState() => _SecaoHeroState();
}

class _SecaoHeroState extends State<SecaoHero> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _debouncer = _Debouncer(milliseconds: 400);
  final _service = SugestoesLinha();

  List<LinhaPesquisa> _resultados = [];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _onQueryChanged(String query) async {
    _debouncer.run(() async {
      try {
        final res = await _service.buscarSugestoes(query);
        if (mounted) setState(() => _resultados = res);
      } catch (e) {
        // Caso de erro silencioso – opcionalmente exiba Snackbar/log
        if (mounted) setState(() => _resultados = []);
      }
    });
  }

  // dentro de _SecaoHeroState
  void _selectLine(LinhaPesquisa linha) {
    _controller.text = linha.numero;
    _focusNode.unfocus();
    setState(() => _resultados = []);

    // Navegação ➜ ResultadoLinhaPage
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultadoLinhaPage(numero: linha.numero),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          image: AssetImage('assets/images/brasilia.png'),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo de busca
              Container(
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
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(fontSize: 16),
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
                  onChanged: _onQueryChanged,
                ),
              ),
              // Lista de resultados
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: _resultados.isEmpty ? 0 : 250,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (_resultados.isNotEmpty)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: _resultados.isEmpty
                    ? const SizedBox.shrink()
                    : ListView.separated(
                  itemCount: _resultados.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (_, i) {
                    final linha = _resultados[i];
                    return ListTile(
                      title: Text(
                        '${linha.numero} - ${linha.descricao}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        linha.sentido,
                        style:
                        TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      onTap: () => _selectLine(linha),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
