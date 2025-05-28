// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_constants.dart';
import 'auth_service.dart'; // Certifique-se de que este import está correto
import 'package:google_fonts/google_fonts.dart'; // Adicionado Google Fonts para consistência
import 'package:image_picker/image_picker.dart'; // Import for image_picker
import 'dart:io'; // Import for File

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
  final TextEditingController _tipoController = TextEditingController();

  // New: State variable for the selected image file
  XFile? _selectedImage;

  // New: ImagePicker instance
  final ImagePicker _picker = ImagePicker();

  String _status = "Em andamento"; // Default value

  String _error = "";
  bool _isLoading = false;

  // New: Method to pick an image
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _criarProjeto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // New: Validate if an image has been selected
    if (_selectedImage == null) {
      setState(() {
        _error = "Por favor, selecione uma imagem para o projeto.";
      });
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
        return;
      }

      String? imageUrl;

      final request = http.MultipartRequest(
        'POST',
        // Mude para o endpoint correto de upload de imagem no seu backend
        Uri.parse("${ApiConstants.baseUrl}/projetos/upload-imagem"),
      );
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        // Nome do campo esperado pelo backend (@RequestParam("file") MultipartFile file)
        _selectedImage!.path,
        filename: _selectedImage!.name,
      ));

      final responseUpload = await request.send();
      if (responseUpload.statusCode == 200) {
        final responseData = await responseUpload.stream.bytesToString();
        // O backend retorna um JSON {"url": "..."}
        final Map<String, dynamic> uploadResult = json.decode(responseData);
        imageUrl =
            uploadResult['url']; // Pega a URL do JSON retornado pelo backend
      } else {
        // Tratar erro de upload de imagem
        String uploadErrorMessage = "Erro ao fazer upload da imagem";
        try {
          final errorData =
              json.decode(await responseUpload.stream.bytesToString());
          uploadErrorMessage = errorData['message'] ?? uploadErrorMessage;
        } catch (e) {
          print("Erro ao parsear resposta de erro do upload: $e");
        }
        setState(() {
          _error = uploadErrorMessage;
        });
        _isLoading = false;
        return; // Interrompe a criação do projeto se o upload falhar
      }

      // --- Fim da lógica de upload de imagem (simulado) ---

      final novoProjeto = {
        "titulo": _tituloController.text,
        "descricao": _descricaoController.text,
        "localizacao": _localizacaoController.text,
        "imagemUrl": imageUrl, // New: Add the image URL
        "tipo": _tipoController.text,
        "status": _status,
        "pessoasEnvolvidas": [
          {"id": userId}
        ],
      };

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/projetos?usuarioCriadorId=$userId"),
        headers: {
          "Content-Type": "application/json",
          'ngrok-skip-browser-warning': 'skip-browser-warning',
        },
        body: json.encode(novoProjeto),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        String errorMessage = "Erro ao criar o projeto";
        try {
          final errorData = json.decode(utf8.decode(response.bodyBytes));
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (e) {
          print("Erro ao parsear resposta de erro: $e");
        }

        setState(() {
          _error = errorMessage;
        });
      }
    } catch (e) {
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
    final Color backgroundColor = Color(0xFF121212);
    final Color appBarColor = Color(0xFF1F2937);
    final Color cardColor = Color(0xFF1F2937);
    final Color textColor = Colors.white;
    final Color hintColor = Colors.white54;
    final Color labelColor = Colors.white70;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Criar Novo Projeto",
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 80,
                ),
              ),
              const SizedBox(height: 30),

              // New: Image selection field
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Imagem do Projeto",
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedImage == null
                                ? Colors.red
                                : Colors
                                    .transparent, // Highlight if no image selected
                            width: 1.5,
                          ),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      color: hintColor,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Tocar para selecionar imagem",
                                      style: GoogleFonts.inter(
                                        color: hintColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    if (_selectedImage == null &&
                        _error.contains("selecione uma imagem"))
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                        child: Text(
                          "Por favor, selecione uma imagem para o projeto.",
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              // End: New Image selection field

              _buildTextField(
                controller: _tituloController,
                label: "Título do Projeto",
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

              _buildTextArea(
                controller: _descricaoController,
                label: "Descrição",
                hint: "Descreva seu projeto",
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

              _buildTextField(
                controller: _localizacaoController,
                label: "Localização",
                hint: "Localização do projeto",
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

              _buildTextField(
                controller: _tipoController,
                label: "Tipo do Projeto",
                hint: "Ex: Filme, Série, Documentário",
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

              _buildDropdown(
                label: "Status do Projeto",
                dropdownColor: appBarColor,
                fillColor: cardColor,
                labelColor: labelColor,
                textColor: textColor,
              ),

              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _error,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 20),

              ElevatedButton(
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
                    : Text(
                        "CRIAR PROJETO",
                        style: GoogleFonts.inter(
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
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: TextStyle(color: textColor ?? Colors.white),
            cursorColor: Colors.amber,
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
              errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.amber, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
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
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: TextStyle(color: textColor ?? Colors.white),
            maxLines: 4,
            cursorColor: Colors.amber,
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
              errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.amber, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
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
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: fillColor ?? Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: _statusFieldKey.currentState?.hasError == true
                      ? Colors.red
                      : Colors.transparent,
                  width: 1.5),
            ),
            child: FormField<String>(
              key: _statusFieldKey,
              initialValue: _status,
              builder: (FormFieldState<String> state) {
                return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _status,
                    isExpanded: true,
                    dropdownColor: dropdownColor ?? Colors.grey[900],
                    style: TextStyle(color: textColor ?? Colors.white),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
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
                        value: "Pré-produção",
                        child: Text("Pré-produção"),
                      ),
                      DropdownMenuItem(
                        value: "Cancelado",
                        child: Text("Cancelado"),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _status = newValue;
                        });
                        state.didChange(newValue);
                      }
                    },
                  ),
                );
              },
              validator: (value) {
                return null;
              },
            ),
          ),
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
    _tipoController.dispose();
    super.dispose();
  }
}
