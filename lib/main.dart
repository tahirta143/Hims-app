import 'package:flutter/material.dart';
import 'package:hims_app/providers/emergency_treatment_provider/emergency_provider.dart';
import 'package:hims_app/providers/mr_provider/mr_provider.dart';
import 'package:hims_app/providers/opd/consultation_provider/cunsultation_provider.dart';
import 'package:hims_app/providers/opd/opd_reciepts/opd_reciepts.dart';
import 'package:hims_app/providers/shift_management/shift_management.dart';
import 'package:hims_app/screens/splash%20screens/splash.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}
// In your main.dart or a separate file
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ ConsultationProvider is above ALL routes,
        //    so every screen can access it
        ChangeNotifierProvider(create: (_) => ConsultationProvider()),
        ChangeNotifierProvider(create: (_) => OpdProvider()),
        ChangeNotifierProvider(create: (_)=> EmergencyProvider()),
        ChangeNotifierProvider(create: (_)=> MrProvider()),
        ChangeNotifierProvider(create: (_)=> ShiftProvider()),
      ],
      child: MaterialApp(
        title: 'HIMS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1ABC9C)),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
