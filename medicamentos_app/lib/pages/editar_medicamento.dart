import 'package:flutter/material.dart';
import 'package:medicamentos_app/controller/medicamento_dao.dart';
import 'package:medicamentos_app/models/medicamento.dart';

class MedicamentoEditView extends StatefulWidget {
  final Medicamento medicamento;

  const MedicamentoEditView({super.key, required this.medicamento});

  @override
  _MedicamentoEditViewState createState() => _MedicamentoEditViewState();
}

class _MedicamentoEditViewState extends State<MedicamentoEditView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _cantidadController;
  late TextEditingController _dosisController;

  final _dao = MedicamentoDao();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.medicamento.nombre);
    _descripcionController = TextEditingController(
      text: widget.medicamento.descripcion,
    );
    _cantidadController = TextEditingController(
      text: widget.medicamento.cantidad.toString(),
    );
    _dosisController = TextEditingController(
      text: widget.medicamento.dosis.toString(),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _cantidadController.dispose();
    _dosisController.dispose();
    super.dispose();
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

  // Widget para contenedores estilizados (similar al de otras pantallas)
  Widget _buildFieldContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
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

  void _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      final medicamentoActualizado = Medicamento(
        id: widget.medicamento.id,
        nombre: _nombreController.text,

        descripcion: _descripcionController.text.isNotEmpty
            ? _descripcionController.text
            : '',
        cantidad: int.tryParse(_cantidadController.text) ?? 0,
        dosis: double.tryParse(_dosisController.text) ?? 0.0,
        estado: widget.medicamento.estado,
      );

      await _dao.update(medicamentoActualizado);

      _showSnackBar(
        'Medicamento "${medicamentoActualizado.nombre}" actualizado con éxito!',
        const Color(0xFF4CAF50), // Verde para éxito
        Icons.check_circle_outline,
      );

      Navigator.pop(context, true);
    } else {
      _showSnackBar(
        'Por favor, corrige los errores en el formulario.',
        Colors.orange,
        Icons.warning_amber_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Medicamento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF26A69A), // Color de la AppBar
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
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Padding general
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Modifica la información de tu medicamento.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4DB6AC),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Nombre del Medicamento
                _buildFieldContainer(
                  child: TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Medicamento',
                      border: InputBorder
                          .none, // Eliminar el borde del TextFormField
                      icon: Icon(
                        Icons.medication_outlined,
                        color: Color(0xFF80CBC4),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF4DB6AC)),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'El nombre es requerido' : null,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),

                // Descripción
                _buildFieldContainer(
                  child: TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.description_outlined,
                        color: Color(0xFF80CBC4),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF4DB6AC)),
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),

                // Cantidad total
                _buildFieldContainer(
                  child: TextFormField(
                    controller: _cantidadController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad Total (Ej: 30)',
                      border: InputBorder.none,
                      icon: Icon(Icons.numbers, color: Color(0xFF80CBC4)),
                      labelStyle: TextStyle(color: Color(0xFF4DB6AC)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La cantidad es requerida';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Ingresa un número entero positivo';
                      }
                      return null;
                    },
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),

                // Dosis por toma
                _buildFieldContainer(
                  child: TextFormField(
                    controller: _dosisController,
                    decoration: const InputDecoration(
                      labelText: 'Dosis por Toma (Ej: 1.5)',
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.medical_information,
                        color: Color(0xFF80CBC4),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF4DB6AC)),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La dosis es requerida';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Ingresa un número válido (> 0)';
                      }
                      return null;
                    },
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),

                const SizedBox(height: 30),

                // Botón de Guardar Cambios
                ElevatedButton.icon(
                  onPressed: _guardarCambios,
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
