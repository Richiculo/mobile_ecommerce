import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/envios/envios_provider.dart';
import '../pages/envio_detail_page.dart';

class EnviosPage extends StatefulWidget {
  const EnviosPage({super.key});

  @override
  State<EnviosPage> createState() => _EnviosPageState();
}

class _EnviosPageState extends State<EnviosPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEnvios();
    });
  }

  Future<void> _loadEnvios() async {
    await Provider.of<EnviosProvider>(context, listen: false).obtenerEnvios();
    setState(() {
      _isLoading = false;
    });
  }

  Color getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'enviado':
        return Colors.blue;
      case 'entregado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Icons.hourglass_empty;
      case 'enviado':
        return Icons.local_shipping;
      case 'entregado':
        return Icons.check_circle;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enviosProvider = Provider.of<EnviosProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Envíos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (enviosProvider.envios == null || enviosProvider.envios!.isEmpty)
              ? const Center(child: Text('No tienes envíos activos.'))
              : ListView.builder(
                  itemCount: enviosProvider.envios!.length,
                  itemBuilder: (context, index) {
                    final envio = enviosProvider.envios![index];
                    final estado = envio['estado'] ?? 'desconocido';
                    final fechaEnvio = envio['fecha_envio'];
                    final observaciones = envio['observaciones'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      elevation: 3,
                      child: ListTile(
                        leading: Icon(
                          getEstadoIcon(estado),
                          color: getEstadoColor(estado),
                          size: 35,
                        ),
                        title: Text(
                          'Estado: ${estado[0].toUpperCase()}${estado.substring(1)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: getEstadoColor(estado),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (fechaEnvio != null)
                              Text(
                                  'Fecha de envío: ${fechaEnvio.substring(0, 10)}'),
                            const SizedBox(height: 4),
                            Text('Observaciones: $observaciones'),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EnvioDetailPage(envio: envio),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
