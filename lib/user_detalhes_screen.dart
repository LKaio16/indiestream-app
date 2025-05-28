// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_constants.dart';
import 'auth_service.dart'; // Certifique-se de que este import está correto
import 'edicao-perfil_screen.dart';
import 'projeto_detalhes_screen.dart'; // Importa Projeto e Usuario (verifique se estão definidos aqui)

class UserDetalhesScreen extends StatefulWidget {
  final String userId;

  const UserDetalhesScreen({super.key, required this.userId});

  @override
  State<UserDetalhesScreen> createState() => _UserDetalhesScreenState();
}

class _UserDetalhesScreenState extends State<UserDetalhesScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _user; // O usuário cujo perfil está sendo visualizado
  Usuario? _usuarioAtualLogado; // O usuário atualmente logado
  List<dynamic> _projetos = [];
  List<dynamic> _habilidades = [];
  List<dynamic> _obrasFavoritas = [];
  bool _isLoadingUserData = true; // Estado de carregamento dos dados do perfil visualizado
  bool _isLoadingCurrentUser = true; // Estado de carregamento dos dados do usuário logado
  bool _isCurrentUser = false; // Flag para verificar se o perfil visualizado é o do usuário logado
  int _paginaAtual = 1;
  final int _itensPorPagina = 3;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Cores do tema
  final Color _primaryColor = Color(0xFF1E2530);
  final Color _accentColor = Color(0xFFFFC107);
  final Color _cardColor = Color(0xFF2A3441);
  final Color _textPrimaryColor = Colors.white;
  final Color _textSecondaryColor = Colors.white70;
  final Color _dividerColor = Colors.white24;
  final Color _chipColor = Color(0xFF3A4453);

  static const Map<String, String> _ngrokHeaders = {
    'ngrok-skip-browser-warning': 'skip-browser-warning',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    _carregarDadosUsuarioVisualizado(); // Carrega o perfil que está sendo visualizado
    _carregarUsuarioLogado(); // Carrega os dados do usuário atualmente logado
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Função para buscar o usuário cujo perfil está sendo visualizado
  Future<void> _carregarDadosUsuarioVisualizado() async {
    setState(() {
      _isLoadingUserData = true;
    });
    try {
      final userResponse = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/user/${widget.userId}"),
        headers: _ngrokHeaders, // Add the ngrok header here
      );

      if (userResponse.statusCode == 200) {
        final userData = json.decode(utf8.decode(userResponse.bodyBytes));

        setState(() {
          _user = userData;
          _habilidades = userData["habilidades"] ?? [];
          _obrasFavoritas = userData["obrasFavoritas"] ?? [];
        });

        // Buscar projetos associados ao usuário visualizado
        final projetosResponse = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/projetos?userId=${widget.userId}"),
          headers: _ngrokHeaders, // Add the ngrok header here
        );

        if (projetosResponse.statusCode == 200) {
          setState(() {
            _projetos = json.decode(utf8.decode(projetosResponse.bodyBytes));
          });
        } else {
          print("Falha ao carregar projetos do usuário: Status ${projetosResponse.statusCode}");
          setState(() {
            _projetos = [];
          });
        }
      } else {
        print("Falha ao carregar usuário: Status ${userResponse.statusCode}");
        setState(() {
          _user = null; // Indica que o usuário não foi encontrado
          _projetos = [];
          _habilidades = [];
          _obrasFavoritas = [];
        });
      }
    } catch (e) {
      print("Erro ao carregar dados do usuário: $e");
      setState(() {
        _user = null; // Indica erro ao carregar o usuário
        _projetos = [];
        _habilidades = [];
        _obrasFavoritas = [];
      });
    } finally {
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  // Função para buscar os detalhes do usuário atualmente logado
  Future<void> _carregarUsuarioLogado() async {
    setState(() {
      _isLoadingCurrentUser = true;
    });

    int? userIdInt = await AuthService.getUserId();

    if (userIdInt == null) {
      print("UserDetalhesScreen: Nenhum ID de usuário logado encontrado no AuthService.");
      if (mounted) {
        setState(() {
          _usuarioAtualLogado = null; // Nenhum usuário logado
          _isLoadingCurrentUser = false;
          _isCurrentUser = false; // Não é o usuário atual
        });
      }
      return;
    }

    String userIdString = userIdInt.toString();

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/user/$userIdString"), // Supondo que você tem um endpoint para buscar usuário por ID
        headers: _ngrokHeaders, // Add the ngrok header here
      );

      if (response.statusCode == 200) {
        final userData = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _usuarioAtualLogado = Usuario(
              id: userData['id']?.toString() ?? userIdString,
              nome: userData['nome']?.toString() ?? "Nome Indisponível",
              imagemUrl: userData['imagemUrl']?.toString() ?? "https://i.ibb.co/PG4G5q3/Ellipse-1.png", // Fallback image
              funcao: userData['profissaoNome']?.toString(), // Ou outro campo que represente a função
            );
            _isLoadingCurrentUser = false;
            _isCurrentUser = userIdString == widget.userId; // Verifica se o ID do logado é o mesmo do perfil visualizado
          });
        }
      } else {
        print("Falha ao carregar detalhes do usuário logado: Status ${response.statusCode}");
        if (mounted) {
          setState(() {
            _usuarioAtualLogado = null;
            _isLoadingCurrentUser = false;
            _isCurrentUser = false;
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar detalhes do usuário logado: $e");
      if (mounted) {
        setState(() {
          _usuarioAtualLogado = null;
          _isLoadingCurrentUser = false;
          _isCurrentUser = false;
        });
      }
    }
  }

  // Helper function to parse a single Usuario from map (copied from ProjetosScreen)
  Usuario _parseUsuarioFromMap(Map<String, dynamic>? userData) {
    if (userData == null) {
      print("Aviso: Dados do usuário (criador/membro) ausentes na API, usando placeholders.");
      return Usuario(
        id: 'unknown_id_${DateTime.now().millisecondsSinceEpoch}',
        nome: 'Usuário Desconhecido',
        imagemUrl: '',
        funcao: null,
      );
    }
    return Usuario(
      id: userData['id']?.toString() ?? 'fallback_id_${DateTime.now().millisecondsSinceEpoch}',
      nome: userData['nome']?.toString() ?? 'Nome Indisponível',
      imagemUrl: userData['imagemUrl']?.toString() ?? '',
      funcao: userData['funcao']?.toString(),
    );
  }

  // Helper function to parse a list of Usuarios from a list of maps (copied from ProjetosScreen)
  List<Usuario> _parseUsuariosListFromMap(List<dynamic>? usersDataList) {
    if (usersDataList == null) {
      return [];
    }
    return usersDataList
        .where((item) => item is Map<String, dynamic>)
        .map((userData) => _parseUsuarioFromMap(userData as Map<String, dynamic>))
        .toList();
  }

  Widget _buildSocialIcon(String url) {
    IconData icon;
    Color color;

    if (url.contains("facebook")) {
      icon = FontAwesomeIcons.facebook;
      color = Colors.blue;
    } else if (url.contains("twitter") || url.contains("x.com")) {
      icon = FontAwesomeIcons.xTwitter;
      color = Colors.white; // X logo is often white on dark backgrounds
    } else if (url.contains("instagram")) {
      icon = FontAwesomeIcons.instagram;
      color = Colors.purple;
    } else if (url.contains("tiktok")) {
      icon = FontAwesomeIcons.tiktok;
      color = Colors.black; // Tiktok logo is black/white/blue/red
    } else if (url.contains("linkedin")) {
      icon = FontAwesomeIcons.linkedin;
      color = Colors.blue;
    } else if (url.contains("pinterest")) {
      icon = FontAwesomeIcons.pinterest;
      color = Colors.red;
    } else if (url.contains("youtube")) {
      icon = FontAwesomeIcons.youtube;
      color = Colors.red;
    } else {
      // Default for email or unknown links
      icon = FontAwesomeIcons.link; // Use a generic link icon
      color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: FaIcon(icon, color: color, size: 20),
    );
  }

  Widget _buildHabilidadesSection() {
    if (_habilidades.isEmpty) {
      return Container(); // Retorna widget vazio se não houver habilidades
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FaIcon(FontAwesomeIcons.lightbulb, size: 16, color: _accentColor),
                ),
                SizedBox(width: 12),
                Text(
                  "Habilidades",
                  style: GoogleFonts.poppins(
                    color: _textPrimaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(color: _dividerColor),
            SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _habilidades.map<Widget>((habilidade) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _chipColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    habilidade["nome"] ?? "Habilidade",
                    style: GoogleFonts.poppins(
                      color: _textPrimaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObrasFavoritasSection() {
    if (_obrasFavoritas.isEmpty) {
      return Container(); // Retorna widget vazio se não houver obras favoritas
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FaIcon(FontAwesomeIcons.heart, size: 16, color: Colors.red),
                ),
                SizedBox(width: 12),
                Text(
                  "Obras Favoritas",
                  style: GoogleFonts.poppins(
                    color: _textPrimaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(color: _dividerColor),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _obrasFavoritas.length,
                itemBuilder: (context, index) {
                  final obra = _obrasFavoritas[index];
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: obra["imagemUrl"] ?? "",
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: _chipColor,
                                child: Center(
                                  child: FaIcon(FontAwesomeIcons.image,
                                      color: _textSecondaryColor),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: _chipColor,
                                child: Center(
                                  child: FaIcon(FontAwesomeIcons.triangleExclamation,
                                      color: _textSecondaryColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          obra["titulo"] ?? "Sem título",
                          style: GoogleFonts.poppins(
                            color: _textPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          obra["tipo"] ?? "Tipo não informado",
                          style: GoogleFonts.poppins(
                            color: _textSecondaryColor,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUserData || _isLoadingCurrentUser) {
      return Scaffold(
        backgroundColor: _primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              Text(
                "Carregando perfil...",
                style: GoogleFonts.poppins(
                  color: _textPrimaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: _primaryColor,
        appBar: AppBar(
          title: Text(
            "Erro ao carregar usuário",
            style: GoogleFonts.poppins(
              color: _textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: _cardColor,
          elevation: 0,
          iconTheme: IconThemeData(color: _textPrimaryColor),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red[300],
              ),
              SizedBox(height: 20),
              Text(
                "Não foi possível carregar os dados do usuário.",
                style: GoogleFonts.poppins(
                  color: _textPrimaryColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _carregarDadosUsuarioVisualizado,
                icon: Icon(Icons.refresh),
                label: Text("Tentar novamente"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final projetosPagina = _projetos.sublist(
      (_paginaAtual - 1) * _itensPorPagina,
      (_paginaAtual * _itensPorPagina).clamp(0, _projetos.length),
    );

    return Scaffold(
      backgroundColor: _primaryColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Perfil",
          style: GoogleFonts.poppins(
            color: _textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _textPrimaryColor),
        actions: [
          if (_isCurrentUser)
            Container(
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _cardColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                icon: FaIcon(FontAwesomeIcons.solidPenToSquare, color: _accentColor, size: 20),
                tooltip: 'Editar Perfil',
                onPressed: () async {
                  final bool? profileUpdated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditarPerfilScreen(
                        usuario: _usuarioAtualLogado!,
                        userData: _user!,
                      ),
                    ),
                  );

                  if (profileUpdated == true) {
                    _carregarDadosUsuarioVisualizado();
                    _carregarUsuarioLogado();
                  }
                },
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarDadosUsuarioVisualizado,
        color: _accentColor,
        backgroundColor: _cardColor,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Seção de Perfil com gradiente
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1A2233),
                        _primaryColor,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar com efeito de brilho
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _accentColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Hero(
                                  tag: 'profile-${widget.userId}',
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: _chipColor,
                                    backgroundImage: _user!["imagemUrl"] != null && _user!["imagemUrl"].isNotEmpty
                                        ? NetworkImage(_user!["imagemUrl"])
                                        : null,
                                    child: (_user!["imagemUrl"] == null || _user!["imagemUrl"].isEmpty)
                                        ? FaIcon(FontAwesomeIcons.user, size: 40, color: _textPrimaryColor)
                                        : null,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _user!["nome"] ?? "Nome Indisponível",
                                      style: GoogleFonts.poppins(
                                        color: _textPrimaryColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _accentColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _user!["profissaoNome"] ?? "Profissão não informada",
                                        style: GoogleFonts.poppins(
                                          color: _accentColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    if (_user!["redesSociais"] != null && (_user!["redesSociais"] as List).isNotEmpty)
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 12,
                                        children: (_user!["redesSociais"] as List)
                                            .map<Widget>((rede) => _buildSocialIcon(rede))
                                            .toList(),
                                      )
                                    else
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: _cardColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            FaIcon(FontAwesomeIcons.shareNodes, size: 14, color: _textSecondaryColor),
                                            SizedBox(width: 8),
                                            Text(
                                              "Redes sociais não disponíveis",
                                              style: GoogleFonts.poppins(
                                                color: _textSecondaryColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: FaIcon(FontAwesomeIcons.locationDot,
                                          color: Colors.blue, size: 14),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      _user!["cidadeNome"] != null
                                          ? "${_user!["cidadeNome"]}, ${_user!["estadoNome"] ?? ''}"
                                          : "Localização não informada",
                                      style: GoogleFonts.poppins(
                                        color: _textPrimaryColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_isCurrentUser)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // TODO: Lógica para impulsionar perfil
                                      print("Botão Impulsionar Perfil pressionado.");
                                    },
                                    icon: FaIcon(FontAwesomeIcons.bolt, size: 14),
                                    label: Text(
                                      "Impulsionar",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _accentColor,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Seção "Sobre Mim"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FaIcon(FontAwesomeIcons.user, size: 16, color: Colors.green),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Sobre Mim",
                              style: GoogleFonts.poppins(
                                color: _textPrimaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Divider(color: _dividerColor),
                        SizedBox(height: 16),
                        Text(
                          _user!["sobreMim"] ?? "Nenhuma informação disponível",
                          style: GoogleFonts.poppins(
                            color: _textSecondaryColor,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Seção de Habilidades
                _buildHabilidadesSection(),

                // Seção de Obras Favoritas
                _buildObrasFavoritasSection(),

                // Seção de Projetos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: FaIcon(FontAwesomeIcons.film, size: 16, color: Colors.purple),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Projetos Envolvidos",
                                  style: GoogleFonts.poppins(
                                    color: _textPrimaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            if (_projetos.isNotEmpty || !_isLoadingUserData)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _chipColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${_projetos.length}",
                                  style: GoogleFonts.poppins(
                                    color: _textPrimaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Divider(color: _dividerColor),
                        SizedBox(height: 16),
                        if (_projetos.isEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Icon(
                                  Icons.movie_filter_outlined,
                                  size: 60,
                                  color: _textSecondaryColor.withOpacity(0.5),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Nenhum projeto encontrado para este usuário.",
                                  style: GoogleFonts.poppins(
                                    color: _textSecondaryColor,
                                    fontSize: 15,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: projetosPagina.map((projetoData) {
                              final usuarioCriadorData = projetoData["usuarioCriador"] as Map<String, dynamic>?;
                              Usuario criadorDoProjeto = _parseUsuarioFromMap(usuarioCriadorData);

                              List<Usuario> usuariosSolicitantes = _parseUsuariosListFromMap(projetoData["usuariosSolicitantes"] as List<dynamic>?);
                              List<Usuario> pessoasEnvolvidas = _parseUsuariosListFromMap(projetoData["pessoasEnvolvidas"] as List<dynamic>?);

                              final Projeto projetoParaDetalhes = Projeto(
                                id: projetoData["id"]?.toString() ?? '',
                                titulo: projetoData["titulo"]?.toString() ?? "Título Indisponível",
                                descricao: projetoData["descricao"]?.toString() ?? "Descrição Indisponível",
                                localizacao: projetoData["localizacao"]?.toString() ?? "Localização Indisponível",
                                imagemUrl: projetoData["imagemUrl"]?.toString() ?? '',
                                tipo: projetoData["tipo"]?.toString() ?? "Tipo Desconhecido",
                                status: projetoData["status"]?.toString() ?? "Status Desconhecido",
                                usuarioCriador: criadorDoProjeto,
                                usuariosSolicitantes: usuariosSolicitantes,
                                pessoasEnvolvidas: pessoasEnvolvidas,
                              );

                              return GestureDetector(
                                onTap: () {
                                  if (_usuarioAtualLogado == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Aguarde, carregando dados do seu usuário..."))
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProjectDetailsScreen(
                                        projeto: projetoParaDetalhes,
                                        usuarioAtual: _usuarioAtualLogado!,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: _primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Imagem do projeto com overlay de status
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: projetoData["imagemUrl"] ?? '',
                                              width: double.infinity,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                color: _chipColor,
                                                child: Center(
                                                  child: FaIcon(FontAwesomeIcons.image, color: _textSecondaryColor),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                color: _chipColor,
                                                child: Center(
                                                  child: FaIcon(FontAwesomeIcons.triangleExclamation, color: _textSecondaryColor),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: projetoData["status"] == "Concluído"
                                                    ? Colors.green
                                                    : _accentColor,
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  FaIcon(
                                                    projetoData["status"] == "Concluído"
                                                        ? FontAwesomeIcons.circleCheck
                                                        : FontAwesomeIcons.circleNotch,
                                                    color: projetoData["status"] == "Concluído"
                                                        ? Colors.white
                                                        : Colors.black,
                                                    size: 12,
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    projetoData["status"] ?? "Status não informado",
                                                    style: GoogleFonts.poppins(
                                                      color: projetoData["status"] == "Concluído"
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Informações do projeto
                                      Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              projetoData["titulo"] ?? "Título Indisponível",
                                              style: GoogleFonts.poppins(
                                                color: _textPrimaryColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _chipColor,
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Text(
                                                    projetoData["tipo"] ?? "Tipo não informado",
                                                    style: GoogleFonts.poppins(
                                                      color: _textPrimaryColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Icon(
                                                  Icons.people_outline,
                                                  size: 16,
                                                  color: _textSecondaryColor,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  "${(projetoData["pessoasEnvolvidas"] as List?)?.length ?? 0} membros",
                                                  style: GoogleFonts.poppins(
                                                    color: _textSecondaryColor,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                        // Paginação
                        if (_projetos.length > _itensPorPagina)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: _paginaAtual > 1
                                      ? () {
                                    setState(() {
                                      _paginaAtual--;
                                    });
                                  }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _chipColor,
                                    foregroundColor: _textPrimaryColor,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(12),
                                    elevation: 0,
                                  ),
                                  child: Icon(Icons.arrow_back_ios, size: 16),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    "$_paginaAtual de ${(_projetos.length / _itensPorPagina).ceil()}",
                                    style: GoogleFonts.poppins(
                                      color: _textPrimaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _paginaAtual < (_projetos.length / _itensPorPagina).ceil()
                                      ? () {
                                    setState(() {
                                      _paginaAtual++;
                                    });
                                  }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _chipColor,
                                    foregroundColor: _textPrimaryColor,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(12),
                                    elevation: 0,
                                  ),
                                  child: Icon(Icons.arrow_forward_ios, size: 16),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Espaço no final
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
