import 'package:flutter/material.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

class CustomPopup extends StatelessWidget {
  final Map<String, dynamic> dadosVeiculo;
  final PopupController popupController;
  final String linha;
  final VoidCallback onClose; // Callback para fechar o popup e limpar o percurso

  const CustomPopup({
    required this.dadosVeiculo,
    required this.popupController,
    required this.linha,
    required this.onClose,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nmOperadora = dadosVeiculo['nm_operadora'] ?? 'N/A';
    final prefixo = dadosVeiculo['prefixo'] ?? 'N/A';
    final datalocal = dadosVeiculo['datalocal'] ?? 'N/A';
    final sentido = dadosVeiculo['sentido'] ?? 'N/A';

    // Formatando a data e hora
    final dataFormatada = formatarDataHora(datalocal);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(12),
              color: Colors.black.withOpacity(0.8),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ajusta altura dinamicamente
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      linha != null && linha.isNotEmpty
                          ? Expanded(
                        child: Text(
                          'Linha: $linha',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                          : const SizedBox.shrink(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),

                        onPressed: onClose,
                        tooltip: 'Fechar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Operadora: $nmOperadora',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prefixo: $prefixo',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sentido: $sentido',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Última atualização:',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    dataFormatada,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: CustomPaint(
            size: const Size(20, 10),
            painter: TrianglePainter(),
          ),
        ),
      ],
    );
  }

  /// Formata a data e hora para exibição amigável
  String formatarDataHora(String datalocal) {
    try {
      final dateTime = DateTime.parse(datalocal);
      return '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year} às '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Data inválida';
    }
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}