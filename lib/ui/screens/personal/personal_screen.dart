import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/services/navigation_service.dart';
import 'package:ysa_app/themes/theme.dart';
import '../../widgets/widgets_exports.dart';
import '../screens_exports.dart';
import 'package:ysa_app/models/models_exports.dart';
import 'package:ysa_app/providers/providers_exports.dart';


class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  int currentIndex = 3;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Filtro de rol
  String _rolFilter = 'todos';

  @override
  void initState() {
    super.initState();
    // Verificar permisos al cargar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccess();
    });
  }

  void _checkAccess() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isAdmin) {
      // Redirigir a Ventas si no es admin
      Navigator.of(context).pushReplacementNamed('/sales');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> toggleActive(UserModel user) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // PROTECCIÓN: No permitir que un usuario se desactive a sí mismo
    if (user.id == authProvider.currentUser?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes desactivar tu propia cuenta'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            user.activo ? '¿Desactivar usuario?' : '¿Activar usuario?',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.activo
                    ? 'Estás a punto de desactivar a:'
                    : 'Estás a punto de activar a:',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.nombreUsuario,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (user.activo) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'El usuario no podrá iniciar sesión hasta que sea reactivado.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: user.activo ? Colors.orange : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                user.activo ? 'Desactivar' : 'Activar',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final docRef = FirebaseFirestore.instance.collection('usuarios').doc(user.id);
      await docRef.update({'activo': !user.activo});
      
      if (!mounted) return;
      
      SuccessDialog.show(
        context,
        user.activo 
            ? '${user.nombreUsuario} ha sido desactivado' 
            : '${user.nombreUsuario} ha sido activado',
      );
    }
  }

  void _navigateToAddPersonal() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddPersonalScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  // Widget de filtros por rol
  Widget _buildRoleFilters() {
    final filters = [
      {'value': 'todos', 'label': 'Todos', 'icon': Icons.people_outline},
      {'value': 'admin', 'label': 'Administradoras', 'icon': Icons.admin_panel_settings_outlined},
      {'value': 'personal', 'label': 'Personal', 'icon': Icons.work_outline},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _rolFilter == filter['value'];
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                  const SizedBox(width: 6),
                  Text(filter['label'] as String),
                ],
              ),
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onSelected: (selected) {
                setState(() {
                  _rolFilter = filter['value'] as String;
                });
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final nombreUsuario = authProvider.userName;
    final isAdmin = authProvider.isAdmin;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        drawer: CustomSideMenu(
          userName: nombreUsuario,
          selectedIndex: currentIndex,
          onMenuItemSelected: (index) {
            setState(() {
              currentIndex = index;
            });
            navigateByIndex(context, index);
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header con widget reutilizable
              CustomAppBar(
                title: 'PERSONAL',
                showAddButton: isAdmin,
                onAddPressed: isAdmin ? _navigateToAddPersonal : null,
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Buscador con widget reutilizable
                      CustomSearchBar(
                        controller: _searchController,
                        hintText: 'Buscar personal',
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Filtros de rol
                      _buildRoleFilters(),
                      
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('usuarios')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return EmptyStateWidget(
                                icon: Icons.person_outline,
                                message: 'No hay personal registrado',
                                buttonText: isAdmin ? 'Añadir personal' : null,
                                onButtonPressed: isAdmin ? _navigateToAddPersonal : null,
                              );
                            }

                            // Filtrar usuarios
                            final users = snapshot.data!.docs
                                .map((doc) => UserModel.fromFirestore(doc))
                                .where((user) {
                                  // Filtro por búsqueda
                                  if (_searchQuery.isNotEmpty) {
                                    final matchesSearch = 
                                        user.nombreUsuario.toLowerCase().contains(_searchQuery) ||
                                        user.email.toLowerCase().contains(_searchQuery);
                                    if (!matchesSearch) return false;
                                  }
                                  
                                  // Filtro por rol
                                  if (_rolFilter == 'todos') {
                                    return true;
                                  } else if (_rolFilter == 'admin') {
                                    return user.isAdmin;
                                  } else if (_rolFilter == 'personal') {
                                    return user.isPersonal;
                                  }
                                  
                                  return true;
                                })
                                .toList();

                            if (users.isEmpty) {
                              return const EmptyStateWidget(
                                icon: Icons.search_off,
                                message: 'No se encontraron resultados',
                              );
                            }

                            return ListView.builder(
                              itemCount: users.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return PersonalCard(
                                  name: user.nombreUsuario,
                                  email: user.email,
                                  salon: user.idSalon,
                                  rol: user.roleName,
                                  isActive: user.activo,
                                  onEdit: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) =>
                                            EditPersonalScreen(user: user),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.ease;
                                          final tween = Tween(begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));
                                          final offsetAnimation = animation.drive(tween);
                                          return SlideTransition(position: offsetAnimation, child: child);
                                        },
                                      ),
                                    );
                                  },
                                  onToggleActive: () => toggleActive(user),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}