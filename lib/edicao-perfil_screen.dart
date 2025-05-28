// lib/edicao-perfil_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api_constants.dart';
import 'projeto_detalhes_screen.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Usuario usuario;
  final Map<String, dynamic> userData;

  const EditarPerfilScreen({
    super.key,
    required this.usuario,
    required this.userData,
  });

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> with SingleTickerProviderStateMixin {
  // Controladores para os campos de texto
  late TextEditingController _nomeController;
  late TextEditingController _profissaoController;
  late TextEditingController _sobreMimController;

  // Variáveis para imagem
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  late String _currentImageUrl;
  bool _imageHovered = false;

  // Variáveis de estado
  bool _isLoading = false;
  bool _isSaveSuccess = false;
  String _errorMessage = '';

  // Animação
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Cores do tema
  final Color _primaryColor = Color(0xFF121212);
  final Color _cardColor = Color(0xFF1E2530);
  final Color _accentColor = Color(0xFFFFC107);
  final Color _successColor = Color(0xFF4CAF50);
  final Color _errorColor = Color(0xFFE57373);
  final Color _textPrimaryColor = Colors.white;
  final Color _textSecondaryColor = Colors.white70;

  // Headers para requisições
  static const Map<String, String> _ngrokHeaders = {
    'ngrok-skip-browser-warning': 'skip-browser-warning',
  };

  @override
  void initState() {
    super.initState();

    // Inicializa controladores com dados existentes
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _profissaoController = TextEditingController(text: widget.usuario.funcao);
    _sobreMimController = TextEditingController(text: widget.userData['sobreMim']);

    // Inicializa URL da imagem atual
    _currentImageUrl = widget.usuario.imagemUrl ?? "https://i.ibb.co/PG4G5q3/Ellipse-1.png";

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
    _nomeController.dispose();
    _profissaoController.dispose();
    _sobreMimController.dispose();
    super.dispose();
  }

  // Método para selecionar imagem
  Future<void> _pickImage() async {
    HapticFeedback.mediumImpact();

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _errorMessage = '';
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

  // Método para salvar alterações
  Future<void> _salvarAlteracoes() async {
    // Feedback tátil
    HapticFeedback.mediumImpact();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String? newImageUrl = _currentImageUrl;

    // Upload da imagem se uma nova foi selecionada
    if (_selectedImage != null) {
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse("${ApiConstants.baseUrl}/user/upload-imagem/${widget.usuario.id}"),
        );
        request.headers.addAll(_ngrokHeaders);

        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _selectedImage!.path,
          filename: _selectedImage!.name,
        ));

        final responseUpload = await request.send();
        if (responseUpload.statusCode == 200) {
          final responseData = await responseUpload.stream.bytesToString();
          final Map<String, dynamic> uploadResult = json.decode(responseData);
          newImageUrl = uploadResult['url'];
        } else {
          String uploadErrorMessage = "Erro ao fazer upload da imagem de perfil";
          try {
            final errorData = json.decode(await responseUpload.stream.bytesToString());
            uploadErrorMessage = errorData['message'] ?? uploadErrorMessage;
          } catch (e) {
            print("Erro ao parsear resposta de erro do upload: $e");
          }

          // Feedback tátil de erro
          HapticFeedback.vibrate();

          setState(() {
            _errorMessage = uploadErrorMessage;
          });
          _isLoading = false;
          return;
        }
      } catch (e) {
        // Feedback tátil de erro
        HapticFeedback.vibrate();

        setState(() {
          _errorMessage = 'Erro ao fazer upload da imagem: ${e.toString()}';
        });
        _isLoading = false;
        return;
      }
    }

    try {
      final updatedData = {
        "nome": _nomeController.text,
        "profissaoNome": _profissaoController.text,
        "sobreMim": _sobreMimController.text,
        "imagemUrl": newImageUrl,
      };

      final response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/user/${widget.usuario.id}"),
        headers: {
          "Content-Type": "application/json",
          'ngrok-skip-browser-warning': 'skip-browser-warning',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        // Feedback tátil de sucesso
        HapticFeedback.mediumImpact();

        // Animação de sucesso
        setState(() {
          _isSaveSuccess = true;
          _isLoading = false;
        });

        // Aguarda a animação de sucesso antes de retornar
        await Future.delayed(Duration(milliseconds: 1200));
        Navigator.pop(context, true);
      } else {
        // Feedback tátil de erro
        HapticFeedback.vibrate();

        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _errorMessage = errorBody['message'] ?? 'Erro ao salvar alterações.';
        });
      }
    } catch (e) {
      // Feedback tátil de erro
      HapticFeedback.vibrate();

      setState(() {
        _errorMessage = 'Erro de conexão: ${e.toString()}';
      });
    } finally {
      if (!_isSaveSuccess) {
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
          "Editar Perfil",
          style: GoogleFonts.poppins(
            color: _textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: _textPrimaryColor),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: _textSecondaryColor),
            onPressed: () {
              // Feedback tátil
              HapticFeedback.lightImpact();

              // Mostra dicas sobre edição de perfil
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: _cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    "Dicas para seu Perfil",
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
                        icon: Icons.photo_camera,
                        text: "Use uma foto de perfil profissional e bem iluminada",
                      ),
                      _buildTipItem(
                        icon: Icons.person,
                        text: "Seu nome completo ajuda outros a te encontrarem",
                      ),
                      _buildTipItem(
                        icon: Icons.work,
                        text: "Especifique sua profissão principal na indústria",
                      ),
                      _buildTipItem(
                        icon: Icons.description,
                        text: "Descreva suas habilidades e experiências relevantes",
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
      body: _isSaveSuccess
          ? _buildSuccessScreen()
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _isLoading
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  "Salvando alterações...",
                  style: GoogleFonts.poppins(
                    color: _textPrimaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Mensagem de erro
                if (_errorMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24.0),
                    padding: const EdgeInsets.all(16),
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
                            _errorMessage,
                            style: GoogleFonts.poppins(
                              color: _errorColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Texto introdutório
                Text(
                  "Personalize seu Perfil",
                  style: GoogleFonts.poppins(
                    color: _textPrimaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "Atualize suas informações para que outros profissionais possam te conhecer melhor",
                  style: GoogleFonts.poppins(
                    color: _textSecondaryColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                // Seletor de imagem
                _buildImageSelector(),
                SizedBox(height: 32),

                // Campos de texto
                _buildTextField(
                  controller: _nomeController,
                  label: "Nome Completo",
                  hint: "Digite seu nome completo",
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome';
                    }
                    return null;
                  },
                ),

                _buildTextField(
                  controller: _profissaoController,
                  label: "Profissão",
                  hint: "Ex: Diretor, Produtor, Roteirista",
                  icon: Icons.work,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua profissão';
                    }
                    return null;
                  },
                ),

                _buildTextArea(
                  controller: _sobreMimController,
                  label: "Sobre Mim",
                  hint: "Conte um pouco sobre você, suas experiências e habilidades",
                  icon: Icons.description,
                  validator: (value) {
                    return null; // Opcional
                  },
                ),

                SizedBox(height: 40),

                // Botão de salvar
                _buildSaveButton(),

                SizedBox(height: 40),
              ],
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

  // Widget para seletor de imagem
  Widget _buildImageSelector() {
    return MouseRegion(
      onEnter: (_) => setState(() => _imageHovered = true),
      onExit: (_) => setState(() => _imageHovered = false),
      child: GestureDetector(
        onTap: _pickImage,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _imageHovered
                    ? _accentColor.withOpacity(0.3)
                    : Colors.black.withOpacity(0.3),
                blurRadius: _imageHovered ? 16 : 8,
                spreadRadius: _imageHovered ? 2 : 0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Avatar
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _imageHovered ? _accentColor : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(70),
                  child: _selectedImage != null
                      ? Image.file(
                    File(_selectedImage!.path),
                    fit: BoxFit.cover,
                    width: 140,
                    height: 140,
                  )
                      : (_currentImageUrl.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: _currentImageUrl,
                    fit: BoxFit.cover,
                    width: 140,
                    height: 140,
                    placeholder: (context, url) => Container(
                      color: _cardColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: _cardColor,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: _textSecondaryColor,
                      ),
                    ),
                  )
                      : Container(
                    color: _cardColor,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: _textSecondaryColor,
                    ),
                  )),
                ),
              ),

              // Botão de câmera
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.all(_imageHovered ? 12 : 10),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: _imageHovered ? 24 : 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
              if (_errorMessage.isNotEmpty) {
                setState(() {
                  _errorMessage = "";
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
              if (_errorMessage.isNotEmpty) {
                setState(() {
                  _errorMessage = "";
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // Widget para botão de salvar
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
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
        onPressed: _isLoading ? null : _salvarAlteracoes,
        child: Text(
          "SALVAR ALTERAÇÕES",
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
            "Perfil Atualizado!",
            style: GoogleFonts.poppins(
              color: _textPrimaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Suas informações foram atualizadas com sucesso.",
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
