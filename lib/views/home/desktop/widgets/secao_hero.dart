import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/pesquisa_linha/pesquisa_linha_model.dart';
import '../../../../providers/favoritos.dart';
import '../../../../services/pesquisa_linha/pesquisa_linha.dart';
import '../../../resultado_linha/resultado_linha.dart';
import '../../widgets/campo_busca_linha.dart';

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
  bool _carregandoPesquisa = false;
  String? _mensagemErro;
  String _ultimaQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _onQueryChanged(String query) async {
    _ultimaQuery = query;

    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _resultados = [];
          _carregandoPesquisa = false;
          _mensagemErro = null;
        });
      }
      return;
    }

    // Mostra loading imediatamente
    if (mounted) {
      setState(() {
        _carregandoPesquisa = true;
        _mensagemErro = null;
      });
    }

    _debouncer.run(() async {
      // Verifica se a query ainda é a mesma
      if (_ultimaQuery != query) return;

      try {
        final res = await _service.buscarSugestoes(query);

        if (mounted && _ultimaQuery == query) {
          setState(() {
            _resultados = res;
            _carregandoPesquisa = false;
            _mensagemErro = null;
          });
        }
      } on NetworkException catch (e) {
        if (mounted && _ultimaQuery == query) {
          setState(() {
            _resultados = [];
            _carregandoPesquisa = false;
            _mensagemErro = 'Sem conexão com a internet.\nVerifique sua conexão.';
          });
        }
      } on ServerException catch (e) {
        if (mounted && _ultimaQuery == query) {
          setState(() {
            _resultados = [];
            _carregandoPesquisa = false;
            _mensagemErro = e.statusCode == 429
                ? 'Muitas buscas realizadas.\nTente novamente em alguns instantes.'
                : 'Serviço temporariamente indisponível.\nTente novamente mais tarde.';
          });
        }
      } on TimeoutException catch (e) {
        if (mounted && _ultimaQuery == query) {
          setState(() {
            _resultados = [];
            _carregandoPesquisa = false;
            _mensagemErro = 'A busca demorou mais que o esperado.\nTente novamente.';
          });
        }
      } on DataParsingException catch (e) {
        if (mounted && _ultimaQuery == query) {
          setState(() {
            _resultados = [];
            _carregandoPesquisa = false;
            _mensagemErro = 'Erro ao processar dados.\nTente novamente.';
          });
        }
      } catch (e) {
        if (mounted && _ultimaQuery == query) {
          setState(() {
            _resultados = [];
            _carregandoPesquisa = false;
            _mensagemErro = 'Erro inesperado.\nTente novamente mais tarde.';
          });
        }
      }
    });
  }

  void _selectLine(LinhaPesquisa linha) {
    _controller.text = linha.numero;
    _focusNode.unfocus();
    setState(() {
      _resultados = [];
      _carregandoPesquisa = false;
      _mensagemErro = null;
      _ultimaQuery = '';
    });

    // Navegação ➜ ResultadoLinhaPage
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultadoLinhaPage(numero: linha.numero),
      ),
    );
  }

  void _tentarNovamente() {
    if (_ultimaQuery.isNotEmpty) {
      _onQueryChanged(_ultimaQuery);
    }
  }

  bool _shouldShowResults() {
    return _carregandoPesquisa || _resultados.isNotEmpty || _mensagemErro != null;
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
            const Color(0xFF4A6FA5).withValues(alpha:0.8),
            const Color(0xFF354F7A).withValues(alpha:0.8),
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
                      color: Colors.black.withValues(alpha:0.1),
                      spreadRadius: 2,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CampoBuscaLinha(
                  onQueryChanged: _onQueryChanged,
                ),
              ),
              // Lista de resultados
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: _shouldShowResults() ? 250 : 0,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (_shouldShowResults())
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: !_shouldShowResults()
                    ? const SizedBox.shrink()
                    : _buildResultsContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsContent() {
    // Mostra loading
    if (_carregandoPesquisa) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 12),
            Text(
              'Buscando linhas...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Mostra erro se houver
    if (_mensagemErro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              Text(
                _mensagemErro!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _tentarNovamente,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mostra mensagem se não houver resultados
    if (_resultados.isEmpty && _ultimaQuery.isNotEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              'Nenhuma linha encontrada',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tente outro termo de busca',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // Mostra lista de resultados com funcionalidade de favoritos
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, _) {
        return ListView.separated(
          itemCount: _resultados.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (_, i) {
            final linha = _resultados[i];
            final numero = linha.numero;
            final descricao = linha.descricao;
            final isFavorited = favoritesProvider.isFavorite(numero);

            return ListTile(
              leading: const Icon(
                Icons.directions_bus,
                color: Colors.blue,
                size: 20,
              ),
              title: Text(
                '$numero - $descricao',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Tarifa: R\$${linha.tarifa.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? Colors.red : Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  if (isFavorited) {
                    favoritesProvider.removeFavorite(numero);
                  } else {
                    favoritesProvider.addFavorite({
                      'numero': numero,
                      'descricao': descricao,
                    });
                  }
                },
              ),
              onTap: () => _selectLine(linha),
              dense: true,
              hoverColor: Colors.blue.withValues(alpha:0.05),
            );
          },
        );
      },
    );
  }
}