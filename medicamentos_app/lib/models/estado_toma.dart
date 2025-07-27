import 'package:medicamentos_app/models/registro_toma.dart';

abstract class EstadoToma {
  String get nombre;
  void aplicar(RegistroToma registro);
}

class Tomado implements EstadoToma {
  @override
  String get nombre => 'Tomado';

  @override
  void aplicar(RegistroToma registro) {
    print("Medicamento tomado a tiempo.");
  }
}

class Omitido implements EstadoToma {
  @override
  String get nombre => 'Omitido';

  @override
  void aplicar(RegistroToma registro) {
    print("Medicamento no fue tomado.");
  }
}
