// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_constants.dart';
import 'auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CriarProjetoScreen extends StatefulWidget {
  const CriarProjetoScreen({super.key});

  @override
  State<CriarProjetoScreen> createState() => _CriarProjetoScreenState();
}

class _CriarProjetoScreenState extends State<CriarProjetoScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _statusFieldKey = GlobalKey<FormFieldState<String>>();

  // Controladores de texto
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _localizacaoController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();

  // Variáveis para imagem
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _imageHovered = false;

  // Variáveis de estado
  String _status = "Em andamento";
  String _error = "";
  bool _isLoading = false;
  bool _isSuccess = false;

  // Animação
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Cores do tema
  final Color _primaryColor = Color(0xFF1E2530);
  final Color _cardColor = Color(0xFF2A3441);
  final Color _accentColor = Color(0xFFFFC107);
  final Color _successColor = Color(0xFF4CAF50);
  final Color _errorColor = Color(0xFFE57373);
  final Color _textPrimaryColor = Colors.white;
  final Color _textSecondaryColor = Colors.white70;

  @override
  void initState() {
    super.initState();

    // Inicializa o controlador de animação
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Inicia a animação
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tituloController.dispose();
    _descricaoController.dispose();
    _localizacaoController.dispose();
    _tipoController.dispose();
    super.dispose();
  }

  // Método para selecionar imagem
  Future<void> _pickImage() async {
    HapticFeedback.mediumImpact();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800, // Aumentado para melhor qualidade
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });

      // Feedback visual de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: _successColor),
              SizedBox(width: 10),
              Text(
                'Imagem selecionada com sucesso!',
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          backgroundColor: _cardColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Método para criar projeto
  Future<void> _criarProjeto() async {
    // Verifica validação do formulário
    if (!_formKey.currentState!.validate()) {
      // Feedback tátil de erro
      HapticFeedback.vibrate();
      return;
    }

    // Verifica se uma imagem foi selecionada
    if (_selectedImage == null) {
      // Feedback tátil de erro
      HapticFeedback.vibrate();
      setState(() {
        _error = "Por favor, selecione uma imagem para o projeto.";
      });
      return;
    }

    // Inicia o carregamento
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

      // Upload da imagem
      String? imageUrl;
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiConstants.baseUrl}/projetos/upload-imagem"),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _selectedImage!.path,
        filename: _selectedImage!.name,
      ));

      final responseUpload = await request.send();
      if (responseUpload.statusCode == 200) {
        final responseData = await responseUpload.stream.bytesToString();
        final Map<String, dynamic> uploadResult = json.decode(responseData);
        imageUrl = uploadResult['url'];
      } else {
        // Tratamento de erro de upload
        String uploadErrorMessage = "Erro ao fazer upload da imagem";
        try {
          final errorData = json.decode(await responseUpload.stream.bytesToString());
          uploadErrorMessage = errorData['message'] ?? uploadErrorMessage;
        } catch (e) {
          print("Erro ao parsear resposta de erro do upload: $e");
        }
        setState(() {
          _error = uploadErrorMessage;
        });
        _isLoading = false;
        return;
      }

      // Criação do projeto
      final novoProjeto = {
        "titulo": _tituloController.text,
        "descricao": _descricaoController.text,
        "localizacao": _localizacaoController.text,
        "imagemUrl": imageUrl,
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
        // Feedback tátil de sucesso
        HapticFeedback.mediumImpact();

        // Animação de sucesso
        setState(() {
          _isSuccess = true;
          _isLoading = false;
        });

        // Aguarda a animação de sucesso antes de retornar
        await Future.delayed(Duration(milliseconds: 1200));
        Navigator.pop(context, true);
      } else {
        // Tratamento de erro na criação do projeto
        String errorMessage = "Erro ao criar o projeto";
        try {
          final errorData = json.decode(utf8.decode(response.bodyBytes));
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (e) {
          print("Erro ao parsear resposta de erro: $e");
        }

        // Feedback tátil de erro
        HapticFeedback.vibrate();

        setState(() {
          _error = errorMessage;
        });
      }
    } catch (e) {
      // Feedback tátil de erro
      HapticFeedback.vibrate();

      setState(() {
        _error = "Erro inesperado: ${e.toString()}";
      });
    } finally {
      if (!_isSuccess) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      appBar: AppBar(
        title: Text(
          "Criar Novo Projeto",
          style: GoogleFonts.poppins(
            color: _textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textPrimaryColor),
          onPressed: () => Navigator.pop(context),
          splashRadius: 24,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: _textSecondaryColor),
            onPressed: () {
              // Feedback tátil
              HapticFeedback.lightImpact();

              // Mostra dicas sobre criação de projetos
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: _cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    "Dicas para Criar Projetos",
                    style: GoogleFonts.poppins(
                      color: _textPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTipItem(
                        icon: Icons.title,
                        text: "Use um título claro e atrativo",
                      ),
                      _buildTipItem(
                        icon: Icons.description,
                        text: "Descreva o projeto com detalhes relevantes",
                      ),
                      _buildTipItem(
                        icon: Icons.image,
                        text: "Escolha uma imagem de alta qualidade",
                      ),
                      _buildTipItem(
                        icon: Icons.location_on,
                        text: "Especifique a localização para facilitar colaborações",
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Entendi",
                        style: GoogleFonts.poppins(
                          color: _accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            splashRadius: 24,
          ),
        ],
      ),
      body: _isSuccess
          ? _buildSuccessScreen()
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo e título
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _accentColor.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 60,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Texto introdutório
                  Text(
                    "Vamos criar seu novo projeto!",
                    style: GoogleFonts.poppins(
                      color: _textPrimaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Preencha os detalhes abaixo para começar sua jornada criativa",
                    style: GoogleFonts.poppins(
                      color: _textSecondaryColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),

                  // Seleção de imagem - Agora responsiva
                  _buildImageSelector(),
                  SizedBox(height: 24),

                  // Campos do formulário
                  _buildTextField(
                    controller: _tituloController,
                    label: "Título do Projeto",
                    hint: "Insira o título do projeto",
                    icon: Icons.title,
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
                    hint: "Descreva seu projeto com detalhes",
                    icon: Icons.description,
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
                    hint: "Onde o projeto será realizado?",
                    icon: Icons.location_on,
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
                    icon: FontAwesomeIcons.film,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o tipo do projeto';
                      }
                      return null;
                    },
                  ),

                  _buildDropdown(
                    label: "Status do Projeto",
                    icon: Icons.flag,
                  ),

                  // Mensagem de erro
                  if (_error.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 16, bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _errorColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: _errorColor,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _error,
                              style: GoogleFonts.poppins(
                                color: _errorColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 32),

                  // Botão de criar projeto
                  _buildCreateButton(),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para item de dica
  Widget _buildTipItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: _accentColor,
            size: 18,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: _textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para seletor de imagem - Agora responsivo e maior
  Widget _buildImageSelector() {
    return LayoutBuilder(
        builder: (context, constraints) {
          // Calcula a altura baseada na largura disponível para manter proporção 16:9
          final double imageHeight = constraints.maxWidth * 0.6;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.image,
                    color: _accentColor,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Imagem do Projeto",
                    style: GoogleFonts.poppins(
                      color: _textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    " *",
                    style: GoogleFonts.poppins(
                      color: _errorColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              MouseRegion(
                onEnter: (_) => setState(() => _imageHovered = true),
                onExit: (_) => setState(() => _imageHovered = false),
                child: GestureDetector(
                  onTap: _pickImage,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: double.infinity,
                    height: _selectedImage != null ? imageHeight : imageHeight,
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedImage == null
                            ? _error.contains("selecione uma imagem")
                            ? _errorColor
                            : _imageHovered
                            ? _accentColor.withOpacity(0.7)
                            : _cardColor.withOpacity(0.3)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: _imageHovered
                          ? [
                        BoxShadow(
                          color: _accentColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ]
                          : [],
                    ),
                    child: _selectedImage != null
                        ? Stack(
                      fit: StackFit.expand,
                      children: [
                        // Imagem selecionada
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        // Overlay escuro com botão de trocar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _imageHovered
                              ? Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: _textPrimaryColor,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Trocar imagem",
                                    style: GoogleFonts.poppins(
                                      color: _textPrimaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              : SizedBox(),
                        ),
                      ],
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          color: _imageHovered ? _accentColor : _textSecondaryColor,
                          size: 64, // Ícone maior
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Clique para selecionar uma imagem",
                          style: GoogleFonts.poppins(
                            color: _imageHovered ? _accentColor : _textSecondaryColor,
                            fontSize: 18, // Texto maior
                            fontWeight: _imageHovered ? FontWeight.w500 : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Recomendado: 1800 x 1000 pixels",
                          style: GoogleFonts.poppins(
                            color: _textSecondaryColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_selectedImage == null && _error.contains("selecione uma imagem"))
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                  child: Text(
                    "Por favor, selecione uma imagem para o projeto.",
                    style: GoogleFonts.poppins(
                      color: _errorColor,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        }
    );
  }

  // Widget para campo de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: _accentColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: _textPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                " *",
                style: GoogleFonts.poppins(
                  color: _errorColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: GoogleFonts.poppins(
              color: _textPrimaryColor,
              fontSize: 15,
            ),
            cursorColor: _accentColor,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: _textSecondaryColor.withOpacity(0.7),
                fontSize: 15,
              ),
              filled: true,
              fillColor: _cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              errorStyle: GoogleFonts.poppins(
                color: _errorColor,
                fontSize: 12,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _accentColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _cardColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _errorColor, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _errorColor, width: 1.5),
              ),
            ),
            validator: validator,
            onChanged: (_) {
              // Limpa mensagem de erro se o usuário começar a digitar
              if (_error.isNotEmpty) {
                setState(() {
                  _error = "";
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // Widget para área de texto
  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: _accentColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: _textPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                " *",
                style: GoogleFonts.poppins(
                  color: _errorColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: GoogleFonts.poppins(
              color: _textPrimaryColor,
              fontSize: 15,
            ),
            maxLines: 4,
            cursorColor: _accentColor,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: _textSecondaryColor.withOpacity(0.7),
                fontSize: 15,
              ),
              filled: true,
              fillColor: _cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
              errorStyle: GoogleFonts.poppins(
                color: _errorColor,
                fontSize: 12,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _accentColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _cardColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _errorColor, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _errorColor, width: 1.5),
              ),
            ),
            validator: validator,
            onChanged: (_) {
              // Limpa mensagem de erro se o usuário começar a digitar
              if (_error.isNotEmpty) {
                setState(() {
                  _error = "";
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // Widget para dropdown
  Widget _buildDropdown({
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: _accentColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: _textPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                " *",
                style: GoogleFonts.poppins(
                  color: _errorColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _statusFieldKey.currentState?.hasError == true
                    ? _errorColor
                    : _cardColor.withOpacity(0.3),
                width: _statusFieldKey.currentState?.hasError == true ? 1.5 : 1,
              ),
            ),
            child: FormField<String>(
              key: _statusFieldKey,
              initialValue: _status,
              builder: (FormFieldState<String> state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _status,
                      isExpanded: true,
                      dropdownColor: _cardColor,
                      style: GoogleFonts.poppins(
                        color: _textPrimaryColor,
                        fontSize: 15,
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: _textSecondaryColor,
                        size: 28,
                      ),
                      items: [
                        _buildDropdownItem("Em andamento", Icons.play_circle_outline),
                        _buildDropdownItem("Concluído", Icons.check_circle_outline),
                        _buildDropdownItem("Pré-produção", Icons.hourglass_empty),
                        _buildDropdownItem("Cancelado", Icons.cancel_outlined),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          // Feedback tátil
                          HapticFeedback.selectionClick();

                          setState(() {
                            _status = newValue;
                          });
                          state.didChange(newValue);
                        }
                      },
                    ),
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
                style: GoogleFonts.poppins(
                  color: _errorColor,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget para item do dropdown
  DropdownMenuItem<String> _buildDropdownItem(String value, IconData icon) {
    Color itemColor;
    switch (value) {
      case "Em andamento":
        itemColor = Colors.blue;
        break;
      case "Concluído":
        itemColor = _successColor;
        break;
      case "Pré-produção":
        itemColor = _accentColor;
        break;
      case "Cancelado":
        itemColor = _errorColor;
        break;
      default:
        itemColor = _textSecondaryColor;
    }

    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: itemColor,
            size: 20,
          ),
          SizedBox(width: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: _textPrimaryColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para botão de criar
  Widget _buildCreateButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            _accentColor,
            Color(0xFFFF9800),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: _isLoading ? null : _criarProjeto,
        child: _isLoading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 3,
              ),
            ),
            SizedBox(width: 12),
            Text(
              "CRIANDO PROJETO...",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ],
        )
            : Text(
          "CRIAR PROJETO",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // Widget para tela de sucesso
  Widget _buildSuccessScreen() {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: _successColor,
              size: 80,
            ),
          ),
          SizedBox(height: 32),
          Text(
            "Projeto Criado com Sucesso!",
            style: GoogleFonts.poppins(
              color: _textPrimaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Seu projeto foi criado e já está disponível na plataforma.",
            style: GoogleFonts.poppins(
              color: _textSecondaryColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
          ),
        ],
      ),
    );
  }
}
