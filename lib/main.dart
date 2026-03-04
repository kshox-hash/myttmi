import "package:flutter/material.dart";
import "package:myttmi/features/shell/splash_gate.dart";
import "package:myttmi/routes/app_routes.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
  title: "MyTTM",
  debugShowCheckedModeBanner: false,
  theme: ThemeData(useMaterial3: true),
  onGenerateRoute: AppRoutes.onGenerateRoute, // ✅ CLAVE
  initialRoute: AppRoutes.splash,              // ✅ opcional (recomendado)
);

  }
}
