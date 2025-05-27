// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart'; // Certifique-se de que este import está correto
import 'package:google_fonts/google_fonts.dart'; // Adicionado Google Fonts para consistência
// import 'package:indiestream_app/AppColors.dart'; // Importe AppColors se definido

class CriarProjetoScreen extends StatefulWidget {
  const CriarProjetoScreen({super.key});

  @override
  State<CriarProjetoScreen> createState() => _CriarProjetoScreenState();
}

class _CriarProjetoScreenState extends State<CriarProjetoScreen> {
  final _formKey = GlobalKey<FormState>();
  // Add a GlobalKey for the Status Dropdown's FormField
  final GlobalKey<FormFieldState<String>> _statusFieldKey =
  GlobalKey<FormFieldState<String>>();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _localizacaoController = TextEditingController();
  // Removido _imagemController conforme a solicitação
  final TextEditingController _tipoController = TextEditingController();

  String _status = "Em andamento"; // Default value

  String _error = "";
  bool _isLoading = false;

  Future<void> _criarProjeto() async {
    // Validate all fields including the dropdown (if it had a validator)
    if (!_formKey.currentState!.validate()) {
      // Explicitly validate the dropdown if needed, although current setup doesn't require it
      // _statusFieldKey.currentState?.validate();
      return;
    }


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
        // Opcional: Redirecionar para a tela de login
        // Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final novoProjeto = {
        "titulo": _tituloController.text,
        "descricao": _descricaoController.text,
        "localizacao": _localizacaoController.text,
        // Removido "imagemUrl" do payload conforme a solicitação
        "tipo": _tipoController.text,
        "status": _status,
        // A API deve lidar com a associação do criador
        // Se a API espera o criador no corpo, ajuste aqui.
        // Mantendo o que estava, mas verificando se a API realmente precisa disso aqui *e* no query param.
        "pessoasEnvolvidas": [{"id": userId}],
      };

      // Verifique a documentação da sua API: o usuarioCriadorId vai no query param
      // ou no corpo do request? O código anterior usava query param.
      // Mantendo o query param como estava:
      final response = await http.post(
        Uri.parse("http://localhost:8080/projetos?usuarioCriadorId=$userId"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(novoProjeto),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Sucesso
        Navigator.pop(context, true); // Retorna 'true' indicando sucesso
      } else {
        // Tratar erros da API
        String errorMessage = "Erro ao criar o projeto";
        try {
          final errorData = json.decode(utf8.decode(response.bodyBytes));
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (e) {
          print("Erro ao parsear resposta de erro: $e");
          // Continua com a mensagem de erro padrão se o parse falhar
        }

        setState(() {
          _error = errorMessage;
        });
      }
    } catch (e) {
      // Tratar erros de conexão ou outros
      setState(() {
        _error = "Erro inesperado: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definir cores de fundo e texto para consistência com o tema escuro da imagem
    final Color backgroundColor = Color(0xFF121212); // Fundo bem escuro
    final Color appBarColor = Color(0xFF1F2937); // Cor da AppBar próxima da imagem
    final Color cardColor = Color(0xFF1F2937); // Cor dos campos/cartões
    final Color textColor = Colors.white;
    final Color hintColor = Colors.white54;
    final Color labelColor = Colors.white70;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Criar Novo Projeto",
          style: GoogleFonts.inter(color: Colors.white), // Usando GoogleFonts
        ),
        backgroundColor: appBarColor,
        // surfaceTintColor: Colors.white, // Pode causar um overlay claro em algumas plataformas
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Cor do ícone de voltar
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Para esticar os campos
            children: [
              // Logo no topo
              Center( // Centraliza a logo
                child: Image.asset(
                  'assets/logo.png', // Caminho da sua logo
                  height: 80,
                  // fit: BoxFit.contain, // Ajusta o tamanho da imagem
                ),
              ),
              const SizedBox(height: 30), // Espaço maior após a logo

              // Removido o campo de imagem conforme solicitação e layout da imagem

              // Campo Título
              _buildTextField(
                controller: _tituloController,
                label: "Título do Projeto", // Ajustado o label conforme a imagem
                hint: "Insira o título do projeto",
                textColor: textColor,
                hintColor: hintColor,
                fillColor: cardColor,
                labelColor: labelColor,
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
                hint: "Descreva seu projeto", // Ajustado o hint conforme a imagem
                textColor: textColor,
                hintColor: hintColor,
                fillColor: cardColor,
                labelColor: labelColor,
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
                hint: "Localização do projeto", // Ajustado o hint conforme a imagem
                textColor: textColor,
                hintColor: hintColor,
                fillColor: cardColor,
                labelColor: labelColor,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a localização';
                  }
                  return null;
                },
              ),

              // Campo Tipo (Campo Livre)
              _buildTextField(
                controller: _tipoController,
                label: "Tipo do Projeto", // Ajustado o label conforme a imagem
                hint: "Ex: Filme, Série, Documentário", // Ajustado o hint para campo livre
                textColor: textColor,
                hintColor: hintColor,
                fillColor: cardColor,
                labelColor: labelColor,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o tipo do projeto';
                  }
                  return null;
                },
              ),

