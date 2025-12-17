import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/models/models_exports.dart';
import '../../widgets/widgets_exports.dart';

class EditPersonalScreen extends StatefulWidget {
  final UserModel user;

  const EditPersonalScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditPersonalScreen> createState() => _EditPersonalScreenState();
}

class _EditPersonalScreenState extends State<EditPersonalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;

  String? _selectedSalon;
  String? _selectedRol;

  final List<Map<String, String>> _salones = [
    {'id': 'salon_principal', 'nombre': 'Salón Principal'},
    {'id': 'salon_secundario', 'nombre': 'Salón Secundario'},
  ];

  final List<Map<String, String>> _roles = [
    {'id': 'admin', 'nombre': 'Administradora'},
    {'id': 'personal', 'nombre': 'Personal'},
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.user.nombreUsuario);
    _selectedSalon = widget.user.idSalon;
    _selectedRol = widget.user.idRol;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _actualizarPersonal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

     FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.user.id)
          .update({
        'nombreUsuario': _nombreController.text.trim(),
        'idSalon': _selectedSalon,
        'idRol': _selectedRol,
      });

      if (!mounted) return;

      SuccessDialog.show(context, 'Personal actualizado correctamente');
      
      // Cerrar la pantalla después del dialog
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      if (!mounted) return;

      // Mantener SnackBar para errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: AppColors.inactiveRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondary,
          systemOverlayStyle: SystemUiOverlayStyle.dark, 
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Editar Personal',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: Colors.grey[200],
              height: 1,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 30),
                CustomFormField(
                  label: 'Nombre completo',
                  controller: _nombreController,
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Correo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: Colors.grey[500],
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.user.email,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Icon(
                            Icons.lock_outline,
                            color: Colors.grey[400],
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomDropdownField2(
                  label: 'Salón',
                  value: _selectedSalon,
                  icon: Icons.store_outlined,
                  items: _salones,
                  onChanged: (value) => setState(() => _selectedSalon = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona un salón';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomDropdownField2(
                  label: 'Rol',
                  value: _selectedRol,
                  icon: Icons.badge_outlined,
                  items: _roles,
                  onChanged: (value) => setState(() => _selectedRol = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona un rol';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  text: 'ACTUALIZAR',
                  onPressed: _actualizarPersonal,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
  }
}