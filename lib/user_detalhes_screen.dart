import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'auth_service.dart';
import 'projeto_detalhes_screen.dart';

class UserDetalhesScreen extends StatefulWidget {
  final String userId;

  const UserDetalhesScreen({super.key, required this.userId});

  @override
  State<UserDetalhesScreen> createState() => _UserDetalhesScreenState();
}

class _UserDetalhesScreenState extends State<UserDetalhesScreen> {
  Map<String, dynamic>? _user;
  List<dynamic> _projetos = [];
  List<dynamic> _habilidades = [];
  List<dynamic> _obrasFavoritas = [];
  bool _isLoading = true;
  bool _isCurrentUser = false;
  int _paginaAtual = 1;
  final int _itensPorPagina = 3;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
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

        final currentUserId = await AuthService.getUserId();
        setState(() {
          _isCurrentUser = currentUserId.toString() == widget.userId;
        });

        final projetosResponse = await http.get(
          Uri.parse("http://localhost:8080/projetos?userId=${widget.userId}"),
        );

        if (projetosResponse.statusCode == 200) {
          setState(() {
            _projetos = json.decode(utf8.decode(projetosResponse.bodyBytes));
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar dados: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSocialIcon(String url) {
    if (url.contains("facebook")) {
      return const FaIcon(FontAwesomeIcons.facebook,
          color: Colors.blue, size: 24);
    } else if (url.contains("twitter") || url.contains("x.com")) {
      return const FaIcon(FontAwesomeIcons.xTwitter,
          color: Colors.black, size: 24);
    } else if (url.contains("instagram")) {
      return const FaIcon(FontAwesomeIcons.instagram,
          color: Colors.purple, size: 24);
    } else if (url.contains("tiktok")) {
      return const FaIcon(FontAwesomeIcons.tiktok,
          color: Colors.black, size: 24);
    } else if (url.contains("linkedin")) {
      return const FaIcon(FontAwesomeIcons.linkedin,
          color: Colors.blue, size: 24);
    } else if (url.contains("pinterest")) {
      return const FaIcon(FontAwesomeIcons.pinterest,
          color: Colors.red, size: 24);
    } else if (url.contains("youtube")) {
      return const FaIcon(FontAwesomeIcons.youtube,
          color: Colors.red, size: 24);
    } else {
      // Email ou genérico
      return const FaIcon(FontAwesomeIcons.envelope,
          color: Colors.grey, size: 24);
    }
  }

  Widget _buildHabilidadesSection() {
    if (_habilidades.isEmpty) {
      return Container(); // Retorna widget vazio se não houver habilidades
    }

    return Padding(
      padding: const EdgeInsets.all(16),
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
      padding: const EdgeInsets.all(16),
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Usuário não encontrado"),
          backgroundColor: Colors.grey[900],
        ),
        body: const Center(
          child: Text(
            "Usuário não encontrado",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

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
                        backgroundImage: _user!["imagemUrl"] != null
                            ? NetworkImage(_user!["imagemUrl"])
                            : null,
                        child: _user!["imagemUrl"] == null
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
                              _user!["nome"],
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
                                _user!["redesSociais"].isNotEmpty)
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: (_user!["redesSociais"] as List)
                                    .map<Widget>(
                                        (rede) => _buildSocialIcon(rede))
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
                                ? "${_user!["cidadeNome"]}, ${_user!["estadoNome"]}"
                                : "Localização não informada",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      if (_isCurrentUser)
                        ElevatedButton.icon(
                          onPressed: () {
                            // Lógica para impulsionar perfil
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
                        "Nenhum projeto encontrado",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    Column(
                      children: projetosPagina.map((projeto) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjetoDetalhesScreen(
                                  projetoId: projeto["id"].toString(),
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
                                      imageUrl: projeto["imagemUrl"],
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
                                          projeto["titulo"],
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
                                              projeto["status"] == "Concluído"
                                                  ? FontAwesomeIcons.circleCheck
                                                  : FontAwesomeIcons
                                                  .circleNotch,
                                              color: projeto["status"] ==
                                                  "Concluído"
                                                  ? Colors.green
                                                  : Colors.amber,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              projeto["status"] ??
                                                  "Status não informado",
                                              style: TextStyle(
                                                color: projeto["status"] ==
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