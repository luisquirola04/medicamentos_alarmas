class Horario {
  int? id;
  double intervalo;
  DateTime hora;
  int medicamentoId;

  Horario({
    this.id,
    required this.intervalo,
    required this.hora,
    required this.medicamentoId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'intervalo': intervalo,
      'hora': hora.toIso8601String(),
      'medicamentoId': medicamentoId,
    };
  }

  static Horario fromMap(Map<String, dynamic> map) {
    return Horario(
      id: map['id'],
      intervalo: map['intervalo'],
      hora: DateTime.parse(map['hora']),
      medicamentoId: map['medicamentoId'],
    );
  }
}