              // Campo Status (Dropdown) - Mantido como dropdown conforme solicitação
              _buildDropdown(
                label: "Status do Projeto", // Ajustado o label
                dropdownColor: appBarColor, // Cor do dropdown
                fillColor: cardColor, // Cor de fundo do container do dropdown
                labelColor: labelColor,
                textColor: textColor,
              ),


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
                    textAlign: TextAlign.center, // Centraliza a mensagem de erro
                  ),
                ),

              const SizedBox(height: 20), // Espaço antes do botão

              // Botão Criar Projeto
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, // Cor âmbar conforme a imagem
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
                    color: Colors.black, // Cor do indicador
                    strokeWidth: 3,
                  ),
                )
                    : Text(
                  "CRIAR PROJETO",
                  style: GoogleFonts.inter( // Usando GoogleFonts
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
    Color? textColor,
    Color? hintColor,
    Color? fillColor,
    Color? labelColor,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor ?? Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500, // Levemente mais negrito
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: TextStyle(color: textColor ?? Colors.white),
            cursorColor: Colors.amber, // Cor do cursor
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: hintColor ?? Colors.white54),
              filled: true,
              fillColor: fillColor ?? Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              errorStyle: const TextStyle(color: Colors.red, fontSize: 12), // Menor fonte para erro
              focusedBorder: OutlineInputBorder( // Borda quando focado
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.amber, width: 1.5), // Borda âmbar
              ),
              enabledBorder: OutlineInputBorder( // Borda normal
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none, // Sem borda no estado normal
              ),
              errorBorder: OutlineInputBorder( // Borda com erro
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder( // Borda com erro e focado
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
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
    Color? textColor,
    Color? hintColor,
    Color? fillColor,
    Color? labelColor,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor ?? Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500, // Levemente mais negrito
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: TextStyle(color: textColor ?? Colors.white),
            maxLines: 4,
            cursorColor: Colors.amber, // Cor do cursor
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: hintColor ?? Colors.white54),
              filled: true,
              fillColor: fillColor ?? Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              errorStyle: const TextStyle(color: Colors.red, fontSize: 12), // Menor fonte para erro
              focusedBorder: OutlineInputBorder( // Borda quando focado
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.amber, width: 1.5), // Borda âmbar
              ),
              enabledBorder: OutlineInputBorder( // Borda normal
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none, // Sem borda no estado normal
              ),
              errorBorder: OutlineInputBorder( // Borda com erro
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder( // Borda com erro e focado
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    Color? dropdownColor,
    Color? fillColor,
    Color? labelColor,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor ?? Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500, // Levemente mais negrito
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: fillColor ?? Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
              // Use the key to check the error state
              border: Border.all(
                  color: _statusFieldKey.currentState?.hasError == true ? Colors.red : Colors.transparent,
                  width: 1.5
              ),
            ),
            // Wrap DropdownButton with FormField to participate in form validation
            child: FormField<String>(
              key: _statusFieldKey, // Assign the key here
              initialValue: _status,
              builder: (FormFieldState<String> state) {
                return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _status,
                    isExpanded: true,
                    dropdownColor: dropdownColor ?? Colors.grey[900],
                    style: TextStyle(color: textColor ?? Colors.white),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white70), // Cor do ícone
                    items: const [
                      DropdownMenuItem(
                        value: "Em andamento",
                        child: Text("Em andamento"),
                      ),
                      DropdownMenuItem(
                        value: "Concluído",
                        child: Text("Concluído"),
                      ),
                      DropdownMenuItem(
                        value: "Pré-produção", // Adicionado para mais opções
                        child: Text("Pré-produção"),
                      ),
                      DropdownMenuItem(
                        value: "Cancelado", // Adicionado para mais opções
                        child: Text("Cancelado"),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _status = newValue;
                        });
                        state.didChange(newValue); // Notify FormField of change
                      }
                    },
                  ),
                );
              },
              // Add validator for the dropdown if needed (e.g., if a "Select Status" initial value is used)
              validator: (value) {
                // If the initial value is null or a placeholder, you might add validation here
                // Example: if (value == null || value.isEmpty || value == 'Select Status') return 'Please select a status';
                return null; // Assuming "Em andamento" is a valid default
              },
            ),
          ),
          // Display error text if the FormField has an error
          if (_statusFieldKey.currentState?.hasError == true)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0),
              child: Text(
                _statusFieldKey.currentState?.errorText ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 12),
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
    // Removido _imagemController.dispose()
    _tipoController.dispose();
    super.dispose();
  }
}