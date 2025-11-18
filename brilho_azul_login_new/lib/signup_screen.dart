import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();
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

  Future<void> _registerUser() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty ||
        _nomeController.text.isEmpty) {
      await _showAlert(
        'Campos Vazios',
        'Por favor, preencha todos os campos obrigatórios',
        true
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Criar usuário no Firebase Auth
      String userId = '';
      try {
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        userId = userCredential.user?.uid ?? '';
      } on TypeError catch (typeErr) {
        // Workaround: houve um problema de decodificação (Pigeon) conhecido em algumas
        // versões dos plugins. A criação pode ter ocorrido no lado nativo, então tentamos
        // recuperar o usuário atual como fallback.
        if (kDebugMode) {
          debugPrint('[SignUp] TypeError durante createUser: $typeErr');
        }

        // Tentativa de recuperar currentUser por alguns instantes
        const int attempts = 6;
        for (int i = 0; i < attempts && userId.isEmpty; i++) {
          final user = _auth.currentUser;
          if (user != null && user.uid.isNotEmpty) {
            userId = user.uid;
            break;
          }
          // aguarda 500ms e tenta novamente
          await Future.delayed(const Duration(milliseconds: 500));
        }

        if (userId.isEmpty) {
          // se ainda não encontramos, rethrow para ser tratado pelos catch externos
          rethrow;
        }
      }

      // Salvar dados no Firestore (com timeout para evitar travamentos)
      await _firestore.collection('users').doc(userId).set({
        'nome': _nomeController.text.trim(),
        'sobrenome': _sobrenomeController.text.trim(),
        'email': _emailController.text.trim(),
        'criadoEm': DateTime.now().toIso8601String(),
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      
      await _showAlert(
        'Sucesso',
        'Usuário registrado com sucesso!',
        false
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Ocorreu um erro no registro';
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca';
      } else if (e.code == 'email-already-in-use') {
        message = 'Este email já está em uso';
      } else if (e.code == 'invalid-email') {
        message = 'Email inválido';
      }
      if (mounted) {
        await _showAlert('Erro no Registro', message, true);
      }
    } catch (e, st) {
      // Log detalhado para ajudar a diagnosticar o erro de cast (PigeonUserDetails etc.)
      if (kDebugMode) {
        debugPrint('[SignUp] Erro inesperado: ${e.runtimeType} -> $e');
        debugPrintStack(label: '[SignUp] Stacktrace:', stackTrace: st);
      }

      if (mounted) {
        await _showAlert(
          'Erro Inesperado',
          'Ocorreu um erro: ${e.toString()}',
          true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar Conta"),
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
                  controller: _nomeController,
                  decoration: _buildInputDecoration("Nome", Icons.person_outline),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _sobrenomeController,
                  decoration: _buildInputDecoration("Sobrenome", Icons.person_outline),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration("E-mail", Icons.email_outlined),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _buildInputDecoration("Senha", Icons.lock_outline),
                ),
                const SizedBox(height: 24.0),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _registerUser,
                    style: _buildButtonStyle(),
                    child: const Text("Registrar", style: TextStyle(fontSize: 16)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
