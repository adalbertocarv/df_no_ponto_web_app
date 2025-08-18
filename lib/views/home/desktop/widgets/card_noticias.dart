import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../services/noticias/noticias.dart';
import '../../../../services/noticias/noticia_imagem.dart';

class NoticiasDesktop extends StatefulWidget {
  const NoticiasDesktop({super.key});

  @override
  State<NoticiasDesktop> createState() => _NoticiasDesktopState();
}

class _NoticiasDesktopState extends State<NoticiasDesktop> {
  final NoticiasSemob _noticiasService = NoticiasSemob();
  final ImagemService _imagemService = ImagemService();
  late Future<List<Map<String, dynamic>>> _futureNoticias;
  final PageController _pageController = PageController(viewportFraction: 1.0);

  @override
  void initState() {
    super.initState();
    _futureNoticias = _noticiasService.procurarNoticias();
  }
  //
  // @override
  // void initState() {
  //   super.initState();
  //
  //   // Simula carregamento de 3 segundos antes de buscar os dados
  //   _futureNoticias = Future.delayed(
  //     const Duration(seconds: 3),
  //         () => _noticiasService.procurarNoticias(),
  //   ).then((futuro) => futuro); // mantém o mesmo tipo de retorno
  // }


  void _proximaPagina() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _paginaAnterior() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _abrirLink(String url) async {
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureNoticias,
      builder: (context, snapshot) {
        // Estado de carregamento → mostra skeletons
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeletonRow();
        }

        // Erro ou lista vazia
        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma notícia disponível.'));
        }

        final noticias = snapshot.data!;
        // Agrupa em páginas de 3 itens
        final paginas = <List<Map<String, dynamic>>>[];
        for (int i = 0; i < noticias.length; i += 3) {
          paginas.add(
            noticias.sublist(i, i + 3 > noticias.length ? noticias.length : i + 3),
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 300,
              child: Row(
                children: [
                  // Botão anterior
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: _paginaAnterior,
                  ),

                  // PageView com 3 cards por página
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: paginas.length,
                      itemBuilder: (context, pageIndex) {
                        final paginaNoticias = paginas[pageIndex];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: paginaNoticias.map((noticia) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: FutureBuilder<Uint8List?>(
                                  future: _imagemService.carregarImagemProtegida(noticia['img']),
                                  builder: (context, imgSnapshot) {
                                    // Carregando imagem → skeleton
                                    if (imgSnapshot.connectionState == ConnectionState.waiting) {
                                      return _buildSkeletonCard();
                                    }
                                    // Erro ou imagem nula → fallback
                                    if (!imgSnapshot.hasData || imgSnapshot.data == null) {
                                      return _buildFallbackCard(noticia);
                                    }
                                    // Imagem carregada → card normal
                                    return _buildNoticiaCard(noticia, imgSnapshot.data!);
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),

                  // Botão próximo
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: _proximaPagina,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Indicador de páginas
            SmoothPageIndicator(
              controller: _pageController,
              count: paginas.length,
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                spacing: 6,
                activeDotColor: Color(0xFF4A6FA5),
              ),
            ),
            const SizedBox(height: 12,)
          ],
        );
      },
    );
  }

  /// Card com imagem carregada
  Widget _buildNoticiaCard(Map<String, dynamic> noticia, Uint8List imagemBytes) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _abrirLink(noticia['link']),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.memory(
                  imagemBytes,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      noticia['titulo'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      noticia['descricao'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Card de fallback (imagem indisponível)
  Widget _buildFallbackCard(Map<String, dynamic> noticia) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _abrirLink(noticia['link']),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                decoration: const BoxDecoration(
                  color: Color(0xFF4A6FA5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.article_outlined, size: 40, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      noticia['titulo']?.isNotEmpty == true
                          ? noticia['titulo']
                          : 'Notícia indisponível',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      noticia['descricao']?.isNotEmpty == true
                          ? noticia['descricao']
                          : 'Não foi possível carregar a descrição.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Card skeleton (carregando)
  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: double.infinity, color: Colors.grey[300]),
                const SizedBox(height: 6),
                Container(height: 12, width: 150, color: Colors.grey[300]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Linha com 3 skeletons (para carregamento inicial)
  Widget _buildSkeletonRow() {
    return SizedBox(
      height: 300,
      child: Row(
        children: List.generate(
          3,
              (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildSkeletonCard(),
            ),
          ),
        ),
      ),
    );
  }
}
