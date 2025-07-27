import 'package:flutter/material.dart';
import 'package:medicamentos_app/controller/medicamento_dao.dart';
import 'package:medicamentos_app/pages/components/drawer_sccafold.dart';
import 'package:medicamentos_app/models/medicamento.dart';
import 'package:medicamentos_app/pages/editar_medicamento.dart';
import 'package:medicamentos_app/pages/horario_medicamento.dart';
import 'package:medicamentos_app/pages/medicamento.dart';

class MedicamentoListView extends StatefulWidget {
  const MedicamentoListView({super.key});

  @override
  _MedicamentoListViewState createState() => _MedicamentoListViewState();
}

class _MedicamentoListViewState extends State<MedicamentoListView> {
  final MedicamentoDao _dao = MedicamentoDao();
  List<Medicamento> _medicamentos = [];

  @override
  void initState() {
    super.initState();
    _cargarMedicamentos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargarMedicamentos();
  }

  void _cargarMedicamentos() async {
    final lista = await _dao.getAll();
    setState(() {
      _medicamentos = lista;
    });
  }

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

  void _confirmarEliminacion(int id, String nombreMedicamento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '¿Eliminar "$nombreMedicamento"?',
          style: const TextStyle(
            color: Color(0xFF26A69A),
          ), // Título con color de tema
        ),
        content: const Text(
          'Esta acción no se puede deshacer y eliminará todos los horarios asociados a este medicamento. ¿Estás seguro?',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF26A69A)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar el diálogo
              await _dao.delete(id);
              _cargarMedicamentos(); // Recargar la lista de medicamentos
              _showSnackBar(
                'Medicamento "$nombreMedicamento" eliminado.',
                const Color(
                  0xFFEF5350,
                ), // Color rojo para acción de eliminación
                Icons.delete_sweep,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFFEF5350,
              ), // Fondo rojo para el botón de eliminar
              foregroundColor: Colors.white, // Texto blanco
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DrawerScaffold(
        title: 'Mis Medicamentos', // Título más amigable en la AppBar
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
          child: _medicamentos.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons
                              .medication_liquid_outlined, // Ícono más específico y moderno
                          size: 80,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '¡Aún no tienes medicamentos registrados!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4DB6AC), // Color de énfasis
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Presiona el botón "+" para empezar a añadir tus medicinas y organizar tus recordatorios.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0), // Padding para la lista
                  itemCount: _medicamentos.length,
                  itemBuilder: (context, index) {
                    final med = _medicamentos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          15.0,
                        ), // Bordes redondeados
                      ),
                      elevation: 5, // Sombra sutil
                      shadowColor: Colors.black.withOpacity(0.1),
                      color: Colors.white.withOpacity(
                        0.95,
                      ), // Fondo blanco ligeramente transparente
                      child: InkWell(
                        // Añadir InkWell para feedback visual al tocar
                        onTap: () {
                          // Navegar a la pantalla de HorariosMedicamentoScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HorariosMedicamentoScreen(medicamento: med),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(
                                  0xFFB2DFDB,
                                ), // Fondo verde/azulado claro
                                radius: 28,
                                child: const Icon(
                                  Icons
                                      .medical_services_outlined, // Ícono moderno de medicación
                                  size: 30,
                                  color: Color(
                                    0xFF26A69A,
                                  ), // Ícono verde/azulado oscuro
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      med.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),

                                    if (med.descripcion != null &&
                                        med.descripcion!.isNotEmpty)
                                      Text(
                                        med.descripcion!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Text(
                                      'Cantidad: ${med.cantidad} | Dosis: ${med.dosis}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize
                                    .min, // Ajustar tamaño de la columna al contenido
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Color(0xFF4DB6AC),
                                    ), // Ícono de editar verde/azul
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MedicamentoEditView(
                                                medicamento: med,
                                              ),
                                        ),
                                      );
                                      _cargarMedicamentos(); // Recargar al regresar
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      color: Color(0xFFEF5350),
                                    ), // Ícono de eliminar rojo
                                    onPressed: () => _confirmarEliminacion(
                                      med.id!,
                                      med.nombre,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MedicamentoView()),
          );
          _cargarMedicamentos();
        },
        label: const Text(
          'Agregar Medicamento',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add_box_rounded, color: Colors.white),
        backgroundColor: const Color(0xFF26A69A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 6,
      ),
    );
  }
}
