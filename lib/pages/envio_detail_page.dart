import 'package:flutter/material.dart';
import '../services/direcciones/direccion_service.dart';

class EnvioDetailPage extends StatefulWidget {
  final Map<String, dynamic> envio;

  const EnvioDetailPage({super.key, required this.envio});

  @override
  _EnvioDetailPageState createState() => _EnvioDetailPageState();
}

class _EnvioDetailPageState extends State<EnvioDetailPage> {
  Map<String, dynamic>? direccionDetalle;
  bool loadingDireccion = true;

  @override
  void initState() {
    super.initState();
    fetchDireccion();
  }

  Future<void> fetchDireccion() async {
    final direccionId = widget.envio['direccion_entrega'];
    if (direccionId != null) {
      final direccionService = DireccionService();
      final fetchedDireccion = await direccionService.getDir(direccionId);
      if (fetchedDireccion != null) {
        setState(() {
          direccionDetalle = fetchedDireccion;
          loadingDireccion = false;
        });
      } else {
        setState(() {
          loadingDireccion = false;
        });
      }
    } else {
      setState(() {
        loadingDireccion = false;
      });
    }
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
    final estado = widget.envio['estado'] ?? 'desconocido';
    final fechaEnvio = widget.envio['fecha_envio'];
    final fechaEntrega = widget.envio['fecha_entrega'];
    final observaciones = widget.envio['observaciones'] ?? '';
    final agencia = widget.envio['agencia_reparto'] ?? 'Agencia no disponible';
    final idVenta = widget.envio['venta']?.toString() ?? 'N/A';

    String direccionTexto() {
      if (loadingDireccion) {
        return 'Cargando dirección...';
      }
      if (direccionDetalle == null) {
        return 'Dirección no disponible';
      }
      final calle = direccionDetalle!['calle'] ?? '';
      final ciudad = direccionDetalle!['ciudad'] ?? '';
      final provincia = direccionDetalle!['provincia'] ?? '';
      final pais = direccionDetalle!['pais'] ?? '';
      return '$calle, $ciudad, $provincia, $pais';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Envío'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Icon(
                getEstadoIcon(estado),
                size: 80,
                color: getEstadoColor(estado),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                estado[0].toUpperCase() + estado.substring(1),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: getEstadoColor(estado),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha de Envío'),
              subtitle: Text(fechaEnvio != null
                  ? fechaEnvio.substring(0, 10)
                  : 'No registrada'),
            ),
            ListTile(
              leading: const Icon(Icons.event_available),
              title: const Text('Fecha de Entrega'),
              subtitle: Text(fechaEntrega != null
                  ? fechaEntrega.substring(0, 10)
                  : 'No entregado aún'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Observaciones'),
              subtitle: Text(
                observaciones.isNotEmpty ? observaciones : 'Sin observaciones',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Dirección de Entrega'),
              subtitle: Text(direccionTexto()),
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('Agencia de Reparto'),
              subtitle: Text(agencia),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('ID de Venta'),
              subtitle: Text(idVenta),
            ),
          ],
        ),
      ),
    );
  }
}
