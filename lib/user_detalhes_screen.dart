// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'auth_service.dart'; // Certifique-se de que este import está correto
import 'projeto_detalhes_screen.dart'; // Importa Projeto e Usuario (verifique se estão definidos aqui)

class UserDetalhesScreen extends StatefulWidget {
  final String userId;

  const UserDetalhesScreen({super.key, required this.userId});

  @override
  State<UserDetalhesScreen> createState() => _UserDetalhesScreenState();
}

class _UserDetalhesScreenState extends State<UserDetalhesScreen> {
  Map<String, dynamic>? _user; // The user whose profile is being viewed
  Usuario? _usuarioAtualLogado; // The currently logged-in user
  List<dynamic> _projetos = [];
  List<dynamic> _habilidades = [];
  List<dynamic> _obrasFavoritas = [];
  bool _isLoadingUserData = true; // Loading state for the viewed user's data
  bool _isLoadingCurrentUser = true; // Loading state for the logged-in user's data
  bool _isCurrentUser = false;
  int _paginaAtual = 1;
  final int _itensPorPagina = 3;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuarioVisualizado(); // Load the user profile being viewed
    _carregarUsuarioLogado(); // Load the currently logged-in user
  }

  // Function to fetch the user whose profile is being viewed
  Future<void> _carregarDadosUsuarioVisualizado() async {
    setState(() {
      _isLoadingUserData = true;
    });
    try {
      final userResponse = await http.get(
        Uri.parse("http://localhost:8080/user/${widget.userId}"),
      );

      if (userResponse.statusCode == 200) {
        final userData = json.decode(utf8.decode(userResponse.bodyBytes));

        setState(() {
          _user = userData;
          _habilidades = userData["habilidades"] ?? [];
          _obrasFavoritas = userData["obrasFavoritas"] ?? [];
        });

        // Fetch projects associated with the viewed user
        final projetosResponse = await http.get(
          Uri.parse("http://localhost:8080/projetos?userId=${widget.userId}"),
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
          _user = null; // Indicate user not found
          _projetos = [];
          _habilidades = [];
          _obrasFavoritas = [];
        });
      }
    } catch (e) {
      print("Erro ao carregar dados do usuário: $e");
      setState(() {
        _user = null; // Indicate error loading user
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

  // Function to fetch the currently logged-in user's details
  Future<void> _carregarUsuarioLogado() async {
    setState(() {
      _isLoadingCurrentUser = true;
    });

    int? userIdInt = await AuthService.getUserId();

    if (userIdInt == null) {
      print("UserDetalhesScreen: Nenhum ID de usuário logado encontrado no AuthService.");
      if(mounted) {
        setState(() {
          _usuarioAtualLogado = null; // No logged-in user
          _isLoadingCurrentUser = false;
          // Determine if the viewed user is the current user
          _isCurrentUser = false;
        });
      }
      return;
    }

    String userIdString = userIdInt.toString();

    // TODO: IMPLEMENTAR BUSCA REAL DOS DETALHES DO USUÁRIO LOGADO
    // Você precisa buscar o NOME, IMAGEMURL e outros detalhes
    // do usuário logado (userIdString) da sua API ou estado global.
    // Substitua a chamada abaixo pela sua lógica real.
    // Exemplo:
    // final detalhesDoUsuario = await suaApi.buscarDetalhesUsuario(userIdString);
    // final nomeUsuario = detalhesDoUsuario['nome'];
    // final imagemUrlUsuario = detalhesDoUsuario['imagemUrl'];
    // final funcaoUsuario = detalhesDoUsuario['funcao'];

    print("UserDetalhesScreen: Usuário logado ID $userIdString encontrado. Usando dados placeholder."); // Log para depuração

    if(mounted) {
      setState(() {
        _usuarioAtualLogado = Usuario(
          id: userIdString, // ID CORRETO E COMO STRING!
          nome: "Nome Real do Usuário Logado", // SUBSTITUA!
          imagemUrl: "https://i.ibb.co/PG4G5q3/Ellipse-1.png", // SUBSTITUA!
          funcao: "Função Real Logado", // SUBSTITUA! (opcional)
        );
        _isLoadingCurrentUser = false;
        // Determine if the viewed user is the current user
        _isCurrentUser = userIdString == widget.userId;
      });
    }
  }


  // Helper function to parse a single Usuario from map (copied from ProjetosScreen)
  Usuario _parseUsuarioFromMap(Map<String, dynamic>? userData) {
    if (userData == null) {
      print(
          "Aviso: Dados do usuário (criador/membro) ausentes na API, usando placeholders.");
      return Usuario(
        id: 'unknown_id_${DateTime.now().millisecondsSinceEpoch}',
        nome: 'Usuário Desconhecido',
        imagemUrl: '',
        funcao: null,
      );
    }
    return Usuario(
      id: userData['id']?.toString() ??
          'fallback_id_${DateTime.now().millisecondsSinceEpoch}',
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

    return FaIcon(icon, color: color, size: 24);
  }


  Widget _buildHabilidadesSection() {
    if (_habilidades.isEmpty) {
      return Container(); // Retorna widget vazio se não houver habilidades
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Ajuste padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              FaIcon(FontAwesomeIcons.lightbulb,
                  size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Habilidades",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _habilidades.map<Widget>((habilidade) {
              return Chip(
                label: Text(
                  habilidade["nome"] ?? "Habilidade",
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.grey[800],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildObrasFavoritasSection() {
    if (_obrasFavoritas.isEmpty) {
      return Container(); // Retorna widget vazio se não houver obras favoritas
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Ajuste padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              FaIcon(FontAwesomeIcons.heart,
                  size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Obras Favoritas",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _obrasFavoritas.length,
              itemBuilder: (context, index) {
                final obra = _obrasFavoritas[index];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: obra["imagemUrl"] ?? "",
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: FaIcon(FontAwesomeIcons.image,
                                  color: Colors.white54),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: FaIcon(
                                  FontAwesomeIcons.triangleExclamation,
                                  color: Colors.white54),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        obra["titulo"] ?? "Sem título",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator if either user data or current user data is loading
    if (_isLoadingUserData || _isLoadingCurrentUser) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error if the viewed user's data failed to load
    if (_user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Erro ao carregar usuário"), // Adjusted title
          backgroundColor: Colors.grey[900],
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            "Não foi possível carregar os dados do usuário.", // Adjusted message
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Handle case where logged-in user data failed to load but viewed user loaded
    // The ProjectDetailsScreen will need the logged-in user, so we should inform the user
    // or prevent navigation if the logged-in user is null.
    // For now, we'll allow viewing the profile but navigation to project details
    // will check for the logged-in user.

    final projetosPagina = _projetos.sublist(
      (_paginaAtual - 1) * _itensPorPagina,
      (_paginaAtual * _itensPorPagina).clamp(0, _projetos.length),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Perfil",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Seção de Perfil
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[700], // Placeholder background
                        backgroundImage: _user!["imagemUrl"] != null && _user!["imagemUrl"].isNotEmpty
                            ? NetworkImage(_user!["imagemUrl"])
                            : null,
                        child: (_user!["imagemUrl"] == null || _user!["imagemUrl"].isEmpty)
                            ? const FaIcon(FontAwesomeIcons.user,
                            size: 40, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _user!["nome"] ?? "Nome Indisponível",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _user!["profissaoNome"] ??
                                  "Profissão não informada",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_user!["redesSociais"] != null &&
                                (_user!["redesSociais"] as List).isNotEmpty)
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: (_user!["redesSociais"] as List)
                                    .map<Widget>((rede) => _buildSocialIcon(rede))
                                    .toList(),
                              )
                            else
                              const Text(
                                "Redes sociais não disponíveis",
                                style: TextStyle(color: Colors.white70),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.locationDot,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _user!["cidadeNome"] != null
                                ? "${_user!["cidadeNome"]}, ${_user!["estadoNome"] ?? ''}" // Added null check for estadoNome
                                : "Localização não informada",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      // Only show Impulsionar button if it's the current user's profile
                      if (_isCurrentUser)
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Lógica para impulsionar perfil
                            print("Botão Impulsionar Perfil pressionado.");
                          },
                          icon: const FaIcon(FontAwesomeIcons.bolt, size: 14),
                          label: const Text("Impulsionar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Seção "Sobre Mim"
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      FaIcon(FontAwesomeIcons.user,
                          size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Sobre Mim",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  Text(
                    _user!["sobreMim"] ?? "Nenhuma informação disponível",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Seção de Habilidades
            _buildHabilidadesSection(),

            // Seção de Obras Favoritas
            _buildObrasFavoritasSection(),

            // Seção de Projetos
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          FaIcon(FontAwesomeIcons.film,
                              size: 16, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Projetos Envolvidos",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Display project count only if projects are loaded
                      if (_projetos.isNotEmpty || !_isLoadingUserData) // Show count if loaded or if load failed but list is empty
                        Text(
                          "${_projetos.length} Projetos",
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  if (_projetos.isEmpty)
                    const Center(
                      child: Text(
                        "Nenhum projeto encontrado para este usuário.", // Adjusted message
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Column(
                      children: projetosPagina.map((projetoData) {
                        // Parse project details to a Projeto object for navigation
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
                            // Check if the logged-in user data is available before navigating
                            if (_usuarioAtualLogado == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Aguarde, carregando dados do seu usuário..."))
                              );
                              return; // Prevent navigation if logged-in user is not loaded
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectDetailsScreen(
                                  projeto: projetoParaDetalhes, // Pass the full Projeto object
                                  usuarioAtual: _usuarioAtualLogado!, // Pass the logged-in user
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.grey[900],
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: projetoData["imagemUrl"] ?? '', // Use imagemUrl from data
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[800],
                                        child: const Center(
                                          child: FaIcon(FontAwesomeIcons.image,
                                              color: Colors.white54),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: Colors.grey[800],
                                            child: const Center(
                                              child: FaIcon(
                                                  FontAwesomeIcons
                                                      .triangleExclamation,
                                                  color: Colors.white54),
                                            ),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          projetoData["titulo"] ?? "Título Indisponível", // Use titulo from data
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            FaIcon(
                                              projetoData["status"] == "Concluído"
                                                  ? FontAwesomeIcons.circleCheck
                                                  : FontAwesomeIcons
                                                  .circleNotch,
                                              color: projetoData["status"] ==
                                                  "Concluído"
                                                  ? Colors.green
                                                  : Colors.amber,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              projetoData["status"] ??
                                                  "Status não informado",
                                              style: TextStyle(
                                                color: projetoData["status"] ==
                                                    "Concluído"
                                                    ? Colors.green
                                                    : Colors.amber,
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
                          ),
                        );
                      }).toList(),
                    ),
                  if (_projetos.length > _itensPorPagina)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.chevronLeft,
                                color: Colors.white),
                            onPressed: _paginaAtual > 1
                                ? () {
                              setState(() {
                                _paginaAtual--;
                              });
                            }
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "$_paginaAtual / ${(_projetos.length / _itensPorPagina).ceil()}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.chevronRight,
                                color: Colors.white),
                            onPressed: _paginaAtual <
                                (_projetos.length / _itensPorPagina).ceil()
                                ? () {
                              setState(() {
                                _paginaAtual++;
                              });
                            }
                                : null,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}