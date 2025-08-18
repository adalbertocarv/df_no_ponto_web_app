import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../services/noticias/noticia_imagem.dart';
import '../../../../services/noticias/noticias.dart';

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
          return _buildSkeletonCarousel();
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
              height: 100,
              child: PageView.builder(
                controller: _pageController,
                itemCount: noticias.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4), // mantém um pequeno gap
                    child: _buildNoticiaCard(noticias[index]),
                  );
                },
              ),

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

  Widget _buildNoticiaCard(Map<String, dynamic> noticia) {
    return FutureBuilder<Uint8List?>(
      future: _imagemService.carregarImagemProtegida(noticia['img']),
      builder: (context, imgSnapshot) {
        Widget imageWidget;
        if (imgSnapshot.connectionState == ConnectionState.waiting) {
          imageWidget = Container(
            height: 100,
            width: double.infinity,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        } else if (imgSnapshot.hasData && imgSnapshot.data != null) {
          imageWidget = Image.memory(
            imgSnapshot.data!,
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        } else {
          imageWidget = Container(
            height: 100,
            width: double.infinity,
            color: Colors.blue[300],
            child: const Icon(Icons.image_not_supported, color: Colors.white, size: 40),
          );
        }

        return GestureDetector(
          onTap: () => _abrirLink(noticia['link']),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                imageWidget,
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        noticia['titulo'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        noticia['descricao'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
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
  }

  Widget _buildSkeletonCarousel() {
    return SizedBox(
      height: 100,
      child: PageView.builder(
        controller: PageController(viewportFraction: 1.0),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.grey[300],
              ),
            ),
          );
        },
      ),
    );
  }
}
