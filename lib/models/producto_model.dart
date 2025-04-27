class Categoria {
  final String nombre;
  final String descripcion;

  Categoria({required this.nombre, required this.descripcion});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }
}

class ImagenProducto {
  final String url;

  ImagenProducto({required this.url});

  factory ImagenProducto.fromJson(Map<String, dynamic> json) {
    return ImagenProducto(url: json['url']);
  }
}

class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final String proveedor;
  final double? descuento;
  final List<String> imagenes;
  final int stockTotal;
  final Detalle? detalle;
  final List<Categoria> categorias;
  final bool estaDisponible;

  Producto(
      {required this.id,
      required this.nombre,
      required this.descripcion,
      required this.proveedor,
      this.descuento,
      required this.imagenes,
      required this.stockTotal,
      this.detalle,
      required this.categorias,
      required this.estaDisponible});

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      proveedor: json['proveedor'],
      descuento: json['descuento']?.toDouble(),
      imagenes: List<String>.from(json['imagenes']),
      stockTotal: json['stock_total'],
      estaDisponible: json['esta_disponible'],
      detalle:
          json['detalle'] != null ? Detalle.fromJson(json['detalle']) : null,
      categorias: (json['categorias'] as List)
          .map((cat) => Categoria.fromJson(cat))
          .toList(),
    );
  }
}

class Detalle {
  final String marca;
  final double precio;

  Detalle({required this.marca, required this.precio});

  factory Detalle.fromJson(Map<String, dynamic> json) {
    return Detalle(
      marca: json['marca'],
      precio: json['precio'].toDouble(),
    );
  }
}
