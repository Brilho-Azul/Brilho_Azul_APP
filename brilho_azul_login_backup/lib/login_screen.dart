import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe o Firebase Auth

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Instância do Firebase Auth para acessar os métodos de autenticação
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controladores para ler o que o usuário digita
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variável para controlar o estado de "carregando" (mostra o ícone de progresso)
  bool _isLoading = false;

  /// Função para TENTAR REGISTRAR um novo usuário
  Future<void> _register() async {
    // 1. Inicia o "carregando"
    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Usa o Firebase Auth para criar um usuário
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(), // .trim() remove espaços em branco
        password: _passwordController.text.trim(),
      );

      // 3. Se deu certo, mostra feedback de sucesso
      _showFeedback("Registro realizado com sucesso!", isError: false);
      
    } on FirebaseAuthException catch (e) {
      // 4. Se deu errado (erro do Firebase), trata os erros mais comuns
      String errorMessage = "Ocorreu um erro.";
      if (e.code == 'weak-password') {
        errorMessage = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Este e-mail já está cadastrado.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'O formato do e-mail é inválido.';
      }
      _showFeedback(errorMessage, isError: true);
    } catch (e) {
      // 5. Outros erros (ex: sem internet)
      _showFeedback("Ocorreu um erro inesperado: $e", isError: true);
    }

    // 6. Para o "carregando"
    setState(() {
      _isLoading = false;
    });
  }

  /// Função para TENTAR LOGAR um usuário existente
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Tenta fazer login com e-mail e senha
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // 2. Se deu certo, mostra sucesso
       _showFeedback("Login realizado com sucesso!", isError: false);
      
      // TODO: Navegar para a tela principal (Home Screen)
      // (Vamos fazer isso no próximo passo, se você quiser)
      // Ex: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      
    } on FirebaseAuthException catch (e) {
      // 3. Trata erros de login
      // 'invalid-credential' é o código moderno para 'user-not-found' ou 'wrong-password'
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

  // Função auxiliar para mostrar uma SnackBar (a barra de notificação inferior)
  void _showFeedback(String message, {bool isError = true}) {
    if (!mounted) return; // Garante que o widget ainda está na tela
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
                    child: Text("Registrar", style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
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