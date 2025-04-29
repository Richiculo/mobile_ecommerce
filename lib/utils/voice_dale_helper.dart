import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceSaleHelper {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  Future<void> iniciarComandoVenta(
      BuildContext context, VoidCallback onConfirmarVenta) async {
    bool disponible = await _speech.initialize();
    if (!disponible) return;

    await _speech.listen(
      onResult: (result) async {
        String comando = result.recognizedWords.toLowerCase();
        if (comando.contains('comprar') || comando.contains('finalizar')) {
          await _tts.speak("¿Estás seguro que quieres realizar la compra?");

          // Mostrar diálogo de confirmación
          bool confirmado = await _mostrarDialogoConfirmacion(context, comando);
          if (confirmado) {
            onConfirmarVenta();
          }
        } else {
          await _tts.speak(
              "Comando no reconocido. Intenta decir 'comprar' o 'finalizar compra'.");
        }
      },
    );
  }

  Future<bool> _mostrarDialogoConfirmacion(
      BuildContext context, String comando) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirmar comando'),
            content: Text('¿Estás seguro que quieres "$comando"?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancelar')),
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Confirmar')),
            ],
          ),
        ) ??
        false;
  }
}
