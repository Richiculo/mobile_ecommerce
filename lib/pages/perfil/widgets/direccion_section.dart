import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../agregar_direccion_dialog.dart';
import '../editar_direccion_dialog.dart';

class DireccionSection extends StatelessWidget {
  const DireccionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user!;
    final dir = user['direccion'];

    if (dir != null) {
      // Si ya hay dirección, la mostramos con opción a editar
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dirección:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${dir['calle']} #${dir['numero']}, ${dir['ciudad']}'),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_location_alt),
            label: const Text('Editar dirección'),
            onPressed: () => mostrarDialogoEditarDireccion(context, auth, dir),
          ),
        ],
      );
    } else {
      // No hay dirección: botón para agregar
      return ElevatedButton.icon(
        icon: const Icon(Icons.add_location),
        label: const Text('Agregar dirección'),
        onPressed: () => mostrarAgregarDireccionDialog(context, auth),
      );
    }
  }
}
