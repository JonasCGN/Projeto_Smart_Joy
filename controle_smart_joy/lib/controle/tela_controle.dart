import 'package:flutter/material.dart';
import 'package:joy_controle/class/interface_control.dart';
import 'package:joy_controle/controle/tela_direcional.dart';


class ControlePage extends StatelessWidget {
  final String ipServidor;
  final InterfaceControl interfaceControl;
  const ControlePage({super.key, required this.ipServidor, required this.interfaceControl});

  void _abrirTelaDirecional(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaDirecional(interfaceControl: interfaceControl,ipServidor: ipServidor),
      ),
    );
  }

//   void _confirmarAcao(BuildContext context, String acao, String titulo) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Confirmar $titulo'),
//         content: Text('Deseja realmente $titulo o computador?'),
//         actions: [
//           TextButton(
//             child: const Text('Cancelar'),
//             onPressed: () => Navigator.of(ctx).pop(),
//           ),
//           ElevatedButton(
//             child: const Text('Sim'),
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               _enviarComando(acao);
//             },
//           ),
//         ],
//       ),
//     );
//   }

  @override
  Widget build(BuildContext context) {
    final botoes = [
      ['⬆️', 'up'], ['⬇️', 'down'], ['⬅️', 'left'], ['➡️', 'right'],
      ['🔄 Tab', 'tab'], ['✅ Enter', 'enter'], ['⏯️ Play', 'playpause'],
      ['🔊 Vol +', 'volup'], ['🔉 Vol -', 'voldown'], ['🔇 Mudo', 'mute'],
      ['⏮️ Ant', 'prev'], ['⏭️ Próx', 'next'], ['⬅️ Pag', 'back'], ['➡️ Pag', 'forward'],
	  ['f11', 'tela_cheia'],
      ['📺 YouTube', 'open_youtube'], ['🎵 YT Music', 'open_ytmusic'], ['🎮 Steam', 'open_steam'],
    //   ['🔌 Desligar', 'shutdown'],['🔄 Reiniciar', 'restart'], ['💤 Suspender', 'sleep']
    ];

    final controladorTexto = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Controle Joy — App de Controle Remoto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.open_with),
              label: const Text('Abrir Controle Direcional'),
              onPressed: () => _abrirTelaDirecional(context),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: botoes.map((b) {
                  final comando = b[1];
                  final label = b[0];

                //   final criticos = ['shutdown', 'restart', 'sleep'];

                  return ElevatedButton(
                    onPressed: () {
                    //   if (criticos.contains(comando)) {
                        // _confirmarAcao(context, comando, label.replaceAll(RegExp(r'[^a-zA-ZÀ-ÿ ]'), '').trim());
                    //   } else {
                        interfaceControl.enviarComando(comando);
                    //   }
                    },
                    child: Text(label, style: const TextStyle(fontSize: 18)),
                  );
                }).toList(),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controladorTexto,
                    decoration: const InputDecoration(
                      hintText: 'Digite algo...'
                    ),
                    onSubmitted: (texto) {
                      interfaceControl.enviarTexto(texto);
                      controladorTexto.clear();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    interfaceControl.enviarTexto(controladorTexto.text);
                    controladorTexto.clear();
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}