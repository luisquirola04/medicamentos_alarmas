import 'package:medicamentos_app/factory/medicamento_factory.dart';

class Medicamento {
  int? id;
  String nombre;
  String descripcion;
  int cantidad;
  double dosis;
  int estado;

  Medicamento({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.cantidad,
    required this.dosis,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'dosis': dosis,
      'estado': estado,
    };
  }

  static Medicamento fromMap(Map<String, dynamic> map) {
    return MedicamentoFactory.createFromMap(map);
  }
}
