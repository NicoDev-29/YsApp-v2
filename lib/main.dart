import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/providers_exports.dart';
import 'package:ysa_app/services/services_exports.dart';
import 'ui/screens/screens_exports.dart';
import 'themes/theme.dart';
import 'ui/widgets/widgets_exports.dart';
import 'package:intl/date_symbol_data_local.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_ES', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // INICIALIZAR NOTIFICACIONES
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'YsApp Salones',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/sales': (context) => SalesScreen(),
        '/transactions': (context) => TransactionsScreen(),
        '/inventory': (context) => InventoryScreen(),
        '/users': (context) => PersonalScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/reports/low-stock': (context) => const LowStockScreen(),
        '/reports/sales-summary': (context) => const SalesReportScreen(),
        '/reports/top-products': (context) => const TopProductsScreen(),
        '/reports/top-services': (context) => const TopServicesScreen(),
        '/reports/worker-sales': (context) => const WorkerSalesReportScreen(),
      },
    );
  }
}