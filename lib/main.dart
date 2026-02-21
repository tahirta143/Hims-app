import 'package:flutter/material.dart';
import 'package:hims_app/providers/opd/consultation_provider/cunsultation_provider.dart';
import 'package:hims_app/providers/opd/opd_reciepts/opd_reciepts.dart';
import 'package:hims_app/screens/splash%20screens/splash.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ ConsultationProvider is above ALL routes,
        //    so every screen can access it
        ChangeNotifierProvider(create: (_) => ConsultationProvider()),
        // Add more providers here as your app grows
        ChangeNotifierProvider(create: (_) => OpdProvider()),
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
