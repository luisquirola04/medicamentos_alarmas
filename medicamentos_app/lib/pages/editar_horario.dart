import 'package:flutter/material.dart';
import 'package:medicamentos_app/controller/horario_dao.dart';
import 'package:medicamentos_app/models/horario.dart';
import 'package:medicamentos_app/models/medicamento.dart';
import 'dart:convert';
import 'package:medicamentos_app/controller/notificaciones_worker.dart';
import 'package:medicamentos_app/controller/notificaciones_helper.dart'; // Asegúrate de que esto esté importado
import 'package:workmanager/workmanager.dart';
import 'package:intl/intl.dart'; // Para formatear la hora en la UI

class EditarHorarioScreen extends StatefulWidget {
  final Horario horario;
  final Medicamento medicamento;

  const EditarHorarioScreen({
    super.key,
    required this.horario,
    required this.medicamento,
  });

  @override
  _EditarHorarioScreenState createState() => _EditarHorarioScreenState();
}

class _EditarHorarioScreenState extends State<EditarHorarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final HorarioDao _horarioDao = HorarioDao();

  late DateTime _hora;
  late double _intervalo;

  @override
  void initState() {
    super.initState();
    _hora = widget.horario.hora;
    _intervalo = widget.horario.intervalo;
  }

  void _actualizarHorario() async {
    if (_formKey.currentState!.validate()) {
      final nuevoHorario = Horario(
        id: widget.horario.id,
        intervalo: _intervalo,
        hora: _hora,
        medicamentoId: widget.horario.medicamentoId,
      );

      // 1. Cancelar notificaciones antiguas asociadas a este horario
      await cancelarNotificacionesDeHorario(
        widget.horario.id!,
        widget.medicamento.cantidad,
      );

      // 2. Actualizar el horario en la base de datos
      await _horarioDao.update(nuevoHorario);

      // 3. Programar las nuevas notificaciones
      for (int i = 0; i < widget.medicamento.cantidad; i++) {
        // Calcula la fecha y hora de la toma
        DateTime fechaToma = _hora.add(
          Duration(hours: (_intervalo * i).toInt()),
        );

        // Ajusta la fecha para que sea en el futuro
        while (fechaToma.isBefore(DateTime.now())) {
          fechaToma = fechaToma.add(const Duration(days: 1));
        }

        // Calcula la diferencia para initialDelay
        final diferencia = fechaToma.difference(DateTime.now());

        // Si la diferencia es negativa después del ajuste (no debería ocurrir), la saltamos.
        if (diferencia.isNegative) continue;

        Workmanager().registerOneOffTask(
          '${nuevoHorario.id}_$i', // Nombre único de la tarea
          tareaNotificacion,
          initialDelay: diferencia,
          inputData: {
            'med': jsonEncode(widget.medicamento.toMap()),
            'horario': jsonEncode(nuevoHorario.toMap()),
            'iteracion': i,
          },
        );
      }

      _showSnackBar(
        'Horario actualizado y notificaciones reprogramadas!',
        const Color(0xFF4CAF50),
        Icons.check_circle_outline,
      );

      Navigator.pop(context); // Volver a la pantalla anterior
    } else {
      _showSnackBar(
        'Por favor, verifica los campos. Asegúrate de que el intervalo sea válido.',
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
    return Scaffold(
      // Mantener Scaffold si no usa DrawerScaffold
      appBar: AppBar(
        title: const Text(
          'Editar Horario',
          style: TextStyle(color: Colors.white), // Texto blanco para contraste
        ),
        backgroundColor: const Color(0xFF26A69A), // Color de la app bar
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Icono de retroceso blanco
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFCCEFF0),
              Color(0xFFB2DFDB),
            ], // Gradiente de fondo
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              // Usar ListView para evitar overflow si hay muchos elementos
              children: [
                const Text(
                  'Ajusta la hora o el intervalo de este recordatorio.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4DB6AC),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Nombre del Medicamento (solo visualización)
                _buildStyledContainer(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.medical_services,
                      color: Color(0xFF80CBC4),
                    ),
                    title: Text(
                      'Medicamento: ${widget.medicamento.nombre}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Slider para el Intervalo (igual que en AgregarHorarioScreen)
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
                        min: 1,
                        max: 24,
                        divisions: 23,
                        label: '${_intervalo.round()} horas',
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

                // Selector de Hora (igual que en AgregarHorarioScreen)
                _buildStyledContainer(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.access_time,
                      color: Color(0xFF80CBC4),
                    ),
                    title: Text(
                      'Hora de la Primera Toma: ${DateFormat('hh:mm a').format(_hora)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: const Icon(Icons.edit, color: Color(0xFF26A69A)),
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_hora),
                        builder: (BuildContext context, Widget? child) {
                          // Tema para el TimePicker
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF26A69A),
                                onPrimary: Colors.white,
                                surface: Colors.white,
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
                          // Mantiene la fecha original de _hora, solo actualiza la hora y el minuto.
                          // Esto es importante para que la hora de inicio no "salte" a la fecha actual si no es lo que se desea.
                          _hora = DateTime(
                            _hora.year,
                            _hora.month,
                            _hora.day,
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
                    'La hora que selecciones será el punto de inicio para la programación de las dosis.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

                // Botón de Guardar Cambios (igual que en AgregarHorarioScreen)
                ElevatedButton.icon(
                  onPressed: _actualizarHorario,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Guardar Cambios',
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
