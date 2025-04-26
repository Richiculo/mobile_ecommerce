import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';

void mostrarAgregarDireccionDialog(BuildContext ctx, AuthProvider auth) {
  final paisC = TextEditingController();
  final ciudadC = TextEditingController();
  final calleC = TextEditingController();
  final numeroC = TextEditingController();
  // …otros campos (zona, referencia, departamentoId)

  showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      title: Text('Nueva dirección'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: paisC,
                decoration: InputDecoration(labelText: 'País')),
            TextField(
                controller: ciudadC,
                decoration: InputDecoration(labelText: 'Ciudad')),
            TextField(
                controller: calleC,
                decoration: InputDecoration(labelText: 'Calle')),
            TextField(
                controller: numeroC,
                decoration: InputDecoration(labelText: 'Número')),
            // … resto de campos
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            final ok = await auth.addDireccion({
              'pais': paisC.text,
              'ciudad': ciudadC.text,
              'calle': calleC.text,
              'numero': numeroC.text,
              // …otros campos solicitados por tu serializer
            });
            Navigator.pop(ctx);
            if (ok) {
              ScaffoldMessenger.of(ctx)
                  .showSnackBar(SnackBar(content: Text('Dirección agregada')));
            } else {
              ScaffoldMessenger.of(ctx)
                  .showSnackBar(SnackBar(content: Text('Error al añadir')));
            }
          },
          child: Text('Guardar'),
        ),
      ],
    ),
  );
}
