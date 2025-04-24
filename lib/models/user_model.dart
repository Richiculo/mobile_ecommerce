class Usuario {
  final int id;
  final String nombre;
  final String correo;

  Usuario({required this.id, required this.nombre, required this.correo});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
        id: json['id'], nombre: json['nombre'], correo: json['correo']);
  }
}
