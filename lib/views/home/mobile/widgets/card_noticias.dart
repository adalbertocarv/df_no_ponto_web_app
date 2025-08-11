import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../services/noticias/noticia_imagem.dart';
import '../../../../services/noticias/noticias.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class NoticiasCarousel extends StatefulWidget {
  const NoticiasCarousel({super.key});

  @override
  State<NoticiasCarousel> createState() => _NoticiasCarouselState();
}

class _NoticiasCarouselState extends State<NoticiasCarousel> {
  final NoticiasSemob _noticiasService = NoticiasSemob();
  final ImagemService _imagemService = ImagemService();
  final PageController _pageController = PageController(viewportFraction: 1.0);
  late Future<List<Map<String, dynamic>>> _futureNoticias;

  @override
  void initState() {
    super.initState();
    _futureNoticias = _noticiasService.procurarNoticias();
  }

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
        if (snapshot.connectionState == ConnectionState.waiting) {
          final skeletonController = PageController(viewportFraction: 1.0);
          return SizedBox(
            height: 200,
            child: PageView.builder(
              controller: skeletonController, // controller independente
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildSkeletonCardMobile(),
                );
              },
            ),
          );
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar notícias'));
        }
        final noticias = snapshot.data ?? [];
        if (noticias.isEmpty) {
          return const Center(child: Text('Nenhuma notícia disponível.'));
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child:
              PageView.builder(
                controller: _pageController,
                itemCount: noticias.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double scale = 1.0;

                      if (_pageController.position.haveDimensions) {
                        scale = (_pageController.page! - index).abs();
                        scale = (1 - (scale * 0.05)).clamp(0.95, 1.0);
                      }

                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Builder(
                      builder: (context) {
                        final noticia = noticias[index];
                        return FutureBuilder<Uint8List?>(
                          future: _imagemService.carregarImagemProtegida(noticia['img']),
                          builder: (context, imgSnapshot) {
                            Widget imagemWidget;
                            if (imgSnapshot.connectionState == ConnectionState.waiting) {
                              imagemWidget = Container(
                                height: 100,
                                width: double.infinity,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            } else if (imgSnapshot.hasData && imgSnapshot.data != null) {
                              imagemWidget = ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Image.memory(
                                  imgSnapshot.data!,
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              );
                            } else {
                              imagemWidget = Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.blue[300],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child:                   const Image(
                                  image: AssetImage('assets/images/icon_bus.png'),
                                  width: 40,
                                  height: 40,
                                ),
                              );
                            }

                            return GestureDetector(
                              onTap: () => _abrirLink(noticia['link']),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    imagemWidget,
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
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            noticia['descricao'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                              height: 1.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              )
            ),
            const SizedBox(height: 8),
            SmoothPageIndicator(
              controller: _pageController,
              count: noticias.length,
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                spacing: 6,
                activeDotColor: Color(0xFF4A6FA5),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkeletonCardMobile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Área da imagem
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE0E0E0), // cinza claro
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
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
