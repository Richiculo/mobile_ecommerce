class Cart {
  final int id;
  final String estado;
  final String creadoEn;

  Cart({
    required this.id,
    required this.estado,
    required this.creadoEn,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      estado: json['estado'],
      creadoEn: json['creado_en'],
    );
  }
}
