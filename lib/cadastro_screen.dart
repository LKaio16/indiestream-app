import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_constants.dart';
import 'login_screen.dart';

class CadastroScreen extends StatefulWidget {
  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> with SingleTickerProviderStateMixin {
  String? perfilSelecionado;
  final List<String> listaPerfis = ["Artista", "Fã", "Produtor", "Outro"];
  final Map<String, IconData> perfilIcons = {
    "Artista": Icons.brush,
    "Fã": Icons.favorite,
    "Produtor": Icons.movie,
    "Outro": Icons.person,
  };

  // Text controllers for the input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmaSenhaController = TextEditingController();

  // Form validation
  final _formKey = GlobalKey<FormState>();
  bool _isEmailValid = true;
  bool _isNomeValid = true;
  bool _isSenhaValid = true;
  bool _isConfirmaSenhaValid = true;
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Hardcoded mapping of profession names to hypothetical IDs
  final Map<String, int> profissaoIds = {
    "Artista": 1,
    "Fã": 2,
    "Produtor": 3,
    "Outro": 4,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nomeController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Function to handle user registration
  Future<void> _realizarCadastro() async {
    // Fechar teclado
    FocusScope.of(context).unfocus();

    // Validar formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Basic validation
    if (_senhaController.text != _confirmaSenhaController.text) {
      _showErrorSnackBar('As senhas não coincidem!');
      setState(() => _isLoading = false);
      return;
    }

    if (perfilSelecionado == null) {
      _showErrorSnackBar('Por favor, selecione sua profissão!');
      setState(() => _isLoading = false);
      return;
    }

    // Get the selected profession ID
    final int? profissaoId = profissaoIds[perfilSelecionado!];

    if (profissaoId == null) {
      _showErrorSnackBar('Erro ao obter o ID da profissão selecionada.');
      setState(() => _isLoading = false);
      return;
    }

    // Feedback tátil
    HapticFeedback.mediumImpact();

    // Prepare the data to be sent to the backend
    final userData = {
      'email': _emailController.text,
      'nome': _nomeController.text,
      'senha': _senhaController.text,
      'profissao': {
        'id': profissaoId,
      },
      'username': _emailController.text,
      'imagemUrl': null,
      'dataNascimento': null,
      'habilidades': [],
      'estado': null,
      'cidade': null,
      'premium': false,
      'redesSociais': [],
      'sobreMin': null,
      'obrasFavoritas': [],
    };

    // Backend URL
    const String apiUrl = '${ApiConstants.baseUrl}/user';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'ngrok-skip-browser-warning': 'skip-browser-warning',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration successful
        print('Usuário cadastrado com sucesso!');

        // Mostrar animação de sucesso
        _showSuccessAnimation();

        // Navegar após a animação
        Future.delayed(const Duration(milliseconds: 1500), () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                var begin = const Offset(0.0, 1.0);
                var end = Offset.zero;
                var curve = Curves.easeInOutCubic;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        });
      } else {
        // Registration failed
        print('Erro ao cadastrar usuário: ${response.statusCode}');
        print('Response body: ${response.body}');

        String errorMessage = 'Erro ao cadastrar usuário. Tente novamente.';
        try {
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Se não for JSON ou a mensagem não existir
        }

        _showErrorSnackBar(errorMessage);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // Handle network errors
      print('Erro de rede durante o cadastro: $e');
      _showErrorSnackBar('Erro de conexão. Verifique sua internet ou o servidor.');
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.greenAccent,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'Cadastro realizado com sucesso!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Redirecionando para o login...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1D1D1D),
              const Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16.0 : 24.0,
                vertical: 20.0,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo com efeito de escala
                        Hero(
                          tag: 'app_logo',
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.8, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.yellow.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/logo.png',
                                height: 90,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Título com estilo moderno
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [Colors.yellow, Colors.amber.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            'Crie sua Conta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Preencha os dados para começar',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Campo de email com validação
                        _buildInputField(
                          label: "Email",
                          hint: "Seu endereço de email",
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          prefixIcon: Icons.alternate_email,
                          isValid: _isEmailValid,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() => _isEmailValid = false);
                              return 'Email é obrigatório';
                            }
                            if (!_validateEmail(value)) {
                              setState(() => _isEmailValid = false);
                              return 'Formato de email inválido';
                            }
                            setState(() => _isEmailValid = true);
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() => _isEmailValid = _validateEmail(value));
                            }
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 16),

