import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _showAlert(String title, String message, bool isError) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          backgroundColor: isError ? Colors.red[50] : Colors.green[50],
          titleTextStyle: TextStyle(
            color: isError ? Colors.red : Colors.green,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(
            color: isError ? Colors.red[900] : Colors.green[900],
            fontSize: 16,
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: isError ? Colors.red : Colors.green,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Função para TENTAR REGISTRAR um novo usuário
  Future<void> _register() async {
    if (!mounted) return;
    
    // Navegar para tela de signup
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  /// Função para TENTAR LOGAR um usuário existente
  Future<void> _login() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Tenta fazer login com e-mail e senha
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      // 2. Se deu certo, mostra sucesso
      await _showAlert(
        'Sucesso',
        'Login realizado com sucesso!',
        false
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
      
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      
      // 3. Trata erros de login
      String errorMessage = "E-mail ou senha incorretos."; 
      if (e.code == 'invalid-email') {
        errorMessage = 'O formato do e-mail é inválido.';
      }
      await _showAlert('Erro no Login', errorMessage, true);
    } catch (e) {
      if (!mounted) return;
      await _showAlert(
        'Erro Inesperado',
        'Ocorreu um erro inesperado: ${e.toString()}',
        true
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Brilho Azul - Login"),
        backgroundColor: Colors.blueAccent, // Um pouco mais vibrante
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView( // Permite rolar se o teclado cobrir a tela
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo de E-mail
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
          
                // Campo de Senha
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Esconde a senha
                  decoration: InputDecoration(
                    labelText: "Senha",
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
          
                // Se _isLoading for true, mostra o CircularProgressIndicator
                if (_isLoading)
                  Center(child: CircularProgressIndicator())
                
                // Se não (else), mostra os botões
                else ...[
                  // Botão de Login
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Login", style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(height: 12.0),
          
                  // Botão de Registro
                  OutlinedButton(
                    onPressed: _register,
                     style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blueAccent),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
}