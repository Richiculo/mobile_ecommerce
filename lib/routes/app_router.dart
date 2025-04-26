import 'package:go_router/go_router.dart';
import 'package:mobile_ecommerce/pages/detalle_producto_page.dart';
import 'package:mobile_ecommerce/models/producto_model.dart';
import 'package:mobile_ecommerce/pages/home/home_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    // Ruta principal (Home)
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(),
    ),

    // Ruta de detalle de producto
    GoRoute(
      path: '/detalle',
      builder: (context, state) {
        final Producto product =
            state.extra as Producto; // Recibe el producto como extra
        return DetalleProductoPage(
            product: product); // Pasa el producto a la página de detalle
      },
    ),
  ],
);
