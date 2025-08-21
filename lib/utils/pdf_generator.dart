import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../controller/resultado_linha/resultado_linha_controller.dart';
import '../../../../models/linha/horario.dart';

class PdfGenerator {
  static Future<void> gerarPdfLinha(
      BuildContext context,
      String numero,
      ResultadoLinhaController dadosController,
      ) async {
    try {
      // Mostrar indicador de carregamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Gerando PDF...'),
            ],
          ),
        ),
      );

      final pdf = pw.Document();
      final fontRegular = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
      final fontBold = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(
            base: fontRegular,
            bold: fontBold,
          ),
          build: (pw.Context context) {
            return [
              _buildCabecalho(numero, dadosController),
              pw.SizedBox(height: 20),
              _buildInformacoes(dadosController),
              pw.SizedBox(height: 20),
              _buildHorarios(dadosController),
            ];
          },
        ),
      );


      // Página 2 - Itinerários (se houver)
      if (dadosController.itinerarios?.isNotEmpty == true) {
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            theme: pw.ThemeData.withFont(
              base: pw.Font.courier(),
              bold: pw.Font.courierBold(),
            ),
            build: (pw.Context context) {
              return [
                pw.Header(
                  level: 1,
                  child: pw.Text(
                    'Itinerarios - Linha $numero',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                ..._buildItinerarios(dadosController),
              ];
            },
          ),
        );
      }

// Gerar e fazer download do PDF
      final bytes = await pdf.save();

// Fazer download do arquivo. Esta é uma operação assíncrona do navegador.
      _downloadPdf(bytes, 'linha_${numero}_informacoes.pdf');

// Fechar dialog de carregamento IMEDIATAMENTE após iniciar o download.
// Isso evita conflitos de estado.
      Navigator.of(context).pop();

// Mostrar sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF gerado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      // Fechar dialog se estiver aberto
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Mostrar erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static pw.Widget _buildCabecalho(String numero, ResultadoLinhaController controller) {
    final info = controller.infoLinha?.firstOrNull;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'LINHA $numero',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          if (info?.descricao != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              info!.descricao,
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.grey700,
              ),
            ),
          ],
          pw.SizedBox(height: 8),
          pw.Text(
            'Relatorio gerado em: ${DateTime.now().toString().split('.')[0]}',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInformacoes(ResultadoLinhaController controller) {
    final infoLinhas = controller.infoLinha;

    if (infoLinhas == null || infoLinhas.isEmpty) {
      return pw.Container();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'INFORMACOES GERAIS',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.SizedBox(height: 12),
        ...infoLinhas.map((info) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Numero:', info.numero),
              _buildInfoRow('Descricao:', info.descricao),
              _buildInfoRow('Sentido:', info.sentido),
              _buildInfoRow('Operadora:', info.operadora),
              _buildInfoRow('Tarifa:', 'R\$ ${info.tarifa.toStringAsFixed(2)}'),
              _buildInfoRow('Faixa Tarifaria:', info.faixaTarifaria),
            ],
          ),
        )).toList(),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHorarios(ResultadoLinhaController controller) {
    final horarios = controller.horarios;

    if (horarios == null || horarios.isEmpty) {
      return pw.Container();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'HORARIOS',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.SizedBox(height: 12),
        ...horarios.map((horario) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange50,
                  border: pw.Border.all(color: PdfColors.orange),
                ),
                child: pw.Text(
                  'Sentido: ${horario.sentido}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              if (horario.duracaoMedia != null)
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Duracao media: ${horario.duracaoMedia} min',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  children: _buildHorariosPorDia(horario.horarios),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  static List<pw.Widget> _buildHorariosPorDia(List<Horario> horarios) {
    final agrupados = _agruparHorariosPorDia(horarios);

    return agrupados.entries.map((entry) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Text(
            Horario.formatarDiaSemana(entry.key),
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: PdfColors.blue,
            ),
          ),
        ),
        pw.Wrap(
          spacing: 6,
          runSpacing: 4,
          children: entry.value.map((h) => pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              h.horario,
              style: const pw.TextStyle(fontSize: 8),
            ),
          )).toList(),
        ),
        pw.SizedBox(height: 12),
      ],
    )).toList();
  }

  static Map<String, List<Horario>> _agruparHorariosPorDia(List<Horario> horarios) {
    final Map<String, List<Horario>> agrupados = {};

    for (final horario in horarios) {
      if (!agrupados.containsKey(horario.diasSemana)) {
        agrupados[horario.diasSemana] = [];
      }
      agrupados[horario.diasSemana]!.add(horario);
    }

    for (final lista in agrupados.values) {
      lista.sort((a, b) => (a.hora * 60 + a.minuto).compareTo(b.hora * 60 + b.minuto));
    }

    return agrupados;
  }

  static List<pw.Widget> _buildItinerarios(ResultadoLinhaController controller) {
    final itinerarios = controller.itinerarios;

    if (itinerarios == null || itinerarios.isEmpty) {
      return [];
    }

    // Máximo de itens por página (ajuste conforme layout)
    const int maxItensPorPagina = 40;
    final widgets = <pw.Widget>[];

    for (final itinerario in itinerarios) {
      // Cabeçalho do itinerário
      widgets.add(
        pw.Container(
          width: double.maxFinite,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.green50,
            border: pw.Border.all(color: PdfColors.green),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${itinerario.origem} para ${itinerario.destino}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Sentido: ${itinerario.sentido} | Extensão: ${itinerario.extensao.toStringAsFixed(2)} km',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
      );

      // Quebrar em páginas
      final pontos = itinerario.itinerario;
      for (var i = 0; i < pontos.length; i += maxItensPorPagina) {
        final slice = pontos.skip(i).take(maxItensPorPagina).toList();

        widgets.add(
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 20),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              children: slice.asMap().entries.map((entry) {
                final index = entry.key + i;
                final item = entry.value;
                final isFirst = index == 0;
                final isLast = index == pontos.length - 1;

                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 20,
                        height: 20,
                        decoration: pw.BoxDecoration(
                          color: isFirst
                              ? PdfColors.green
                              : isLast
                              ? PdfColors.red
                              : PdfColors.blue,
                          shape: pw.BoxShape.circle,
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            item.sequencial,
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (item.via.isNotEmpty)
                              pw.Text(
                                item.via,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            if (item.localidade.isNotEmpty)
                              pw.Text(
                                item.localidade,
                                style: pw.TextStyle(
                                  color: PdfColors.grey600,
                                  fontSize: 9,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );

        // Força quebra de página se ainda houver mais pontos
        if (i + maxItensPorPagina < pontos.length) {
          widgets.add(pw.NewPage());
        }
      }
    }

    return widgets;
  }

  static void _downloadPdf(List<int> bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}

// Widget do botão para adicionar ao seu DesktopSidePanel
class PdfDownloadButton extends StatelessWidget {
  const PdfDownloadButton({
    super.key,
    required this.numero,
    required this.dadosController,
  });

  final String numero;
  final ResultadoLinhaController dadosController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: dadosController.carregando
              ? null
              : () => PdfGenerator.gerarPdfLinha(
            context,
            numero,
            dadosController,
          ),
          icon: const Icon(Icons.picture_as_pdf, size: 20),
          label: const Text(
            'Baixar Relatório PDF',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}