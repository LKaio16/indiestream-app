// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:indiestream_app/AppColors.dart';
import 'package:indiestream_app/user_detalhes_screen.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'api_constants.dart';

class PessoasScreen extends StatefulWidget {
  const PessoasScreen({super.key});

  @override
  State<PessoasScreen> createState() => _PessoasScreenState();
}

class _PessoasScreenState extends State<PessoasScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  List<dynamic> _usuarios = [];
  String _filtro = "";
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isSearchFocused = false;

  // Animação para os cards
  late AnimationController _animationController;

  // Cores do tema
  final Color _primaryColor = Color(0xFF1E2530);
  final Color _cardColor = Color(0xFF2A3441);
  final Color _accentColor = Color(0xFFFFC107);
  final Color _premiumGold = Color(0xFFFFD700);
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

    _buscarUsuarios();
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
      _buscarUsuarios();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _buscarUsuarios() async {
    // Evita múltiplas chamadas simultâneas
    if (_isRefreshing) return;

    setState(() {
      _isLoading = !_isRefreshing; // Só mostra o indicador de carregamento principal se não for um refresh
      _isRefreshing = true;
    });

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/user"),
        headers: _ngrokHeaders,
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        if (decodedData is List) {
          // Ordena a lista aqui
          decodedData.sort((a, b) {
            final aPremium = a['isPremium'] ?? false;
            final bPremium = b['isPremium'] ?? false;
            // Usuários premium vêm primeiro
            if (aPremium && !bPremium) {
              return -1;
            } else if (!aPremium && bPremium) {
              return 1;
            } else {
              return 0; // Mantém a ordem original se ambos são premium ou não
            }
          });

          if (mounted) {
            setState(() {
              _usuarios = decodedData;
            });

            // Inicia a animação dos cards
            _animationController.reset();
            _animationController.forward();
          }
        } else {
          print("Erro: Resposta da API não é uma lista.");
          if (mounted) {
            setState(() {
              _usuarios = [];
            });
          }
        }
      } else {
        print("Falha ao carregar usuários: Status ${response.statusCode}");
        if (mounted) {
          setState(() {
            _usuarios = [];
          });
        }
      }
    } catch (e) {
      print("Erro ao buscar usuários: $e");
      if (mounted) {
        setState(() {
          _usuarios = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Widget _buildHabilidadeTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.lightbulb,
            color: _accentColor,
            size: 12,
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: _textPrimaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> usuariosFiltrados = _usuarios.where((usuario) {
      final nome = usuario["nome"]?.toString().toLowerCase() ?? "";
      final profissao = usuario["profissaoNome"]?.toString().toLowerCase() ?? "";
      return nome.contains(_filtro.toLowerCase()) || profissao.contains(_filtro.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: _primaryColor,
      body: RefreshIndicator(
        onRefresh: _buscarUsuarios,
        color: _accentColor,
        backgroundColor: _cardColor,
        displacement: 40,
        strokeWidth: 3,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      hintText: "Pesquisar membros...",
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

              // Contador de usuários
              if (!_isLoading && usuariosFiltrados.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
                  child: Row(
                    children: [
                      Text(
                        _filtro.isEmpty
                            ? "${usuariosFiltrados.length} membro${usuariosFiltrados.length != 1 ? 's' : ''}"
                            : "${usuariosFiltrados.length} resultado${usuariosFiltrados.length != 1 ? 's' : ''}",
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

              // Lista de usuários
              Expanded(
                child: _isLoading
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
                        "Buscando membros...",
                        style: GoogleFonts.poppins(
                          color: _textSecondaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
                    : _usuarios.isEmpty
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
                          FontAwesomeIcons.userGroup,
                          color: _accentColor.withOpacity(0.7),
                          size: 48,
                        ),
                        SizedBox(height: 24),
                        Text(
                          "Nenhum membro disponível",
                          style: GoogleFonts.poppins(
                            color: _textPrimaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Puxe para baixo para atualizar",
                          style: GoogleFonts.poppins(
                            color: _textSecondaryColor,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: _buscarUsuarios,
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
                    : usuariosFiltrados.isEmpty && _filtro.isNotEmpty
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
                          "Não encontramos membros com \"$_filtro\"",
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
                  padding: EdgeInsets.zero,
                  itemCount: usuariosFiltrados.length,
                  itemBuilder: (context, index) {
                    // Animação para entrada dos cards
                    final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          index / usuariosFiltrados.length * 0.7,
                          (index + 1) / usuariosFiltrados.length * 0.7 + 0.3,
                          curve: Curves.easeOutQuart,
                        ),
                      ),
                    );

                    final usuario = usuariosFiltrados[index];
                    final String nome = usuario['nome'] ?? 'Nome Indisponível';
                    final String? imageUrl = usuario['imagemUrl'];
                    final String profissaoNome = usuario['profissaoNome'] ?? "Profissão não informada";
                    final String cidadeNome = usuario['cidadeNome'] ?? "Cidade não informada";
                    final String? estadoNome = usuario['estadoNome'];
                    final String sobreMim = usuario['sobreMin'] ?? '';
                    final bool isPremium = usuario['isPremium'] ?? false;

                    List<dynamic> habilidadesRaw = usuario['habilidades'] ?? [];
                    List<String> habilidades = habilidadesRaw
                        .map((h) => h is Map ? h['nome']?.toString() : null)
                        .where((nome) => nome != null)
                        .cast<String>()
                        .take(2)
                        .toList();

                    final String localizacao =
                    cidadeNome == "Cidade não informada" && estadoNome == null
                        ? "Localização não informada"
                        : (cidadeNome != "Cidade não informada" ? cidadeNome : "") +
                        (estadoNome != null
                            ? (cidadeNome != "Cidade não informada"
                            ? ", $estadoNome"
                            : estadoNome)
                            : "");

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

                            final userId = usuario["id"]?.toString();
                            if (userId != null) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetalhesScreen(
                                    userId: userId,
                                  ),
                                ),
                              );

                              // Recarrega os dados ao voltar da tela de detalhes
                              if (mounted) {
                                _buscarUsuarios();
                              }
                            } else {
                              print("Erro: ID do usuário é nulo.");
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
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
                              border: isPremium
                                  ? Border.all(
                                color: _premiumGold,
                                width: 1.5,
                              )
                                  : null,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar do usuário com efeito premium
                                  Stack(
                                    children: [
                                      // Efeito de brilho para usuários premium
                                      if (isPremium)
                                        Container(
                                          width: 76,
                                          height: 76,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                _premiumGold.withOpacity(0.7),
                                                _premiumGold.withOpacity(0.0),
                                              ],
                                              stops: [0.5, 1.0],
                                            ),
                                          ),
                                        ),

                                      // Avatar do usuário
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isPremium ? _premiumGold : _cardColor,
                                            width: isPremium ? 2 : 0,
                                          ),
                                          boxShadow: isPremium
                                              ? [
                                            BoxShadow(
                                              color: _premiumGold.withOpacity(0.5),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                              : [],
                                        ),
                                        child: Hero(
                                          tag: 'user-avatar-${usuario["id"]}',
                                          child: CircleAvatar(
                                            radius: 35,
                                            backgroundColor: Color(0xFF3A4453),
                                            child: imageUrl == null || imageUrl.isEmpty
                                                ? Icon(
                                              Icons.person,
                                              size: 35,
                                              color: _textSecondaryColor,
                                            )
                                                : ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => Container(
                                                  color: Color(0xFF3A4453),
                                                  child: Center(
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
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
                                                    color: Color(0xFF3A4453),
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      size: 35,
                                                      color: _textSecondaryColor,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Indicador premium
                                      if (isPremium)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: _premiumGold,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.star,
                                              color: Colors.black,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(width: 16),

                                  // Informações do usuário
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Nome do usuário
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                nome,
                                                style: GoogleFonts.poppins(
                                                  color: _textPrimaryColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),

                                        // Profissão
                                        Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.briefcase,
                                              size: 14,
                                              color: isPremium ? _premiumGold : _accentColor,
                                            ),
                                            SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                profissaoNome,
                                                style: GoogleFonts.poppins(
                                                  color: isPremium ? _premiumGold : _textSecondaryColor,
                                                  fontSize: 14,
                                                  fontWeight: isPremium ? FontWeight.w600 : FontWeight.normal,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),

                                        // Localização
                                        if (localizacao != "Localização não informada")
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: _textSecondaryColor,
                                              ),
                                              SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  localizacao,
                                                  style: GoogleFonts.poppins(
                                                    color: _textSecondaryColor,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),

                                        // Sobre mim
                                        if (sobreMim.isNotEmpty) ...[
                                          SizedBox(height: 12),
                                          Text(
                                            sobreMim,
                                            style: GoogleFonts.poppins(
                                              color: _textPrimaryColor.withOpacity(0.9),
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],

                                        // Habilidades
                                        if (habilidades.isNotEmpty) ...[
                                          SizedBox(height: 12),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: habilidades
                                                .map((habilidade) => _buildHabilidadeTag(habilidade))
                                                .toList(),
                                          ),
                                        ],

                                        // Botão de ver perfil
                                        // SizedBox(height: 16),
                                        // Align(
                                        //   alignment: Alignment.centerRight,
                                        //   child: ElevatedButton(
                                        //     onPressed: () async {
                                        //       HapticFeedback.mediumImpact();
                                        //
                                        //       final userId = usuario["id"]?.toString();
                                        //       if (userId != null) {
                                        //         await Navigator.push(
                                        //           context,
                                        //           MaterialPageRoute(
                                        //             builder: (context) => UserDetalhesScreen(
                                        //               userId: userId,
                                        //             ),
                                        //           ),
                                        //         );
                                        //
                                        //         if (mounted) {
                                        //           _buscarUsuarios();
                                        //         }
                                        //       }
                                        //     },
                                        //     style: ElevatedButton.styleFrom(
                                        //       backgroundColor: isPremium ? _premiumGold : _accentColor,
                                        //       foregroundColor: isPremium ? Colors.black : Colors.black,
                                        //       elevation: 0,
                                        //       shape: RoundedRectangleBorder(
                                        //         borderRadius: BorderRadius.circular(12),
                                        //       ),
                                        //       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        //     ),
                                        //     child: Text(
                                        //       "Ver Perfil",
                                        //       style: GoogleFonts.poppins(
                                        //         fontWeight: FontWeight.w600,
                                        //         fontSize: 14,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
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
