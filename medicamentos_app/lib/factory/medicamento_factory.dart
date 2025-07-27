import '../models/medicamento.dart';

class MedicamentoFactory {
  static Medicamento createFromMap(Map<String, dynamic> map) {
    return Medicamento(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      cantidad: map['cantidad'],
      dosis: map['dosis']?.toDouble() ?? 0.0,
      estado: map['estado'],
    );
  }

  static Medicamento createNew({
    required String nombre,
    required String descripcion,
    required int cantidad,
    required double dosis,
    int estado = 1,
  }) {
    return Medicamento(
      nombre: nombre,
      descripcion: descripcion,
      cantidad: cantidad,
      dosis: dosis,
      estado: estado,
    );
  }
}
