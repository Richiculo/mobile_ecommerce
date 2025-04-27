import 'package:flutter/material.dart';
import '../../providers/auth/auth_provider.dart';

void mostrarDialogoEditarDireccion(
    BuildContext ctx, AuthProvider auth, Map<String, dynamic> direccion) {
  final paisC = TextEditingController(text: direccion['pais']);
  final ciudadC = TextEditingController(text: direccion['ciudad']);
  final calleC = TextEditingController(text: direccion['calle']);
  final numeroC = TextEditingController(text: direccion['numero']);
  // otros campos también aquí si tienes

  showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      title: const Text('Editar dirección'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: paisC,
                decoration: const InputDecoration(labelText: 'País')),
            TextField(
                controller: ciudadC,
                decoration: const InputDecoration(labelText: 'Ciudad')),
            TextField(
                controller: calleC,
                decoration: const InputDecoration(labelText: 'Calle')),
            TextField(
                controller: numeroC,
                decoration: const InputDecoration(labelText: 'Número')),
            // otros campos si hace falta
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            final ok = await auth.updateDireccion({
              'pais': paisC.text,
              'ciudad': ciudadC.text,
              'calle': calleC.text,
              'numero': numeroC.text,
              // incluir ID si se requiere para identificar la dirección
            });
            Navigator.pop(ctx);
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(ok
                    ? 'Dirección actualizada'
                    : 'Error al actualizar dirección'),
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}
