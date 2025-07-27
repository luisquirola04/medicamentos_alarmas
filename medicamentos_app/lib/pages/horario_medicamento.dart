import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicamentos_app/controller/horario_dao.dart';
import 'package:medicamentos_app/pages/agregar_horario_screen.dart';
import 'package:medicamentos_app/pages/editar_horario.dart';
import 'package:medicamentos_app/pages/notificaciones_programadas.dart';
import '../models/horario.dart';
import '../models/medicamento.dart';
import 'package:medicamentos_app/controller/notificaciones_helper.dart';

class HorariosMedicamentoScreen extends StatefulWidget {
  final Medicamento medicamento;

  const HorariosMedicamentoScreen({super.key, required this.medicamento});

  @override
  _HorariosMedicamentoScreenState createState() =>
      _HorariosMedicamentoScreenState();
}

class _HorariosMedicamentoScreenState extends State<HorariosMedicamentoScreen> {
  final HorarioDao _horarioDao = HorarioDao();
  List<Horario> _horarios = [];

  @override
  void initState() {
    super.initState();
    _cargarHorarios();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _cargarHorarios();
  }

  void _cargarHorarios() async {
    final lista = await _horarioDao.getByMedicamentoId(widget.medicamento.id!);
    setState(() {
      _horarios = lista;
    });
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

  Widget _buildCardContainer({
    required Widget child,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  void _mostrarOpciones(Horario horario) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _buildCardContainer(
          margin: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text(
                  'Opciones para Horario (${DateFormat('hh:mm a').format(horario.hora)})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF26A69A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(height: 1, color: Color(0xFFB2DFDB)),

              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF26A69A)),
                title: const Text(
                  'Editar Horario',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () async {
                  Navigator.pop(context); // Cerrar bottom sheet
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditarHorarioScreen(
                        horario: horario,
                        medicamento: widget.medicamento,
                      ),
                    ),
                  );
                  if (result == true) {
                    _cargarHorarios();
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.notifications_active,
                  color: Color(0xFF4DB6AC),
                ),
                title: const Text(
                  'Ver Notificaciones Programadas',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context); // Cerrar bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificacionesProgramadasScreen(
                        medicamento: widget.medicamento,
                        horario: horario,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_forever,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Eliminar Horario',
                  style: TextStyle(fontSize: 16, color: Colors.redAccent),
                ),
                onTap: () async {
                  Navigator.pop(context); // Cerrar bottom sheet
                  final confirmado = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        'Confirmar Eliminación',
                        style: TextStyle(color: Color(0xFF26A69A)),
                      ),
                      content: const Text(
                        '¿Estás seguro de que deseas eliminar este horario?\n\n¡Se cancelarán todas las notificaciones asociadas a este horario!',
                        style: TextStyle(color: Colors.black87),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Color(0xFF26A69A)),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmado == true) {
                    await cancelarNotificacionesDeHorario(
                      horario.id!,
                      widget.medicamento.cantidad,
                    );
                    await _horarioDao.delete(horario.id!);
                    _cargarHorarios(); // Refrescar la lista
                    _showSnackBar(
                      "Horario eliminado y notificaciones canceladas.",
                      const Color(0xFFEF5350), // Rojo para eliminación
                      Icons.delete_sweep,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Horarios de ${widget.medicamento.nombre}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF26A69A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFCCEFF0), Color(0xFFB2DFDB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
              child: _buildCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles de ${widget.medicamento.nombre}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF26A69A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dosis por toma: ${widget.medicamento.dosis}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Cantidad total: ${widget.medicamento.cantidad}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    if (widget.medicamento.descripcion != null &&
                        widget.medicamento.descripcion!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Descripción: ${widget.medicamento.descripcion}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: _horarios.isEmpty
                  ? Center(
                      child: _buildCardContainer(
                        child: const Text(
                          'Aún no has programado horarios para este medicamento.\n¡Presiona el botón "+" para agregar uno!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _horarios.length,
                      itemBuilder: (context, index) {
                        final horario = _horarios[index];
                        return _buildCardContainer(
                          child: InkWell(
                            onTap: () => _mostrarOpciones(horario),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFFB2DFDB),
                                    radius: 25,
                                    child: Icon(
                                      Icons.alarm,
                                      color: const Color(0xFF26A69A),
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Primera Toma: ${DateFormat('hh:mm a').format(horario.hora)}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Cada ${horario.intervalo.toInt()} horas',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.more_vert,
                                    color: Colors.grey,
                                    size: 28,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AgregarHorarioScreen(medicamentoId: widget.medicamento.id),
            ),
          );
          if (result == true) {
            _cargarHorarios();
          }
        },
        label: const Text(
          'Agregar Horario',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add_alarm, color: Colors.white),
        backgroundColor: const Color(0xFF26A69A), // Color del FAB
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 6,
      ),
    );
  }
}
