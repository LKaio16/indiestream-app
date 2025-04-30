import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Este import pode não ser mais necessário nesta tela se AuthService lida com isso internamente
import 'auth_service.dart';
import 'cadastro_screen.dart';
import 'config_page.dart' as config; // Importado com alias
import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> _login() async {
    setState(() => _isLoading = true);

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        // Idealmente, use uma URL base de um arquivo de configuração
        // Uri.parse("${config.backendBaseUrl}/user/login"),
        Uri.parse("http://localhost:8080/user/login"), // Mantido o original por enquanto
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "senha": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)); // Decodifica com suporte a UTF8

        // ASSUMINDO que o backend retorna 'token' e 'id' no corpo 200
        final String? token = data['token']; // Obtém o token da resposta
        final int? userId = data['id'];     // Obtém o ID do usuário da resposta

        if (token != null && userId != null) {
          // Salva o token de forma segura (usando flutter_secure_storage)
          await AuthService.saveToken(token);
          // Salva o ID do usuário (usando SharedPreferences)
          await AuthService.saveUserId(userId);


          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Login bem-sucedido')),
          );

          // Navega para a HomeScreen, substituindo a tela de login
          // Usando pushReplacementNamed para consistência com o roteamento no main.dart
          Navigator.pushReplacementNamed(context, '/home');

        } else {
          // Resposta 200, mas faltando dados essenciais
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resposta do servidor incompleta: Token ou ID ausente.')),
          );
        }

      } else {
        // Lida com respostas não-200
        String errorMessage = 'Erro desconhecido';
        try {
          // Tenta extrair a mensagem de erro do corpo da resposta se for JSON
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorData['message'] ?? 'Erro no login';
        } catch (e) {
          // Se não for JSON ou a mensagem não existir
          errorMessage = 'Erro no servidor: Status ${response.statusCode}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // Lida com erros de conexão ou outras exceções
      print("Erro durante o login: $e"); // Log do erro para depuração
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao conectar ao servidor. Verifique a conexão e o endereço.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1D1D),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => config.PaginaConfiguracao()),
                    );
                  },
                  child: Image.asset(
                    'assets/logo.png',
                    height: 80,
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Faça login em sua conta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Align( // Removido const desnecessário se houver algum erro
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[800],
                    hintText: 'Insira seu email',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                const Align( // Removido const desnecessário se houver algum erro
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Senha',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[900],
                    hintText: 'Insira sua senha',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {}, // Esqueceu a senha action
                    child: const Text(
                      'Esqueceu a senha',
                      style: TextStyle(color: Colors.yellow),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '- OU -',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não possui conta?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CadastroScreen()),
                        );
                      },
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}