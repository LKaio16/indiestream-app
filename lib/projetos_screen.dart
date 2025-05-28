// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:indiestream_app/AppColors.dart';
import 'dart:convert';
import 'package:indiestream_app/projeto_detalhes_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indiestream_app/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'api_constants.dart';

class ProjetosScreen extends StatefulWidget {
  const ProjetosScreen({super.key});

  @override
  State<ProjetosScreen> createState() => _ProjetosScreenState();
}

class _ProjetosScreenState extends State<ProjetosScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  List<dynamic> _projetos = [];
  String _filtro = "";
  Usuario? _usuarioAtualCarregado;
  bool _carregandoUsuario = true;
  bool _carregandoProjetos = false;
  bool _isSearchFocused = false;

  // Animação para os cards
  late AnimationController _animationController;

  // Cores do tema
  final Color _primaryColor = Color(0xFF1E2530);
  final Color _cardColor = Color(0xFF2A3441);
  final Color _accentColor = Color(0xFFFFC107);
  final Color _successColor = Color(0xFF4CAF50);
  final Color _dangerColor = Color(0xFFE57373);
  final Color _textPrimaryColor = Colors.white;
  final Color _textSecondaryColor = Colors.white70;

  // Headers comuns para requisições com ngrok
  final Map<String, String> _ngrokHeaders = {
    'ngrok-skip-browser-warning': 'skip-browser-warning',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Inicializa o controlador de animação
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _carregarDados();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _carregarDados();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _carregarDados() async {
    await _carregarUsuarioLogado();
    await _buscarProjetos();
  }

  Future<void> _carregarUsuarioLogado() async {
    if (!mounted) return;

    setState(() {
      _carregandoUsuario = true;
    });

    int? userIdInt = await AuthService.getUserId();

    if (userIdInt == null) {
      print("ProjetosScreen: Nenhum ID de usuário encontrado no AuthService.");
      if (mounted) {
        setState(() {
          _usuarioAtualCarregado = null;
          _carregandoUsuario = false;
        });
      }
      return;
    }

    String userIdString = userIdInt.toString();

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/user/$userIdString"),
        headers: _ngrokHeaders,
      );

      if (response.statusCode == 200) {
        final userData = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _usuarioAtualCarregado = Usuario(
              id: userData['id']?.toString() ?? userIdString,
              nome: userData['nome']?.toString() ?? "Nome Real do Usuário",
              imagemUrl: userData['imagemUrl']?.toString() ?? "https://i.ibb.co/PG4G5q3/Ellipse-1.png",
              funcao: userData['profissaoNome']?.toString(),
            );
            _carregandoUsuario = false;
          });
        }
      } else {
        print("Falha ao carregar detalhes do usuário logado: Status ${response.statusCode}");
        if (mounted) {
          setState(() {
            _usuarioAtualCarregado = null;
            _carregandoUsuario = false;
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar detalhes do usuário logado: $e");
      if (mounted) {
        setState(() {
          _usuarioAtualCarregado = null;
          _carregandoUsuario = false;
        });
      }
    }
  }

  Future<void> _buscarProjetos() async {
    if (!mounted || _carregandoProjetos) return;

    setState(() {
      _carregandoProjetos = true;
    });

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/projetos"),
        headers: _ngrokHeaders,
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _projetos = json.decode(utf8.decode(response.bodyBytes));
            _carregandoProjetos = false;
          });

          // Inicia a animação dos cards
          _animationController.reset();
          _animationController.forward();
        }
      } else {
        print("Falha ao carregar projetos: Status ${response.statusCode}");
        if (mounted) {
          setState(() {
            _projetos = [];
            _carregandoProjetos = false;
          });
        }
      }
    } catch (e) {
      print("Erro ao buscar projetos: $e");
      if (mounted) {
        setState(() {
          _projetos = [];
          _carregandoProjetos = false;
        });
      }
    }
  }

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

  List<Usuario> _parseUsuariosListFromMap(List<dynamic>? usersDataList) {
    if (usersDataList == null) {
      return [];
    }
    return usersDataList
        .where((item) => item is Map<String, dynamic>)
        .map((userData) => _parseUsuarioFromMap(userData as Map<String, dynamic>))
        .toList();
  }

  Widget _buildTag(String text, {required bool isStatus}) {
    Color bgColor;
    Color textColor;
    IconData? iconData;

    if (isStatus) {
      switch (text) {
        case "Em andamento":
        case "Pre-production":
          bgColor = _accentColor;
          textColor = Colors.black;
          iconData = FontAwesomeIcons.hourglassHalf;
          break;
        case "Concluído":
          bgColor = _successColor;
          textColor = Colors.white;
          iconData = FontAwesomeIcons.check;
          break;
        default:
          bgColor = Color(0xFF424B59);
          textColor = _textPrimaryColor;
          iconData = FontAwesomeIcons.circleInfo;
      }
    } else {
      switch (text) {
        case "Curta":
          bgColor = Color(0xFF3A4453);
          textColor = _textPrimaryColor;
          iconData = FontAwesomeIcons.film;
          break;
        case "Drama":
          bgColor = Color(0xFF3A4453);
          textColor = _textPrimaryColor;
          iconData = FontAwesomeIcons.mask;
          break;
        default:
          bgColor = Color(0xFF3A4453);
          textColor = _textPrimaryColor;
          iconData = FontAwesomeIcons.clapperboard;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconData != null) ...[
            Icon(
              iconData,
              color: textColor,
              size: 12,
            ),
            SizedBox(width: 6),
          ],
          Text(
            text,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregandoUsuario) {
      return Scaffold(
        backgroundColor: _primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Carregando seu perfil...",
                style: GoogleFonts.poppins(
                  color: _textSecondaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_usuarioAtualCarregado == null) {
      return Scaffold(
        backgroundColor: _primaryColor,
        body: Center(
          child: Container(
            padding: EdgeInsets.all(24),
            margin: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  color: _accentColor,
                  size: 64,
                ),
                SizedBox(height: 24),
                Text(
                  "Você não está logado",
                  style: GoogleFonts.poppins(
                    color: _textPrimaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Faça login para visualizar e participar de projetos na plataforma",
                  style: GoogleFonts.poppins(
                    color: _textSecondaryColor,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Adicione sua navegação para a tela de login aqui
                    print("Botão 'Ir para Login' pressionado. Implementar navegação.");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(
                    "Fazer Login",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    List<dynamic> projetosFiltrados = _projetos.where((projeto) {
      final titulo = projeto["titulo"]?.toString().toLowerCase() ?? "";
      return titulo.contains(_filtro.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: _primaryColor,
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        color: _accentColor,
        backgroundColor: _cardColor,
        displacement: 40,
        strokeWidth: 3,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: Column(
            children: [
              // Campo de pesquisa aprimorado
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 56,
                decoration: BoxDecoration(
                  color: _isSearchFocused ? _cardColor.withOpacity(0.9) : _cardColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isSearchFocused
                      ? [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                      : [],
                ),
                child: Focus(
                  onFocusChange: (hasFocus) {
                    setState(() {
                      _isSearchFocused = hasFocus;
                    });
                  },
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Pesquisar projetos...",
                      hintStyle: GoogleFonts.poppins(
                        color: _textSecondaryColor,
                        fontSize: 15,
                      ),
                      filled: false,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: _isSearchFocused ? _accentColor : _textSecondaryColor,
                        size: 22,
                      ),
                      suffixIcon: _filtro.isNotEmpty
                          ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: _textSecondaryColor,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _filtro = "";
                          });
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    style: GoogleFonts.poppins(
                      color: _textPrimaryColor,
                      fontSize: 15,
                    ),
                    cursorColor: _accentColor,
                    onChanged: (valor) {
                      setState(() {
                        _filtro = valor;
                      });

                      // Feedback tátil ao digitar
                      HapticFeedback.lightImpact();
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Contador de projetos
              if (!_carregandoProjetos && projetosFiltrados.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
                  child: Row(
                    children: [
                      Text(
                        _filtro.isEmpty
                            ? "${projetosFiltrados.length} projetos disponíveis"
                            : "${projetosFiltrados.length} resultados encontrados",
                        style: GoogleFonts.poppins(
                          color: _textSecondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_filtro.isNotEmpty) ...[
                        SizedBox(width: 4),
                        Text(
                          "para \"$_filtro\"",
                          style: GoogleFonts.poppins(
                            color: _accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // Lista de projetos
              Expanded(
                child: _carregandoProjetos
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Buscando projetos...",
                        style: GoogleFonts.poppins(
                          color: _textSecondaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
                    : _projetos.isEmpty
                    ? Center(
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _cardColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.film,
                          color: _accentColor.withOpacity(0.7),
                          size: 48,
                        ),
                        SizedBox(height: 24),
                        Text(
                          "Nenhum projeto disponível",
                          style: GoogleFonts.poppins(
                            color: _textPrimaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Puxe para baixo para atualizar ou crie seu primeiro projeto",
                          style: GoogleFonts.poppins(
                            color: _textSecondaryColor,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: _carregarDados,
                          icon: Icon(Icons.refresh),
                          label: Text("Atualizar"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _accentColor,
                            side: BorderSide(color: _accentColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : projetosFiltrados.isEmpty && _filtro.isNotEmpty
                    ? Center(
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _cardColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          color: _textSecondaryColor,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Nenhum resultado encontrado",
                          style: GoogleFonts.poppins(
                            color: _textPrimaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Não encontramos projetos com \"$_filtro\"",
                          style: GoogleFonts.poppins(
                            color: _textSecondaryColor,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _filtro = "";
                            });
                          },
                          icon: Icon(Icons.clear),
                          label: Text("Limpar pesquisa"),
                          style: TextButton.styleFrom(
                            foregroundColor: _accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: projetosFiltrados.length,
                  itemBuilder: (context, index) {
                    // Animação para entrada dos cards
                    final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          index / projetosFiltrados.length * 0.7,
                          (index + 1) / projetosFiltrados.length * 0.7 + 0.3,
                          curve: Curves.easeOutQuart,
                        ),
                      ),
                    );

                    final projetoData = projetosFiltrados[index] as Map<String, dynamic>;
                    final usuarioCriadorData = projetoData["usuarioCriador"] as Map<String, dynamic>?;
                    Usuario criadorDoProjeto = _parseUsuarioFromMap(usuarioCriadorData);
                    List<Usuario> usuariosSolicitantes = _parseUsuariosListFromMap(
                        projetoData["usuariosSolicitantes"] as List<dynamic>?);
                    List<Usuario> pessoasEnvolvidas = _parseUsuariosListFromMap(
                        projetoData["pessoasEnvolvidas"] as List<dynamic>?);

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

                    return FadeTransition(
                      opacity: itemAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(itemAnimation),
                        child: GestureDetector(
                          onTap: () async {
                            // Feedback tátil ao tocar
                            HapticFeedback.mediumImpact();

                            if (_usuarioAtualCarregado == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Aguarde, carregando dados do usuário...",
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor: _cardColor,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }

                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectDetailsScreen(
                                  projeto: projetoParaDetalhes,
                                  usuarioAtual: _usuarioAtualCarregado!,
                                ),
                              ),
                            );

                            if (mounted) {
                              _carregarDados();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20.0),
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Imagem do projeto com overlay de gradiente
                                  Stack(
                                    children: [
                                      Hero(
                                        tag: 'project-image-${projetoParaDetalhes.id}',
                                        child: CachedNetworkImage(
                                          imageUrl: projetoParaDetalhes.imagemUrl,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            height: 200,
                                            color: Color(0xFF2C3545),
                                            child: Center(
                                              child: SizedBox(
                                                width: 30,
                                                height: 30,
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) {
                                            print("Erro ao carregar imagem: $url\nErro: $error");
                                            return Container(
                                              height: 200,
                                              color: Color(0xFF2C3545),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      FontAwesomeIcons.photoFilm,
                                                      color: _textSecondaryColor,
                                                      size: 40,
                                                    ),
                                                    SizedBox(height: 12),
                                                    Text(
                                                      "Imagem não disponível",
                                                      style: GoogleFonts.poppins(
                                                        color: _textSecondaryColor,
                                                        fontSize: 14,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      // Gradiente de sobreposição para melhorar legibilidade
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 80,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.7),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Status do projeto no canto superior direito
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: _buildTag(
                                          projetoParaDetalhes.status,
                                          isStatus: true,
                                        ),
                                      ),
                                      // Tipo do projeto no canto superior esquerdo
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        child: _buildTag(
                                          projetoParaDetalhes.tipo,
                                          isStatus: false,
                                        ),
                                      ),
                                      // Título do projeto na parte inferior da imagem
                                      Positioned(
                                        bottom: 12,
                                        left: 12,
                                        right: 12,
                                        child: Text(
                                          projetoParaDetalhes.titulo,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.5),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Conteúdo do card
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Informações do criador
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: _accentColor,
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _accentColor.withOpacity(0.3),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundColor: Color(0xFF3A4453),
                                                backgroundImage: projetoParaDetalhes.usuarioCriador.imagemUrl.isNotEmpty
                                                    ? CachedNetworkImageProvider(projetoParaDetalhes.usuarioCriador.imagemUrl)
                                                    : null,
                                                child: projetoParaDetalhes.usuarioCriador.imagemUrl.isEmpty
                                                    ? Icon(
                                                  Icons.person,
                                                  size: 24,
                                                  color: _textSecondaryColor,
                                                )
                                                    : null,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  projetoParaDetalhes.usuarioCriador.nome,
                                                  style: GoogleFonts.poppins(
                                                    color: _textPrimaryColor,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  "Criador do Projeto",
                                                  style: GoogleFonts.poppins(
                                                    color: _textSecondaryColor,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Spacer(),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _primaryColor,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.people,
                                                    color: _textSecondaryColor,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    "${projetoParaDetalhes.pessoasEnvolvidas.length}",
                                                    style: GoogleFonts.poppins(
                                                      color: _textSecondaryColor,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),

                                        // Descrição do projeto
                                        Text(
                                          projetoParaDetalhes.descricao,
                                          style: GoogleFonts.poppins(
                                            color: _textSecondaryColor,
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        // Localização do projeto
                                        if (projetoParaDetalhes.localizacao.isNotEmpty &&
                                            projetoParaDetalhes.localizacao != "Localização Indisponível") ...[
                                          SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: _textSecondaryColor,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  projetoParaDetalhes.localizacao,
                                                  style: GoogleFonts.poppins(
                                                    color: _textSecondaryColor,
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],

                                        // Botão de ver detalhes
                                        SizedBox(height: 16),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              HapticFeedback.mediumImpact();

                                              if (_usuarioAtualCarregado == null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Aguarde, carregando dados do usuário...",
                                                      style: GoogleFonts.poppins(),
                                                    ),
                                                    backgroundColor: _cardColor,
                                                    behavior: SnackBarBehavior.floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ProjectDetailsScreen(
                                                    projeto: projetoParaDetalhes,
                                                    usuarioAtual: _usuarioAtualCarregado!,
                                                  ),
                                                ),
                                              );

                                              if (mounted) {
                                                _carregarDados();
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _accentColor,
                                              foregroundColor: Colors.black,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            ),
                                            child: Text(
                                              "Ver Detalhes",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
