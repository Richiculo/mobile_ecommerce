import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pedidos/venta_provider.dart';
import '../pages/venta_detail_page.dart';

class VentasUserPage extends StatefulWidget {
  const VentasUserPage({super.key});

  @override
  State<VentasUserPage> createState() => _VentasUserPageState();
}

class _VentasUserPageState extends State<VentasUserPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVentas();
    });
  }

  Future<void> _loadVentas() async {
    await Provider.of<VentaProvider>(context, listen: false).obtenerVentas();
    setState(() {
      _isLoading = false;
    });
  }

  Color getEstadoColor(String estado) {
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

  IconData getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Icons.hourglass_empty;
      case 'pagado':
        return Icons.check_circle;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ventasProvider = Provider.of<VentaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Compras'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (ventasProvider.ventas == null || ventasProvider.ventas!.isEmpty)
              ? const Center(child: Text('No has realizado ninguna compra.'))
              : ListView.builder(
                  itemCount: ventasProvider.ventas!.length,
                  itemBuilder: (context, index) {
                    final venta = ventasProvider.ventas![index];
                    final estado =
                        (venta['estado'] ?? 'desconocido').toString();
                    final fecha = (venta['fecha'] ?? '').toString();

                    // 1) Extraemos rawTotal como dynamic:
                    final rawTotal = venta['total'];

                    // 2) Parseamos a double:
                    final double total = rawTotal is num
                        ? rawTotal.toDouble()
                        : double.tryParse(rawTotal.toString()) ?? 0.0;

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
                            if (fecha.isNotEmpty)
                              Text('Fecha: ${fecha.substring(0, 10)}'),
                            const SizedBox(height: 4),
                            // 3) Usamos la variable `total` ya en double:
                            Text('Total: Bs ${total.toStringAsFixed(2)}'),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VentaDetailPage(venta: venta),
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
