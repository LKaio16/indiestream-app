// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:indiestream_app/AppColors.dart'; // Certifique-se que este arquivo existe e AppColors está definido
import 'dart:convert';
import 'package:indiestream_app/projeto_detalhes_screen.dart'; // Importa Projeto e Usuario
import 'package:google_fonts/google_fonts.dart';
import 'package:indiestream_app/auth_service.dart'; // Certifique-se de que este import está correto para seu AuthService

class ProjetosScreen extends StatefulWidget {
  const ProjetosScreen({super.key});

  @override
  State<ProjetosScreen> createState() => _ProjetosScreenState();
}

class _ProjetosScreenState extends State<ProjetosScreen> {
  List<dynamic> _projetos = [];
  String _filtro = "";
  Usuario? _usuarioAtualCarregado; // Variável para armazenar o usuário logado
  bool _carregandoUsuario = true; // Flag para estado de carregamento do usuário

  @override
  void initState() {
    super.initState();
    _buscarProjetos();
    _carregarUsuarioLogado(); // Chama a função para carregar o usuário
  }

  Future<void> _carregarUsuarioLogado() async {
    setState(() {
      _carregandoUsuario = true; // Inicia o carregamento
    });

    int? userIdInt = await AuthService.getUserId();

    if (userIdInt == null) {
      print("ProjetosScreen: Nenhum ID de usuário encontrado no AuthService.");
      if (mounted) {
        setState(() {
          _usuarioAtualCarregado = null; // Ou um usuário 'guest' se preferir
          _carregandoUsuario = false;
        });
      }
      // Considere redirecionar para a tela de login ou mostrar uma mensagem
      return;
    }

    String userIdString = userIdInt.toString();

    // =======================================================================
    // TODO: IMPLEMENTAR BUSCA REAL DOS DETALHES DO USUÁRIO
    // IMPORTANTE: Você precisa buscar o NOME, IMAGEMURL e outros detalhes
    // do usuário logado (userIdString) da sua API ou estado global.
    // O AuthService.getUserId() só retorna o ID.
    // Exemplo (substitua por sua lógica real):
    // final detalhesDoUsuario = await suaApi.buscarDetalhesUsuario(userIdString);
    // final nomeUsuario = detalhesDoUsuario['nome'];
    // final imagemUrlUsuario = detalhesDoUsuario['imagemUrl'];
    // final funcaoUsuario = detalhesDoUsuario['funcao'];
    // =======================================================================

    // Usando dados placeholder para nome/imagemUrl enquanto a busca real não está implementada.
    // SUBSTITUA PELOS DADOS REAIS DO SEU USUÁRIO LOGADO!
    print("ProjetosScreen: Usuário ID $userIdString encontrado. Usando dados placeholder."); // Log para depuração

    if (mounted) {
      setState(() {
        _usuarioAtualCarregado = Usuario(
          id: userIdString, // ID CORRETO E COMO STRING!
          nome: "Nome Real do Usuário", // SUBSTITUA! Ex: nomeUsuario
          imagemUrl: "https://i.ibb.co/PG4G5q3/Ellipse-1.png", // SUBSTITUA! Use uma URL real ou placeholder adequada.
          funcao: "Função Real", // SUBSTITUA! (opcional) Ex: funcaoUsuario
        );
        _carregandoUsuario = false; // Termina o carregamento
      });
    }
  }

  Future<void> _buscarProjetos() async {
    try {
      final response =
      await http.get(Uri.parse("http://localhost:8080/projetos"));
      if (response.statusCode == 200) {
        setState(() {
          _projetos = json.decode(utf8.decode(response.bodyBytes));
        });
      } else {
        print("Falha ao carregar projetos: Status ${response.statusCode}");
        setState(() {
          _projetos = [];
        });
      }
    } catch (e) {
      print("Erro ao buscar projetos: $e");
      setState(() {
        _projetos = [];
      });
    }
  }