                        // Campo de nome com validação
                        _buildInputField(
                          label: "Nome",
                          hint: "Seu nome completo",
                          controller: _nomeController,
                          icon: Icons.person_outline,
                          prefixIcon: Icons.person,
                          isValid: _isNomeValid,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() => _isNomeValid = false);
                              return 'Nome é obrigatório';
                            }
                            if (value.trim().split(' ').length < 2) {
                              setState(() => _isNomeValid = false);
                              return 'Informe nome e sobrenome';
                            }
                            setState(() => _isNomeValid = true);
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty && !_isNomeValid) {
                              setState(() => _isNomeValid = true);
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // Campo de senha com validação
                        _buildInputField(
                          label: "Senha",
                          hint: "Crie uma senha forte",
                          controller: _senhaController,
                          icon: Icons.lock_outline,
                          prefixIcon: Icons.lock,
                          isValid: _isSenhaValid,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() => _isSenhaValid = false);
                              return 'Senha é obrigatória';
                            }
                            if (value.length < 6) {
                              setState(() => _isSenhaValid = false);
                              return 'Senha deve ter pelo menos 6 caracteres';
                            }
                            setState(() => _isSenhaValid = true);
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty && !_isSenhaValid) {
                              setState(() => _isSenhaValid = true);
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // Campo de confirmação de senha com validação
                        _buildInputField(
                          label: "Confirme a Senha",
                          hint: "Digite a senha novamente",
                          controller: _confirmaSenhaController,
                          icon: Icons.lock_outline,
                          prefixIcon: Icons.lock,
                          isValid: _isConfirmaSenhaValid,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() => _isConfirmaSenhaValid = false);
                              return 'Confirmação de senha é obrigatória';
                            }
                            if (value != _senhaController.text) {
                              setState(() => _isConfirmaSenhaValid = false);
                              return 'As senhas não coincidem';
                            }
                            setState(() => _isConfirmaSenhaValid = true);
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty && !_isConfirmaSenhaValid) {
                              setState(() => _isConfirmaSenhaValid = value == _senhaController.text);
                            }
                          },
                        ),

                        const SizedBox(height: 24),

                        // Seleção de perfil com design moderno
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.work_outline,
                                    size: 18,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Profissão',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: perfilSelecionado == null
                                      ? Colors.transparent
                                      : Colors.yellow.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    value: perfilSelecionado,
                                    hint: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.work,
                                            color: Colors.grey[500],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            "Selecione sua profissão",
                                            style: TextStyle(color: Colors.grey[400]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey[400],
                                    ),
                                    dropdownColor: const Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(16),
                                    isExpanded: true,
                                    items: listaPerfis.map((String valor) {
                                      return DropdownMenuItem<String>(
                                        value: valor,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Row(
                                            children: [
                                              Icon(
                                                perfilIcons[valor] ?? Icons.person,
                                                color: Colors.yellow,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                valor,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? novoValor) {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        perfilSelecionado = novoValor;
                                      });
                                    },
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Botão de cadastro com animação
                        _isLoading
                            ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            children: [
                              const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Processando...',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                            : Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [Colors.yellow, Colors.amber.shade700],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              splashColor: Colors.white.withOpacity(0.2),
                              highlightColor: Colors.transparent,
                              onTap: _realizarCadastro,
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'CADASTRAR',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Separador com estilo moderno
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.withOpacity(0.1),
                                      Colors.grey.withOpacity(0.5),
                                    ],
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OU',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.withOpacity(0.1),
                                      Colors.grey.withOpacity(0.5),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Link para login com animação
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Já possui conta?',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 15,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      var begin = const Offset(-1.0, 0.0);
                                      var end = Offset.zero;
                                      var curve = Curves.easeInOutCubic;
                                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                      return SlideTransition(
                                        position: animation.drive(tween),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.yellow,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Entrar',
                                    style: TextStyle(
                                      color: Colors.yellow[600],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: Colors.yellow[600],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required IconData prefixIcon,
    required bool isValid,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          keyboardType: keyboardType,
          cursorColor: Colors.yellow,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isValid ? Colors.yellow : Colors.red,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isValid
                    ? Colors.transparent
                    : Colors.red.withOpacity(0.5),
              ),
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: isValid ? Colors.grey[500] : Colors.red,
            ),
            suffixIcon: isPassword
                ? Icon(
              Icons.visibility_off_outlined,
              color: Colors.grey[500],
            )
                : null,
          ),
        ),
      ],
    );
  }
}
