import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe o Firestore
import 'signup_screen.dart'; // Importe a nova tela de cadastro
import 'home_screen.dart'; // Importe a nova tela inicial

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Instâncias do Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controladores
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  /// Função para TENTAR LOGAR e buscar dados
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Tenta fazer login no Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Se o login deu certo, pegue o UID
      String userId = userCredential.user!.uid;

      // 2. Buscar o documento do usuário no Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      String nome = "Usuário"; // Valor padrão
      if (userDoc.exists) {
        // Pega o campo 'nome' do documento
        nome = (userDoc.data() as Map<String, dynamic>)['nome'];
      }

      // 3. Navegar para a HomeScreen, passando o nome
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(nome: nome),
          ),
        );
      }

    } on FirebaseAuthException catch (e) {
      String errorMessage = "E-mail ou senha incorretos.";
      if (e.code == 'invalid-email') {
        errorMessage = 'O formato do e-mail é inválido.';
      }
      _showFeedback(errorMessage, isError: true);
    } catch (e) {
      _showFeedback("Ocorreu um erro inesperado: $e", isError: true);
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Função para navegar para a tela de registro
  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  // Função de feedback
  void _showFeedback(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Brilho Azul - Login"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration("E-mail", Icons.email_outlined),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _buildInputDecoration("Senha", Icons.lock_outline),
                ),
                SizedBox(height: 24.0),
                if (_isLoading)
                  Center(child: CircularProgressIndicator())
                else ...[
                  ElevatedButton(
                    onPressed: _login,
                    style: _buildButtonStyle(),
                    child: Text("Login", style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(height: 12.0),
                  OutlinedButton(
                    onPressed: _goToSignUp, // MUDANÇA AQUI
                    style: _buildOutlinedButtonStyle(),
                    child: Text("Criar Conta", style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Funções de estilo para reuso
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  ButtonStyle _buildOutlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.blueAccent),
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}