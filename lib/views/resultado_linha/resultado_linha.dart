import 'package:flutter/material.dart';
import 'desktop/desktop_resultado_linha.dart';
import 'mobile/mobile_resultado_linha.dart';

class ResultadoLinhaPage extends StatelessWidget {
  const ResultadoLinhaPage({super.key, required this.numero});
  final String numero;

  static const _desktopBreakpoint = 780.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= _desktopBreakpoint) {
      return DesktopResultadoLinha(numero: numero);
    }
    return MobileResultadoLinha(numero: numero);
  }
}
