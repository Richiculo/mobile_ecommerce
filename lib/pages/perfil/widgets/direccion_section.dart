import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth/auth_provider.dart';
import '../agregar_direccion_dialog.dart';
import '../editar_direccion_dialog.dart';

class DireccionSection extends StatefulWidget {
  const DireccionSection({super.key});

  @override
  State<DireccionSection> createState() => _DireccionSectionState();
}

class _DireccionSectionState extends State<DireccionSection> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDireccion();
  }

  Future<void> _cargarDireccion() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Solo carga la dirección si no está ya cargada
    if (auth.direccionActual == null) {
      final user = auth.user!;
      final direccionId = user['direccion'];

      if (direccionId != null) {
        await auth.getDireccion(direccionId);
      }
    }

    // Después de cargar los datos, se actualiza la UI
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.user!;
        final direccion = auth.direccionActual;

        if (direccion != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dirección:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  '${direccion['calle']} #${direccion['numero']}, ${direccion['ciudad']}'),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_location_alt),
                label: const Text('Editar dirección'),
                onPressed: () =>
                    mostrarDialogoEditarDireccion(context, auth, direccion),
              ),
            ],
          );
        } else {
          return ElevatedButton.icon(
            icon: const Icon(Icons.add_location),
            label: const Text('Agregar dirección'),
            onPressed: () => mostrarAgregarDireccionDialog(context, auth),
          );
        }
      },
    );
  }
}
