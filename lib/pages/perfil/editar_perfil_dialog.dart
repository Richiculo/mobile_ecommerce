import 'package:flutter/material.dart';
import '../../providers/auth/auth_provider.dart';

void mostrarDialogoEditarPerfil(
    BuildContext ctx, AuthProvider auth, Map<String, dynamic> user) {
  final nombreCtrl = TextEditingController(text: user['nombre']);
  final apellidosCtrl = TextEditingController(text: user['apellidos']);

  showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      title: const Text('Editar perfil'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nombreCtrl,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          TextField(
            controller: apellidosCtrl,
            decoration: const InputDecoration(labelText: 'Apellidos'),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            final ok = await auth.updateUser({
              'nombre': nombreCtrl.text,
              'apellidos': apellidosCtrl.text,
            });
            Navigator.pop(ctx);
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                  content:
                      Text(ok ? 'Perfil actualizado' : 'Error al actualizar')),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}