  // Função auxiliar para converter um Map JSON em um objeto Usuario
  Usuario _parseUsuarioFromMap(Map<String, dynamic>? userData) {
    if (userData == null) {
      // Se os dados do usuário forem nulos, retorne um usuário placeholder.
      print(
          "Aviso: Dados do usuário (criador/membro) ausentes na API, usando placeholders.");
      return Usuario(
        id: 'unknown_id_${DateTime.now().millisecondsSinceEpoch}', // ID único de fallback
        nome: 'Usuário Desconhecido',
        imagemUrl: '', // URL de imagem vazia ou um placeholder padrão
        funcao: null,
      );
    }
    return Usuario(
      id: userData['id']?.toString() ??
          'fallback_id_${DateTime.now().millisecondsSinceEpoch}',
      nome: userData['nome']?.toString() ?? 'Nome Indisponível',
      imagemUrl: userData['imagemUrl']?.toString() ?? '', // Garanta que não seja nulo
      funcao: userData['funcao']?.toString(), // 'funcao' é nullable no modelo Usuario
    );
  }

  // Função auxiliar para converter uma lista de Maps JSON em uma List<Usuario>
  List<Usuario> _parseUsuariosListFromMap(List<dynamic>? usersDataList) {
    if (usersDataList == null) {
      return []; // Retorna lista vazia se não houver dados
    }
    return usersDataList
        .where((item) =>
    item is Map<String, dynamic>) // Filtra para garantir que cada item é um Map
        .map((userData) => _parseUsuarioFromMap(userData as Map<String, dynamic>))
        .toList();
  }

