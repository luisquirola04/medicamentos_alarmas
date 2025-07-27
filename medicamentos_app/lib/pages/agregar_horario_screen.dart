import 'dart:convert'; // Import para json.encode
import 'package:flutter/material.dart';
import 'package:medicamentos_app/pages/medicamento_all.dart';
import 'package:workmanager/workmanager.dart';
import 'package:medicamentos_app/controller/horario_dao.dart';
import 'package:medicamentos_app/controller/medicamento_dao.dart';
import 'package:medicamentos_app/pages/components/drawer_sccafold.dart';
import 'package:medicamentos_app/models/medicamento.dart';
import 'package:medicamentos_app/models/horario.dart';
import 'package:medicamentos_app/controller/notificaciones_worker.dart';
import 'package:intl/intl.dart'; // Para formatear la hora en la UI

class AgregarHorarioScreen extends StatefulWidget {
  final int? medicamentoId; // Para poder recibir un ID de medicamento
  const AgregarHorarioScreen({super.key, this.medicamentoId});

  @override
  _AgregarHorarioScreenState createState() => _AgregarHorarioScreenState();
}

class _AgregarHorarioScreenState extends State<AgregarHorarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final MedicamentoDao _medicamentoDao = MedicamentoDao();
  final HorarioDao _horarioDao = HorarioDao();

  List<Medicamento> _medicamentos = [];
  Medicamento? _medicamentoSeleccionado;
  DateTime? _hora;
  double _intervalo = 8.0;

  @override
  void initState() {
    super.initState();
    _cargarMedicamentos();
    _hora =
        DateTime.now(); // Inicializa la hora al tiempo actual para preseleccionar
  }

  // Helper para simular .firstWhereOrNull
  Medicamento? _firstWhereOrNull(
    List<Medicamento> list,
    bool Function(Medicamento) test,
  ) {
    for (var element in list) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }

  void _cargarMedicamentos() async {
    final meds = await _medicamentoDao.getAll();
    setState(() {
      _medicamentos = meds;
      // Intenta seleccionar el medicamento si se pasó un ID
      if (widget.medicamentoId != null) {
        _medicamentoSeleccionado = _firstWhereOrNull(
          _medicamentos,
          (med) => med.id == widget.medicamentoId,
        );
      }
      // Si no se seleccionó por ID y hay medicamentos, selecciona el primero por defecto
      if (_medicamentos.isNotEmpty && _medicamentoSeleccionado == null) {
        _medicamentoSeleccionado = _medicamentos.first;
      }
    });
  }

  void _guardarHorario() async {
    if (_formKey.currentState!.validate() &&
        _hora != null &&
        _medicamentoSeleccionado != null) {
      final horario = Horario(
        intervalo: _intervalo,
        hora: _hora!,
        medicamentoId: _medicamentoSeleccionado!.id!,
      );

      final int? id = await _horarioDao.insert(horario);

      if (id == null) {
        _showSnackBar(
          'Error: No se pudo guardar el horario. Inténtalo de nuevo.',
          Colors.red,
          Icons.error,
        );
        return;
      }

      final cantidadTomas = _medicamentoSeleccionado!.cantidad;

      for (int i = 0; i < cantidadTomas; i++) {
        // Calcula la fecha y hora de la toma
        DateTime fechaToma = _hora!.add(
          Duration(hours: (_intervalo * i).toInt()),
        );

        // Asegúrate de que la fecha de la toma sea en el futuro, si no, avanza un día
        while (fechaToma.isBefore(DateTime.now())) {
          fechaToma = fechaToma.add(const Duration(days: 1));
        }

        // Calcula la diferencia para initialDelay
        final diferencia = fechaToma.difference(DateTime.now());

        // Si la diferencia es negativa después del ajuste (esto no debería ocurrir si el while es efectivo), la saltamos.
        if (diferencia.isNegative) continue;

        Workmanager().registerOneOffTask(
          '${id}_$i', // Nombre único de la tarea
          tareaNotificacion, // El nombre de la tarea definida en el callbackDispatcher
          initialDelay: diferencia,
          inputData: {
            // Envía los objetos completos serializados a JSON
            'med': jsonEncode(_medicamentoSeleccionado!.toMap()),
            'horario': jsonEncode(horario.toMap()),
            'iteracion': i, // El número de toma (0, 1, 2...)
          },
        );
      }

      _showSnackBar(
        'Horario y notificaciones programadas con éxito!',
        const Color(0xFF4CAF50),
        Icons.check_circle_outline,
      );

      if (widget.medicamentoId != null) {
        Navigator.pop(
          context,
          true,
        ); // Vuelve y puede indicar éxito para refrescar
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MedicamentoListView()),
        );
      }
    } else {
      _showSnackBar(
        'Por favor, completa todos los campos requeridos y selecciona una hora válida.',
        Colors.orange,
        Icons.warning_amber_rounded,
      );
    }
  }

  // Helper para mostrar SnackBar con estilo mejorado
  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  // Widget para contenedores estilizados
  Widget _buildStyledContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrawerScaffold(
      title: 'Programar Recordatorio', // Título más descriptivo
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFCCEFF0), Color(0xFFB2DFDB)], // Gradiente suave
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Configura cuándo debes tomar tu medicamento.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4DB6AC), // Color de texto distintivo
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Selector de Medicamento (Dropdown con estilo)
                _buildStyledContainer(
                  child: DropdownButtonFormField<Medicamento>(
                    decoration: const InputDecoration(
                      labelText: 'Selecciona el Medicamento',
                      border: InputBorder.none, // Elimina el borde interno
                      prefixIcon: Icon(
                        Icons.medication,
                        color: Color(0xFF80CBC4),
                      ),
                      contentPadding: EdgeInsets.zero,
                      labelStyle: TextStyle(color: Color(0xFF4DB6AC)),
                    ),
                    items: _medicamentos.map((med) {
                      return DropdownMenuItem(
                        value: med,
                        child: Text(
                          med.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _medicamentoSeleccionado = value),
                    hint: const Text("Seleccionar Medicamento"),
                    validator: (value) => value == null
                        ? 'Por favor selecciona un medicamento'
                        : null,
                    value: _medicamentoSeleccionado,
                    isExpanded: true, // Para que ocupe todo el ancho
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF26A69A),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildStyledContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Intervalo entre tomas (horas)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4DB6AC),
                        ),
                      ),
                      Slider(
                        value: _intervalo,
                        min: 1, // Mínimo 1 hora
                        max: 24, // Máximo 24 horas
                        divisions: 23, // Divisiones para cada hora
                        label:
                            '${_intervalo.round()} horas', // Etiqueta del slider
                        onChanged: (newValue) {
                          setState(() {
                            _intervalo = newValue;
                          });
                        },
                        activeColor: const Color(0xFF26A69A),
                        inactiveColor: const Color(0xFFB2DFDB),
                      ),
                      Center(
                        child: Text(
                          'Cada ${_intervalo.round()} horas',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildStyledContainer(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.access_time,
                      color: Color(0xFF80CBC4),
                    ),
                    title: Text(
                      _hora == null
                          ? 'Seleccionar la Primera Hora de Toma'
                          : 'Primera Toma: ${DateFormat('hh:mm a').format(_hora!)}', // Formato 12 horas
                      style: TextStyle(
                        fontSize: 16,
                        color: _hora == null
                            ? const Color(0xFF4DB6AC)
                            : Colors.black87,
                        fontWeight: _hora == null
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.edit, color: Color(0xFF26A69A)),
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          _hora ?? DateTime.now(),
                        ),
                        builder: (BuildContext context, Widget? child) {
                          // Tema para el TimePicker
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF26A69A), // Color principal
                                onPrimary:
                                    Colors.white, // Texto en color principal
                                surface: Colors.white, // Fondo del picker
                                onSurface: Colors.black87,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF26A69A),
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _hora = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Esta será la hora de tu primera dosis cada día o el punto de inicio para el intervalo.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

                ElevatedButton.icon(
                  onPressed: _guardarHorario,
                  icon: const Icon(Icons.alarm_add),
                  label: const Text(
                    'Programar Recordatorio',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF26A69A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
