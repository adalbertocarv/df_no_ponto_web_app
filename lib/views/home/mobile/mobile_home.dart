import 'dart:async';
import 'package:df_no_ponto_web_app/views/home/mobile/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/pesquisa_linha/pesquisa_linha_model.dart';
import '../../../../services/pesquisa_linha/pesquisa_linha.dart';
import '../../../providers/favoritos.dart';
import '../../resultado_linha/resultado_linha.dart';
import '../widgets/campo_busca_linha.dart';               // widget com animação + botão "×"
import 'widgets/bottom_navigation.dart';
import 'widgets/item_favoritos.dart';
import 'widgets/card_noticias.dart';

/// ---------------- debounce ----------------
class _Debouncer {
  _Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _t;
  void run(VoidCallback action) {
    _t?.cancel();
    _t = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() => _t?.cancel();
}

/// ---------------- página ----------------
class MobileHome extends StatefulWidget {
  const MobileHome({super.key});

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  final _txt = TextEditingController();
  final _focus = FocusNode();
  final _debouncer = _Debouncer(milliseconds: 350);
  final _service = SugestoesLinha();

  List<LinhaPesquisa> _sugestoes = [];
  bool _carregandoPesquisa = false;
  String _ultimaQuery = '';
  String? _mensagemErro;

  @override
  void dispose() {
    _debouncer.dispose();
    _txt.dispose();
    _focus.dispose();
    super.dispose();
  }

  /* ------------ busca / seleção ------------ */
  void _buscar(String q) {
    // Atualiza a query atual
    _ultimaQuery = q;

    if (q.isEmpty) {
      if (mounted) {
        setState(() {
          _sugestoes = [];
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
      // Verifica se a query ainda é a mesma (evita race condition)
      if (_ultimaQuery != q) return;

      try {
        final res = await _service.buscarSugestoes(q);

        // Verifica novamente se a query ainda é a mesma
        if (mounted && _ultimaQuery == q) {
          setState(() {
            _sugestoes = res;
            _carregandoPesquisa = false;
            _mensagemErro = null;
          });
        }
      } on NetworkException catch (e) {
        if (mounted && _ultimaQuery == q) {
          setState(() {
            _sugestoes = [];
            _carregandoPesquisa = false;
            _mensagemErro = 'Sem conexão com a internet.\nVerifique sua conexão.';
          });
        }
      } on ServerException catch (e) {
        if (mounted && _ultimaQuery == q) {
          setState(() {
            _sugestoes = [];
            _carregandoPesquisa = false;
            _mensagemErro = e.statusCode == 429
                ? 'Muitas buscas realizadas.\nTente novamente em alguns instantes.'
                : 'Serviço temporariamente indisponível.\nTente novamente mais tarde.';
          });
        }
      } on TimeoutException catch (e) {
        if (mounted && _ultimaQuery == q) {
          setState(() {
            _sugestoes = [];
            _carregandoPesquisa = false;
            _mensagemErro = 'A busca demorou mais que o esperado.\nTente novamente.';
          });
        }
      } on DataParsingException catch (e) {
        if (mounted && _ultimaQuery == q) {
          setState(() {
            _sugestoes = [];
            _carregandoPesquisa = false;
            _mensagemErro = 'Erro ao processar dados.\nTente novamente.';
          });
        }
      } catch (e) {
        if (mounted && _ultimaQuery == q) {
          setState(() {
            _sugestoes = [];
            _carregandoPesquisa = false;
            _mensagemErro = 'Erro inesperado.\nTente novamente mais tarde.';
          });
        }
      }
    });
  }

  void _selectLine(LinhaPesquisa l) {
    _txt.text = l.numero;
    _focus.unfocus();
    setState(() {
      _sugestoes = [];
      _carregandoPesquisa = false;
      _ultimaQuery = '';
      _mensagemErro = null;
    });
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultadoLinhaPage(numero: l.numero)),
    );
  }

  /* ------------ UI ------------ */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: Colors.grey[200],
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildContent(),
          if (_shouldShowOverlay()) _buildOverlay(),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(context),
    );
  }

  bool _shouldShowOverlay() {
    return _carregandoPesquisa || _sugestoes.isNotEmpty || _mensagemErro != null;
  }

  /* ----- appbar ----- */
  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: Colors.grey[200],
    elevation: 0,
    leading: Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu, color: Colors.grey),
        onPressed: () {
          Scaffold.of(context).openDrawer(); // Agora vai funcionar
        },
      ),
    ),
    title: Image.asset('assets/images/logo.png', height: 60),
    centerTitle: true,
  );

  /* ----- corpo principal ----- */
  Widget _buildContent() {
    return Column(
      children: [
        // busca
        Padding(
          padding: const EdgeInsets.all(16),
          child: CampoBuscaLinha(
            onQueryChanged: _buscar,
          ),
        ),
        const SizedBox(height: 24),

        // favoritos título
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Favoritos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // favoritos lista dinâmica
        Expanded(
          child: Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, _) {
              final favoritos = favoritesProvider.favorites;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: favoritos.isEmpty
                      ? [
                    const Text(
                      textAlign: TextAlign.center,
                      'Salve suas linhas favoritas \n para exibir elas aqui.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                  ]
                      : favoritos.map((linha) {
                    final numero = linha['numero'] ?? '';
                    final descricao = linha['descricao'] ?? '';

                    return Column(
                      children: [
                        buildFavoriteItem(
                          numero: numero,
                          descricao: descricao,
                          isFavorited: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ResultadoLinhaPage(numero: numero),
                              ),
                            );
                          },
                          onRemove: () {
                            favoritesProvider.removeFavorite(numero);
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                )
              );
            },
          ),
        ),

        // notícias
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'NOTÍCIAS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fique por dentro',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              buildNewsCard(),
            ],
          ),
        ),
      ],
    );
  }

  /* ----- overlay de sugestões ----- */
  Widget _buildOverlay() {
    final width = MediaQuery.of(context).size.width - 32;
    final top = MediaQuery.of(context).padding.top +
        kToolbarHeight +
        16; // margin search

    return Positioned(
      top: top,
      left: 16,
      width: width,
      child: Material(
        elevation: 6,
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 250,
          child: _buildOverlayContent(),
        ),
      ),
    );
  }

  Widget _buildOverlayContent() {
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
              TextButton.icon(
                onPressed: () {
                  if (_ultimaQuery.isNotEmpty) {
                    _buscar(_ultimaQuery);
                  }
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Tentar novamente'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mostra mensagem se não houver resultados
    if (_sugestoes.isEmpty && _ultimaQuery.isNotEmpty) {
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

    // Mostra lista de sugestões
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, _) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _sugestoes.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (_, i) {
            final linha = _sugestoes[i];
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
                style: const TextStyle(fontWeight: FontWeight.w500),
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
            );
          },
        );
      },
    );
  }
}