  Widget _buildTag(String text, {required bool isStatus}) {
    Color bgColor;
    Color textColor;

    if (isStatus) {
      switch (text) {
        case "Em andamento":
        case "Pre-production": // Adicionado para consistência com ProjectDetailsScreen
          bgColor = Colors.amber;
          textColor = Colors.black;
          break;
        case "Concluído":
          bgColor = Colors.blueAccent;
          textColor = Colors.white;
          break;
        default:
          bgColor = Colors.grey[800]!;
          textColor = Colors.white70;
      }
    } else {
      // Para 'tipo' de projeto
      switch (text) {
        case "Curta":
        case "Drama": // Adicionado para consistência
          bgColor = Colors.grey[700]!;
          textColor = Colors.white;
          break;
        default:
          bgColor = Colors.grey[800]!;
          textColor = Colors.white70;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregandoUsuario) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
            child: CircularProgressIndicator(
                color: Colors.amber)), // Indicador de carregamento
      );
    }

    if (_usuarioAtualCarregado == null) {
      // Caso o usuário não esteja logado ou não pôde ser carregado
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Você não está logado.",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // TODO: Adicione sua navegação para a tela de login aqui
                  // Exemplo: Navigator.of(context).pushReplacementNamed('/login');
                  print("Botão 'Ir para Login' pressionado. Implementar navegação.");
                },
                child: Text("Ir para Login"),
              )
            ],
          ),
        ),
      );
    }

    // Se chegou aqui, _usuarioAtualCarregado não é nulo e não está carregando
    List<dynamic> projetosFiltrados = _projetos.where((projeto) {
      final titulo = projeto["titulo"]?.toString().toLowerCase() ?? "";
      return titulo.contains(_filtro.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Pesquisar projetos...",
                hintStyle: GoogleFonts.interTight(color: Colors.white70),
                filled: true,
                fillColor: AppColors.inputFieldBackground,
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.inter(color: Colors.white),
              onChanged: (valor) {
                setState(() {
                  _filtro = valor;
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _projetos.isEmpty && _filtro.isEmpty
                  ? const Center(
                  child: CircularProgressIndicator(color: Colors.amber))
                  : projetosFiltrados.isEmpty && _filtro.isNotEmpty
                  ? Center(
                  child: Text("Nenhum projeto encontrado.",
                      style: GoogleFonts.inter(color: Colors.white70)))
                  : ListView.builder(
                itemCount: projetosFiltrados.length,
                itemBuilder: (context, index) {
                  // Garantir que projetoData seja um Map<String, dynamic>
                  final projetoData =
                  projetosFiltrados[index] as Map<String, dynamic>;

                  // Parse do criador do projeto
                  final usuarioCriadorData =
                  projetoData["usuarioCriador"] as Map<String, dynamic>?;
                  Usuario criadorDoProjeto =
                  _parseUsuarioFromMap(usuarioCriadorData);

                  // Parse das listas de usuários (solicitantes e envolvidos)
                  // Se a API não fornecer essas listas na rota /projetos, elas serão vazias.
                  List<Usuario> usuariosSolicitantes =
                  _parseUsuariosListFromMap(
                      projetoData["usuariosSolicitantes"] as List<dynamic>?);
                  List<Usuario> pessoasEnvolvidas =
                  _parseUsuariosListFromMap(
                      projetoData["pessoasEnvolvidas"] as List<dynamic>?);

                  // Construir o objeto Projeto completo
                  final Projeto projetoParaDetalhes = Projeto(
                    id: projetoData["id"]?.toString() ?? '',
                    titulo: projetoData["titulo"]?.toString() ??
                        "Título Indisponível",
                    descricao: projetoData["descricao"]?.toString() ??
                        "Descrição Indisponível",
                    localizacao: projetoData["localizacao"]
                        ?.toString() ??
                        "Localização Indisponível", // Campo adicionado ao parse
                    imagemUrl: projetoData["imagemUrl"]?.toString() ?? '',
                    tipo: projetoData["tipo"]?.toString() ??
                        "Tipo Desconhecido",
                    status: projetoData["status"]?.toString() ??
                        "Status Desconhecido",
                    usuarioCriador: criadorDoProjeto,
                    usuariosSolicitantes: usuariosSolicitantes,
                    pessoasEnvolvidas: pessoasEnvolvidas,
                  );

                  return GestureDetector(
                    onTap: () {
                      // Verifica se o usuário atual foi carregado antes de navegar
                      if (_usuarioAtualCarregado == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Aguarde, carregando dados do usuário...")),
                        );
                        return; // Não navega se o usuário não foi carregado
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailsScreen(
                            projeto:
                            projetoParaDetalhes, // Passa o objeto Projeto
                            usuarioAtual: _usuarioAtualCarregado!, // Passa o usuário logado (garantido não nulo aqui)
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: const Color(0xFF1F2937), // Mesma cor do exemplo anterior
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: CachedNetworkImage(
                                imageUrl: projetoParaDetalhes
                                    .imagemUrl, // Usar do objeto Projeto
                                height: 180,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(
                                      height: 180,
                                      color: Colors.grey[800],
                                      child: Center(
                                        child: Text(
                                          "Carregando imagem...", // Mensagem mais amigável
                                          style: GoogleFonts.inter(
                                              color: Colors.white54,
                                              fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                errorWidget: (context, url, error) {
                                  print(
                                      "Erro ao carregar imagem: $url\nErro: $error");
                                  return Container(
                                    height: 180,
                                    color: AppColors
                                        .inputFieldBackgroundAlt, // Usar AppColors se definido
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons
                                                .broken_image_outlined, // Ícone alternativo
                                            color: Colors.white54,
                                            size: 50,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Imagem não disponível",
                                            style: GoogleFonts.inter(
                                                color: Colors.white54,
                                                fontSize: 14),
                                            textAlign:
                                            TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.grey[
                                      700], // Cor de fundo do avatar
                                      backgroundImage: projetoParaDetalhes
                                          .usuarioCriador
                                          .imagemUrl
                                          .isNotEmpty
                                          ? CachedNetworkImageProvider(
                                          projetoParaDetalhes
                                              .usuarioCriador
                                              .imagemUrl) // Usar imagem do criador
                                          : null, // Sem imagem se URL vazia
                                      child: projetoParaDetalhes
                                          .usuarioCriador
                                          .imagemUrl
                                          .isEmpty
                                          ? Icon(Icons.person,
                                          size: 24,
                                          color: Colors.white70) // Ícone se sem imagem
                                          : null,
                                    ),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            projetoParaDetalhes
                                                .titulo, // Usar do objeto Projeto
                                            style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight
                                                    .w600), // Ajuste de peso
                                            maxLines: 2,
                                            overflow:
                                            TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            projetoParaDetalhes
                                                .usuarioCriador
                                                .nome, // Usar do objeto Projeto
                                            style: GoogleFonts.inter(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  projetoParaDetalhes
                                      .descricao, // Usar do objeto Projeto
                                  style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(
                                          0.85), // Leve ajuste de opacidade
                                      fontSize: 14,
                                      height: 1.5 // Melhorar legibilidade
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    _buildTag(
                                        projetoParaDetalhes
                                            .status, // Usar do objeto Projeto
                                        isStatus: true),
                                    const SizedBox(width: 8),
                                    _buildTag(
                                        projetoParaDetalhes
                                            .tipo, // Usar do objeto Projeto
                                        isStatus: false),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
}