import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import '../models/medicamento.dart';
import '../models/horario.dart';

class NotificacionesProgramadasScreen extends StatelessWidget {
  final Medicamento medicamento;
  final Horario horario;

  const NotificacionesProgramadasScreen({
    super.key,
    required this.medicamento,
    required this.horario,
  });

  // Widget para contenedores estilizados (similar al de otras pantallas)
  Widget _buildCardContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // Casi opaco
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<DateTime> fechas = [];

    // Lógica para calcular fechas futuras (no se modifica)
    for (int i = 0; i < medicamento.cantidad; i++) {
      final fechaToma = horario.hora.add(
        Duration(hours: (horario.intervalo * i).toInt()),
      );
      // Asegurarse de que la fecha sea en el futuro desde la hora actual
      // Se mantiene la lógica original, que filtra las pasadas
      if (fechaToma.isAfter(now)) {
        fechas.add(fechaToma);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Próximas Dosis', // Título más amigable
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            ], // Degradado de fondo consistente
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medicamento: ${medicamento.nombre}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF26A69A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dosis: ${medicamento.dosis} | Cantidad total: ${medicamento.cantidad}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Intervalo: ${horario.intervalo.round()} horas',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Detalle de las próximas tomas:',
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: fechas.isEmpty
                  ? Center(
                      child: _buildCardContainer(
                        child: const Text(
                          '🎉 No hay notificaciones futuras pendientes para este medicamento por ahora.',
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
                      itemCount: fechas.length,
                      itemBuilder: (context, index) {
                        final fecha = fechas[index];
                        final formattedDate = DateFormat(
                          'EEE, d MMM yyyy',
                        ).format(fecha); // Ej: Sáb, 27 Jul 2025
                        final formattedTime = DateFormat(
                          'hh:mm a',
                        ).format(fecha); // Ej: 11:59 PM

                        return _buildCardContainer(
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFB2DFDB),
                                child: Text(
                                  '${index + 1}', // Número de toma
                                  style: const TextStyle(
                                    color: Color(0xFF26A69A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${formattedDate}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Hora: $formattedTime',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.notifications_active,
                                color: Color(0xFF26A69A),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
