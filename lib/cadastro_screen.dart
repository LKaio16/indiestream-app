import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // Import for JSON encoding/decoding
import 'login_screen.dart';

class CadastroScreen extends StatefulWidget {
  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  String? perfilSelecionado;
  final List<String> listaPerfis = ["Artista", "Fã", "Produtor", "Outro"];

  // Text controllers for the input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmaSenhaController = TextEditingController();

  // Hardcoded mapping of profession names to hypothetical IDs
  // In a real app, fetch this from the backend
  final Map<String, int> profissaoIds = {
    "Artista": 1,
    "Fã": 2,
    "Produtor": 3,
    "Outro": 4,
  };

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _emailController.dispose();
    _nomeController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

  // Function to handle user registration
  Future<void> _realizarCadastro() async {
    // Basic validation
    if (_senhaController.text != _confirmaSenhaController.text) {
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('As senhas não coincidem!')),
      );
      return;
    }

    if (perfilSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecione sua profissão!')),
      );
      return;
    }

    // Get the selected profession ID
    final int? profissaoId = profissaoIds[perfilSelecionado!];

    if (profissaoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter o ID da profissão selecionada.')),
      );
      return;
    }


    // Prepare the data to be sent to the backend
    final userData = {
      'email': _emailController.text,
      'nome': _nomeController.text,
      'senha': _senhaController.text,
      'profissao': { // Send profession as a nested object with ID
        'id': profissaoId,
        // If backend requires other profession details, add them here (e.g., 'nome': perfilSelecionado!)
        // However, based on the Usuario model, only the ID within Profissao might be needed for association
      },
      // Add other fields if required by your backend's Usuario model for creation
      'username': _emailController.text, // Assuming username is the email for simplicity
      'imagemUrl': null, // Or a default image URL
      'dataNascimento': null, // Or collect this data in the UI
      'habilidades': [], // Or collect this data
      'estado': null, // Or collect this data
      'cidade': null, // Or collect this data
      'premium': false, // Default value
      'redesSociais': [], // Or collect this data
      'sobreMin': null, // Or collect this data
      'obrasFavoritas': [], // Or handle this later
    };

    // Backend URL (replace with your actual backend URL)
    const String apiUrl = 'http://localhost:8080/user'; // Adjust port if needed

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration successful
        print('Usuário cadastrado com sucesso!');
        // Navigate to the login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        // Registration failed
        print('Erro ao cadastrar usuário: ${response.statusCode}');
        print('Response body: ${response.body}');
        // Show an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar usuário. Tente novamente.')),
        );
      }
    } catch (e) {
      // Handle network errors
      print('Erro de rede durante o cadastro: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão. Verifique sua internet ou o servidor.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1D1D),
      body: Center(
        child: SingleChildScrollView( // Added to prevent overflow on smaller screens
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ---- LOGO ----
              Image.asset(
                'assets/logo.png',
                height: 80,
              ),
              const SizedBox(height: 20),

              // ---- TÍTULO ----
              Text(
                "Crie sua Conta",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              SizedBox(height: 15),

              // ---- CAMPOS DE TEXTO ----
              _campoTexto("Email", "Insira seu Email", controller: _emailController),
              _campoTexto("Nome", "Insira seu nome", controller: _nomeController),
              _campoTexto("Senha", "Insira sua senha", controller: _senhaController, isSenha: true),
              _campoTexto("Confirme Senha", "Confirme sua senha", controller: _confirmaSenhaController, isSenha: true),

              // ---- SELEÇÃO DE PERFIL ----
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Profissão", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10),
                margin: EdgeInsets.only(top: 5, bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: perfilSelecionado,
                    hint: Text("Selecione seu perfil", style: TextStyle(color: Colors.black54)),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black), // Ícone de seta
                    items: listaPerfis.map((String valor) {
                      return DropdownMenuItem<String>(
                        value: valor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(valor, style: TextStyle(color: Colors.black87)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? novoValor) {
                      setState(() {
                        perfilSelecionado = novoValor;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              // ---- BOTÃO AVANÇAR ----
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                onPressed: _realizarCadastro, // Call the registration function
                child: Text(
                  "Avançar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              SizedBox(height: 20),
              // ------ Separação "OU" ------
              Text(
                "- OU -",
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: 10),

              // ------ Link "Já possui conta? Entre" ------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Já possui conta? ",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      "Entrar",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 10), // Added for spacing below the row
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- COMPONENTE PARA CAMPOS DE TEXTO ----
  Widget _campoTexto(String rotulo, String dica, {TextEditingController? controller, bool isSenha = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 5),
        TextField(
          controller: controller, // Assign the controller
          obscureText: isSenha,
          style: TextStyle(color: Colors.black87), // Set text color
          decoration: InputDecoration(
            hintText: dica,
            hintStyle: TextStyle(color: Colors.black54), // Set hint text color
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}