// lib/models/registro_toma.dart
import 'package:medicamentos_app/models/estado_toma.dart';

class RegistroToma {
  int? id;
  int medicamentoId;
  int horarioId;
  DateTime fechaHoraEsperada;
  DateTime? fechaHoraReal;
  EstadoToma estado;

  RegistroToma({
    this.id,
    required this.medicamentoId,
    required this.horarioId,
    required this.fechaHoraEsperada,
    this.fechaHoraReal,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicamentoId': medicamentoId,
      'horarioId': horarioId,
      'fechaHoraEsperada': fechaHoraEsperada.toIso8601String(),
      'fechaHoraReal': fechaHoraReal?.toIso8601String(),
      'estado': estado.nombre,
    };
  }

  static RegistroToma fromMap(Map<String, dynamic> map) {
    EstadoToma estadoObjeto;
    switch (map['estado']) {
      case 'Tomado':
        estadoObjeto = Tomado();
        break;
      case 'Omitido':
        estadoObjeto = Omitido();
        break;

      default:
        estadoObjeto = Omitido();
    }

    return RegistroToma(
      id: map['id'],
      medicamentoId: map['medicamentoId'],
      horarioId: map['horarioId'],
      fechaHoraEsperada: DateTime.parse(map['fechaHoraEsperada']),
      fechaHoraReal: map['fechaHoraReal'] != null
          ? DateTime.parse(map['fechaHoraReal'])
          : null,
      estado: estadoObjeto,
    );
  }

  void aplicarEstado() {
    estado.aplicar(this);
  }
}
