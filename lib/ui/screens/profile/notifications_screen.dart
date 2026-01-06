import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ysa_app/providers/providers_exports.dart';
import 'package:ysa_app/services/navigation_service.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/ui/widgets/widgets_exports.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int currentIndex = 4;
  String? _selectedSalonFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        if (!authProvider.isAdmin) {
          _selectedSalonFilter = authProvider.currentUser?.idSalon;
        } else {
          _selectedSalonFilter = 'salon_principal';
        }
        _markNotificationsAsRead();
      }
      setState(() {});
    });
  }

  Future<void> _markNotificationsAsRead() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;

    try {
      final alerts = await FirebaseFirestore.instance
          .collection('stock_alerts')
          .where('resolved', isEqualTo: false)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      bool hasChanges = false;

      for (var doc in alerts.docs) {
        List viewedBy = doc.data()['viewedBy'] ?? [];
        if (!viewedBy.contains(userId)) {
          batch.update(doc.reference, {
            'viewedBy': FieldValue.arrayUnion([userId]),
          });
          hasChanges = true;
        }
      }
      if (hasChanges) await batch.commit();
    } catch (e) {
      debugPrint('Error marking read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      drawer: CustomSideMenu(
        userName: authProvider.userName,
        selectedIndex: currentIndex,
        onMenuItemSelected: (index) {
          setState(() => currentIndex = index);
          navigateByIndex(context, index);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'NOTIFICACIONES'),
            
            // REUTILIZAR SalonSelector
            if (authProvider.isAdmin)
              SalonSelector(
                selectedSalon: _selectedSalonFilter,
                onChanged: (value) {
                  setState(() => _selectedSalonFilter = value);
                },
              ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('stock_alerts')
                    .orderBy('timestamp', descending: true)
                    .limit(100)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildStatusState(
                      Icons.error_outline,
                      "Error al cargar notificaciones",
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (_selectedSalonFilter == 'todos') return true;
                    return data['salonId'] == _selectedSalonFilter;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return _buildStatusState(
                      Icons.notifications_none,
                      "Sin notificaciones",
                    );
                  }

                  // AGRUPAR POR FECHA
                  final groupedNotifications = _groupByDate(filteredDocs);

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 4),
                    itemCount: groupedNotifications.keys.length,
                    itemBuilder: (context, index) {
                      final dateKey = groupedNotifications.keys.elementAt(index);
                      final notifications = groupedNotifications[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HEADER DE FECHA
                          _buildDateHeader(dateKey),
                        
                          // NOTIFICACIONES DEL DÍA
                          ...notifications.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final userId = authProvider.currentUser?.id;
                            final viewedBy = data['viewedBy'] as List?;
                            final isUnread = viewedBy == null || !viewedBy.contains(userId);
                            
                            return _buildNotificationItem(data, isUnread);
                          }),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER DE FECHA
  Widget _buildDateHeader(String dateKey) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        _formatDateHeader(dateKey),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ITEM DE NOTIFICACIÓN ESTILO TELÉFONO 
  Widget _buildNotificationItem(Map<String, dynamic> data, bool isUnread) {
    final bool resolved = data['resolved'] ?? false;
    final int stock = data['stock'] is int 
        ? data['stock'] 
        : int.tryParse(data['stock'].toString()) ?? 0;
    final String productName = data['productName'] ?? 'Producto desconocido';
    final String salonId = data['salonId'] ?? '';
    final String salonName = salonId == 'salon_principal' 
        ? 'Salón Principal' 
        : 'Salón Secundario';
    final DateTime? timestamp = (data['timestamp'] as Timestamp?)?.toDate();

    // Colores según urgencia
    final Color iconBgColor = resolved 
        ? Colors.green.shade50
        : (stock == 0 
            ? Colors.red.shade50 
            : (stock <= 2 
                ? Colors.deepOrange.shade50 
                : Colors.orange.shade50));
    
    final Color iconColor = resolved 
        ? AppColors.activeGreen
        : (stock == 0 
            ? AppColors.inactiveRed 
            : (stock <= 2 
                ? Colors.deepOrange 
                : Colors.orange));

    final IconData iconData = resolved
        ? Icons.check_circle
        : (stock == 0 
            ? Icons.error 
            : Icons.warning_amber_rounded);

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: resolved ? Colors.grey.shade50 : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // ACCIÓN DIRECTA: Ir a inventario (sin dialog)
          onTap: resolved 
              ? null 
              : () => Navigator.pushNamed(context, '/inventory'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ICONO DE NOTIFICACIÓN
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // CONTENIDO DE LA NOTIFICACIÓN
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título principal
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 15,
                                  color: resolved 
                                      ? Colors.grey.shade600 
                                      : Colors.black87,
                                  height: 1.3,
                                ),
                                children: [
                                  TextSpan(
                                    text: resolved 
                                        ? 'Stock reabastecido: ' 
                                        : 'Stock bajo: ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // INDICADOR DE NO LEÍDO
                          if (isUnread && !resolved)
                            Container(
                              width: 9,
                              height: 9,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Descripción
                      Text(
                        resolved
                            ? 'Esta alerta ha sido resuelta'
                            : 'Solo quedan $stock unidades en $salonName',
                        style: TextStyle(
                          fontSize: 14,
                          color: resolved 
                              ? Colors.grey.shade500 
                              : Colors.grey.shade700,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Hora y badge
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 13,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timestamp != null 
                                ? _getTimeAgo(timestamp) 
                                : 'Hace un momento',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Spacer(),
                          
                          // Badge de stock
                          if (!resolved)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: iconColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$stock unidades',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // AGRUPAR NOTIFICACIONES POR FECHA
  Map<String, List<QueryDocumentSnapshot>> _groupByDate(
    List<QueryDocumentSnapshot> docs,
  ) {
    final Map<String, List<QueryDocumentSnapshot>> grouped = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

      if (timestamp != null) {
        final dateKey = DateFormat('yyyy-MM-dd').format(timestamp);
        grouped.putIfAbsent(dateKey, () => []);
        grouped[dateKey]!.add(doc);
      }
    }

    return grouped;
  }

  // FORMATEAR HEADER DE FECHA
  String _formatDateHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) return 'HOY';
    if (dateToCheck == yesterday) return 'AYER';
    
    return DateFormat('EEEE, d MMMM yyyy', 'es_ES')
        .format(date)
        .toUpperCase();
  }

  // CALCULAR "HACE CUÁNTO"
  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Hace un momento';
    if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Hace ${difference.inHours} h';
    if (difference.inDays == 1) return 'Ayer';
    return 'Hace ${difference.inDays} días';
  }
}