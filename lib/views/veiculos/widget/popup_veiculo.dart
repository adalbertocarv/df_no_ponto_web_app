import 'package:flutter/material.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

class CustomPopup extends StatelessWidget {
  final Map<String, dynamic> dadosVeiculo;
  final PopupController popupController;
  final String linha;
  final VoidCallback onClose;
  final VoidCallback? onVerRota; // Callback para ver/ocultar rota
  final bool carregandoPercurso; // Se está carregando percurso
  final bool temRota; // Se já tem a rota carregada
  final bool isLinhaAtual; // Se é a linha atual sendo carregada

  const CustomPopup({
    required this.dadosVeiculo,
    required this.popupController,
    required this.linha,
    required this.onClose,
    this.onVerRota,
    this.carregandoPercurso = false,
    this.temRota = false,
    this.isLinhaAtual = false,
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

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          linha != null && linha.isNotEmpty
              ? Text(
                  'Linha: $linha',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 4),
          Text(
            'Prefixo: $prefixo',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text('Operadora: $nmOperadora',            style: TextStyle(color: Colors.white),),
          if (sentido != 'N/A') const SizedBox(height: 4),
          if (sentido != 'N/A') Text('Sentido: $sentido',            style: TextStyle(color: Colors.white),),
          const SizedBox(height: 4),
          Text(
            'Última atualização:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          Text(
            dataFormatada,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botão Ver/Ocultar Rota
              if (onVerRota != null)
                TextButton(
                  onPressed: carregandoPercurso ? null : onVerRota,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (carregandoPercurso && isLinhaAtual)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      else
                        linha != null && linha.isNotEmpty
                            ? Icon(
                                temRota ? Icons.visibility_off : Icons.route,
                                size: 16,
                                color: carregandoPercurso
                                    ? Colors.blue
                                    : Colors.blueAccent,
                              )
                            : const SizedBox.shrink(),
                      const SizedBox(width: 4),
                      linha != null && linha.isNotEmpty
                          ? Text(
                              temRota ? 'Ocultar Rota' : 'Ver Rota',
                              style: TextStyle(
                                color: carregandoPercurso
                                    ? Colors.blue
                                    : Colors.blueAccent,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              if (onVerRota != null) const SizedBox(width: 8),
              // Botão Fechar
              TextButton(
                onPressed: onClose,
                child: const Text(
                  'Fechar',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
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
