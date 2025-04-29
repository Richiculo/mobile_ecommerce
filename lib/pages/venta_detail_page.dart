import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pedidos/venta_provider.dart';

class VentaDetailPage extends StatefulWidget {
  final Map<String, dynamic> venta;

  const VentaDetailPage({super.key, required this.venta});

  @override
  State<VentaDetailPage> createState() => _VentaDetailPageState();
}

class _VentaDetailPageState extends State<VentaDetailPage> {
  Future<void>? _detalleFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detalleFuture = _fetchDetalleVenta();
      setState(() {}); // para refrescar FutureBuilder con el nuevo Future
    });
  }

  Future<void> _fetchDetalleVenta() async {
    await Provider.of<VentaProvider>(context, listen: false)
        .obtenerDetalleVenta(widget.venta['id']);
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'pagado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = widget.venta['estado'] ?? 'desconocido';
    final fecha = widget.venta['fecha'] ?? '';

    final rawTotal = widget.venta['total'];
    final double total = rawTotal is num
        ? rawTotal.toDouble()
        : double.tryParse(rawTotal.toString()) ?? 0.0;

    final dventas = Provider.of<VentaProvider>(context).dventas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Venta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<void>(
          future: _detalleFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || dventas == null) {
              return const Center(child: Text('Error al cargar los productos'));
            }

            return ListView(
              children: [
                Text(
                  'Estado: ${estado[0].toUpperCase()}${estado.substring(1)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _getEstadoColor(estado),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Fecha de la compra: ${fecha.substring(0, 10)}'),
                const SizedBox(height: 8),
                Text('Total: ${total.toStringAsFixed(2)} Bs'),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Productos:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dventas.length,
                  itemBuilder: (context, index) {
                    final item = dventas[index];
                    final producto = item['producto'];
                    final nombre = producto['nombre'] ?? 'Sin nombre';
                    final cantidad = item['cantidad'] ?? 0;
                    final precioUnitarioRaw = item['precio_unitario'];
                    final double precioUnitario = precioUnitarioRaw is num
                        ? precioUnitarioRaw.toDouble()
                        : double.tryParse(precioUnitarioRaw.toString()) ?? 0.0;

                    return ListTile(
                      title: Text(nombre),
                      subtitle: Text('Cantidad: $cantidad'),
                      trailing: Text(
                        '${(precioUnitario * cantidad).toStringAsFixed(2)} Bs',
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
