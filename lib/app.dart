import 'package:flutter/material.dart';
import 'package:myttmi/routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyTTM',

      //rutas
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,

      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
    );
  }
}
