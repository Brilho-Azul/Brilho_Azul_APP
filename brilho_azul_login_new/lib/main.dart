import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importe o core
import 'firebase_options.dart'; // Importe as opções geradas pelo FlutterFire
import 'login_screen.dart'; // Vamos criar este arquivo a seguir

void main() async {
  // Garante que os bindings do Flutter sejam inicializados
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Inicializa o Firebase usando o arquivo firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Brilho Azul',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Você pode mudar para Colors.deepPurple se preferir
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Remove a faixa "Debug"
      home: LoginScreen(), // Nossa tela de login será a tela inicial
    );
  }
}