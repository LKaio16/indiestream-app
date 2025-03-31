import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class CriarProjetoScreen extends StatefulWidget {
  const CriarProjetoScreen({super.key});

  @override
  State<CriarProjetoScreen> createState() => _CriarProjetoScreenState();
}

class _CriarProjetoScreenState extends State<CriarProjetoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _localizacaoController = TextEditingController();
  final TextEditingController _imagemController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();

  String _status = "Em andamento";
  String _error = "";
  bool _isLoading = false;

  Future<void> _criarProjeto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = "";
    });

    try {
      final userId = await AuthService.getUserId();

      if (userId == null) {
        setState(() {
          _error = "Usuário não está logado. Faça login novamente.";
          _isLoading = false;
        });
        return;
      }

      final novoProjeto = {
        "titulo": _tituloController.text,
        "descricao": _descricaoController.text,
        "localizacao": _localizacaoController.text,
        "imagemUrl": _imagemController.text,
        "tipo": _tipoController.text,
        "status": _status,
        "pessoasEnvolvidas": [{"id": userId}],
      };

      final response = await http.post(
        Uri.parse("http://localhost:8080/projetos?usuarioCriadorId=$userId"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(novoProjeto),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _error = errorData['message'] ?? "Erro ao criar o projeto";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Erro de conexão: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Criar Novo Projeto"),
        backgroundColor: Colors.grey[900],
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Logo
              Image.asset(
                'assets/logo.png',
                height: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                "Criar novo projeto",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Campo Título
              _buildTextField(
                controller: _tituloController,
                label: "Título",
                hint: "Insira o título do projeto",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  if (value.length < 3) {
                    return 'O título deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),

              // Campo Descrição
              _buildTextArea(
                controller: _descricaoController,
                label: "Descrição",
                hint: "Insira uma breve descrição",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  if (value.length < 10) {
                    return 'A descrição deve ter pelo menos 10 caracteres';
                  }
                  return null;
                },
              ),

              // Campo Localização
              _buildTextField(
                controller: _localizacaoController,
                label: "Localização",
                hint: "Insira a localização",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a localização';
                  }
                  return null;
                },
              ),

              // Campo URL da Imagem
              _buildTextField(
                controller: _imagemController,
                label: "URL da Imagem",
                hint: "Insira o link da imagem do projeto",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a URL da imagem';
                  }
                  if (!Uri.parse(value).isAbsolute) {
                    return 'Por favor, insira uma URL válida';
                  }
                  return null;
                },
              ),

              // Campo Tipo
              _buildTextField(
                controller: _tipoController,
                label: "Tipo",
                hint: "Ex: Filme, Série, Documentário",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o tipo do projeto';
                  }
                  return null;
                },
              ),

              // Campo Status (Dropdown)
              _buildDropdown(),

              // Mensagem de erro
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _error,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),

              // Botão Criar Projeto
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _criarProjeto,
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 3,
                    ),
                  )
                      : const Text(
                    "CRIAR PROJETO",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              errorStyle: const TextStyle(color: Colors.red),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              errorStyle: const TextStyle(color: Colors.red),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Status",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _status,
                isExpanded: true,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(
                    value: "Em andamento",
                    child: Text("Em andamento"),
                  ),
                  DropdownMenuItem(
                    value: "Concluído",
                    child: Text("Concluído"),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _status = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _localizacaoController.dispose();
    _imagemController.dispose();
    _tipoController.dispose();
    super.dispose();
  }
}