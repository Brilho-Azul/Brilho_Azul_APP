import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Importe a tela de login para onde voltaremos

class HomeScreen extends StatelessWidget {
  // Recebe o nome do usuário da tela de login
  final String nome;

  const HomeScreen({super.key, required this.nome});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    
    // Navega de volta ao Login e remove todas as telas anteriores (para não poder "voltar")
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false, // Remove todas as rotas
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Página Inicial"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context), // Chama a função de logout
            tooltip: "Sair",
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Bem-vindo, $nome!", // Exibe a mensagem de boas-vindas
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}