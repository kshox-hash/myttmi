class RegionCL {
  final String codigo;
  final String nombre;
  RegionCL({required this.codigo, required this.nombre});

  factory RegionCL.fromJson(Map<String, dynamic> j) => RegionCL(
        codigo: (j["codigo"] ?? "").toString(),
        nombre: (j["nombre"] ?? "").toString(),
      );
}

class ProvinciaCL {
  final String codigo;
  final String nombre;
  final String codigoRegion;
  ProvinciaCL({
    required this.codigo,
    required this.nombre,
    required this.codigoRegion,
  });

  factory ProvinciaCL.fromJson(Map<String, dynamic> j) => ProvinciaCL(
        codigo: (j["codigo"] ?? "").toString(),
        nombre: (j["nombre"] ?? "").toString(),
        codigoRegion: (j["codigoRegion"] ?? "").toString(),
      );
}

class ComunaCL {
  final String codigo;
  final String nombre;
  final String codigoProvincia;
  ComunaCL({
    required this.codigo,
    required this.nombre,
    required this.codigoProvincia,
  });

  factory ComunaCL.fromJson(Map<String, dynamic> j) => ComunaCL(
        codigo: (j["codigo"] ?? "").toString(),
        nombre: (j["nombre"] ?? "").toString(),
        codigoProvincia: (j["codigoProvincia"] ?? "").toString(),
      );
}
