// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import "dart:convert";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:google_fonts/google_fonts.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:cached_network_image/cached_network_image.dart";

import "AppColors.dart";
import "api_constants.dart";
import "user_detalhes_screen.dart";

// Modelo de dados simulado (substituir com seus modelos reais)
class Usuario {
  final String id;
  final String nome;
  final String imagemUrl;
  final String? funcao;

  Usuario({required this.id, required this.nome, required this.imagemUrl, this.funcao});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'].toString(),
      nome: json['nome'],
      imagemUrl: json['imagemUrl'] ?? '',
      funcao: json['funcao'],
    );
  }
}

class Projeto {
  final String id;
  final String titulo;
  final String descricao;
  final String localizacao;
  final String imagemUrl;
  final String tipo;
  final String status;
  final Usuario usuarioCriador;
  List<Usuario> usuariosSolicitantes;
  List<Usuario> pessoasEnvolvidas;

  Projeto({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.localizacao,
    required this.imagemUrl,
    required this.tipo,
    required this.status,
    required this.usuarioCriador,
    required this.usuariosSolicitantes,
    required this.pessoasEnvolvidas,
  });

  factory Projeto.fromJson(Map<String, dynamic> json) {
    return Projeto(
      id: json['id'].toString(),
      titulo: json['titulo'],
      descricao: json['descricao'],
      localizacao: json['localizacao'],
      imagemUrl: json['imagemUrl'] ?? '',
      tipo: json['tipo'],
      status: json['status'],
      usuarioCriador: Usuario.fromJson(json['usuarioCriador']),
      usuariosSolicitantes: (json['usuariosSolicitantes'] as List<dynamic>?)
          ?.map((i) => Usuario.fromJson(i as Map<String, dynamic>))
          .toList() ?? [],
      pessoasEnvolvidas: (json['pessoasEnvolvidas'] as List<dynamic>?)
          ?.map((i) => Usuario.fromJson(i as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class ProjectDetailsScreen extends StatefulWidget {
  final Projeto projeto;
  final Usuario usuarioAtual;

  const ProjectDetailsScreen({Key? key, required this.projeto, required this.usuarioAtual}) : super(key: key);

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> with SingleTickerProviderStateMixin {
  late bool isCriador;
  late bool estaSolicitando;
  late bool estaEnvolvido;
  bool _isLoading = false;
  late Projeto _projetoAtual;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Cores do tema
  final Color _primaryColor = Color(0xFF1E2530);
  final Color _cardColor = Color(0xFF2A3441);
  final Color _accentColor = Color(0xFFFFC107);
  final Color _successColor = Color(0xFF4CAF50);
  final Color _dangerColor = Color(0xFFE57373);
  final Color _textPrimaryColor = Colors.white;
  final Color _textSecondaryColor = Colors.white70;
  final Color _dividerColor = Colors.white24;

  static const String _baseUrl = '${ApiConstants.baseUrl}/projetos';
  static const Map<String, String> _ngrokHeaders = {
    'ngrok-skip-browser-warning': 'skip-browser-warning',
    'Content-Type': 'application/json',
  };

  @override
  void initState() {
    super.initState();
    _projetoAtual = widget.projeto;
    _updateUserRoles();

    // Configuração da animação
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

    // Carrega os dados atualizados ao entrar na tela
    _carregarDadosProjeto();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateUserRoles() {
    setState(() {
      isCriador = _projetoAtual.usuarioCriador.id == widget.usuarioAtual.id;
      estaSolicitando = _projetoAtual.usuariosSolicitantes.any((user) => user.id == widget.usuarioAtual.id);
      estaEnvolvido = _projetoAtual.pessoasEnvolvidas.any((user) => user.id == widget.usuarioAtual.id);
    });
  }

  void _navegarParaPerfil(Usuario usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetalhesScreen(
          userId: usuario.id,
        ),
      ),
    );
  }

  Future<void> _carregarDadosProjeto() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/${_projetoAtual.id}'),
        headers: _ngrokHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _projetoAtual = Projeto.fromJson(data);
          _updateUserRoles();
          _isLoading = false;
        });
      } else {
        throw Exception('Falha ao carregar dados do projeto: ${response.statusCode}');
      }
    } catch (e) {
      print("Erro ao carregar dados do projeto: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao atualizar dados. Tente novamente."),
              backgroundColor: _dangerColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, Color> _getChipColors(String text, bool isStatus) {
    Color bgColor;
    Color textColor;

    if (isStatus) {
      switch (text) {
        case "Em andamento":
        case "Pre-production":
          bgColor = _accentColor;
          textColor = Colors.black;
          break;
        case "Concluído":
          bgColor = _successColor;
          textColor = Colors.white;
          break;
        default:
          bgColor = _cardColor;
          textColor = _textPrimaryColor;
      }
    } else {
      switch (text) {
        case "Curta":
        case "Drama":
          bgColor = _cardColor;
          textColor = _textPrimaryColor;
          break;
        default:
          bgColor = Color(0xFF3A4453);
          textColor = _textPrimaryColor;
      }
    }
    return {"bg": bgColor, "text": textColor};
  }

  Future<void> _aceitarSolicitacao(Usuario solicitante) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/${_projetoAtual.id}/add-pessoa/${solicitante.id}'),
        headers: _ngrokHeaders,
      );

      if (response.statusCode == 200) {
        await _carregarDadosProjeto();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text("${solicitante.nome} foi adicionado ao projeto."),
                    ),
                  ],
                ),
                backgroundColor: _successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              )
          );
        }
      } else {
        final errorMessage = utf8.decode(response.bodyBytes);
        throw Exception('Falha ao aceitar solicitação: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print("Erro ao aceitar solicitação: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao aceitar solicitação. Tente novamente."),
              backgroundColor: _dangerColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
        );
      }
    }
  }

  Future<void> _rejeitarSolicitacao(Usuario solicitante) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/${_projetoAtual.id}/remove-solicitante/${solicitante.id}'),
        headers: _ngrokHeaders,
      );

      if (response.statusCode == 200) {
        await _carregarDadosProjeto();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Solicitação de ${solicitante.nome} rejeitada."),
                backgroundColor: Color(0xFF424B59),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              )
          );
        }
      } else {
        final errorMessage = utf8.decode(response.bodyBytes);
        throw Exception('Falha ao rejeitar solicitação: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print("Erro ao rejeitar solicitação: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao rejeitar solicitação. Tente novamente."),
              backgroundColor: _dangerColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
        );
      }
    }
  }

  Future<void> _removerMembro(Usuario membro) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirmar Remoção",
          style: GoogleFonts.poppins(
            color: _textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Tem certeza que deseja remover ${membro.nome} do projeto?",
          style: GoogleFonts.poppins(
            color: _textSecondaryColor,
            fontSize: 16,
          ),
        ),
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: _textPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              "Cancelar",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              "Remover",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Aqui você implementaria a chamada à API para remover o membro
        // Por enquanto, vamos apenas simular a remoção no estado local
        setState(() {
          _projetoAtual.pessoasEnvolvidas.removeWhere((user) => user.id == membro.id);
          _updateUserRoles();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.person_remove, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text("${membro.nome} foi removido do projeto."),
                    ),
                  ],
                ),
                backgroundColor: Color(0xFF424B59),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              )
          );
        }
      } catch (e) {
        print("Erro ao remover membro: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Erro ao remover membro. Tente novamente."),
                backgroundColor: _dangerColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              )
          );
        }
      }
    }
  }

  Future<void> _solicitarParticipacao() async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/${_projetoAtual.id}/add-solicitante/${widget.usuarioAtual.id}'),
        headers: _ngrokHeaders,
      );

      if (response.statusCode == 200) {
        await _carregarDadosProjeto();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text("Solicitação para participar enviada com sucesso!"),
                    ),
                  ],
                ),
                backgroundColor: _successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              )
          );
        }
      } else {
        final errorMessage = utf8.decode(response.bodyBytes);
        throw Exception('Falha ao solicitar participação: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print("Erro ao solicitar participação: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao enviar solicitação. Tente novamente."),
              backgroundColor: _dangerColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
        );
      }
    }
  }

  Future<void> _excluirProjeto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirmar Exclusão",
          style: GoogleFonts.poppins(
            color: _textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Tem certeza que deseja excluir este projeto? Esta ação não pode ser desfeita.",
          style: GoogleFonts.poppins(
            color: _textSecondaryColor,
            fontSize: 16,
          ),
        ),
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: _textPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              "Cancelar",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              "Excluir",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(
          Uri.parse('$_baseUrl/${_projetoAtual.id}'),
          headers: _ngrokHeaders,
        );

        if (response.statusCode == 204) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text("Projeto excluído com sucesso!"),
                      ),
                    ],
                  ),
                  backgroundColor: _successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                )
            );
            Navigator.of(context).pop();
          }
        } else {
          final errorMessage = response.bodyBytes.isNotEmpty ? utf8.decode(response.bodyBytes) : "Erro desconhecido";
          throw Exception('Falha ao deletar projeto: ${response.statusCode} - $errorMessage');
        }
      } catch (e) {
        print("Erro ao excluir projeto: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Erro ao excluir projeto. Tente novamente."),
                backgroundColor: _dangerColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              )
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: _carregarDadosProjeto,
              tooltip: "Atualizar dados",
            ),
          ),
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                // Ação para o menu de três pontos
                showModalBottomSheet(
                  context: context,
                  backgroundColor: _cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.share, color: _textPrimaryColor),
                          title: Text(
                            'Compartilhar Projeto',
                            style: GoogleFonts.poppins(color: _textPrimaryColor),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Função de compartilhamento em breve!"),
                                  backgroundColor: _cardColor,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                )
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.report_problem, color: Colors.amber),
                          title: Text(
                            'Reportar Problema',
                            style: GoogleFonts.poppins(color: _textPrimaryColor),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Função de reportar em breve!"),
                                  backgroundColor: _cardColor,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                )
                            );
                          },
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
      body: RefreshIndicator(
        onRefresh: _carregarDadosProjeto,
        color: _accentColor,
        backgroundColor: _cardColor,
        displacement: 40,
        strokeWidth: 3,
        child: _isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
              ),
              SizedBox(height: 16),
              Text(
                "Carregando dados...",
                style: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        )
            : FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem de capa com gradiente
                Stack(
                  children: [
                    Container(
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _projetoAtual.imagemUrl.isNotEmpty
                          ? Hero(
                        tag: 'project-image-${_projetoAtual.id}',
                        child: CachedNetworkImage(
                          imageUrl: _projetoAtual.imagemUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: Colors.grey, size: 40),
                                SizedBox(height: 8),
                                Text(
                                  "Erro ao carregar imagem",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          : Center(
                        child: Text(
                          "Project Cover Image",
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    // Gradiente de sobreposição para melhorar legibilidade do texto
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              _primaryColor.withOpacity(0.8),
                              _primaryColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Conteúdo principal
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título do projeto
                      Text(
                        _projetoAtual.titulo,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Informações do criador
                      InkWell(
                        onTap: () => _navegarParaPerfil(_projetoAtual.usuarioCriador),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
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
                                  backgroundImage: NetworkImage(
                                      _projetoAtual.usuarioCriador.imagemUrl.isNotEmpty
                                          ? _projetoAtual.usuarioCriador.imagemUrl
                                          : "https://via.placeholder.com/40"
                                  ),
                                  radius: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _projetoAtual.usuarioCriador.nome,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "Project Creator",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey[400],
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Tags (status e tipo)
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getChipColors(_projetoAtual.status, true)["bg"],
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _projetoAtual.status == "Concluído"
                                      ? Icons.check_circle
                                      : Icons.pending,
                                  color: _getChipColors(_projetoAtual.status, true)["text"],
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  _projetoAtual.status,
                                  style: GoogleFonts.poppins(
                                    color: _getChipColors(_projetoAtual.status, true)["text"],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getChipColors(_projetoAtual.tipo, false)["bg"],
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
                              _projetoAtual.tipo,
                              style: GoogleFonts.poppins(
                                color: _getChipColors(_projetoAtual.tipo, false)["text"],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.grey[400],
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _projetoAtual.localizacao,
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Descrição do projeto
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _cardColor,
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
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _accentColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.description,
                                    color: _accentColor,
                                    size: 16,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Sobre o Projeto",
                                  style: GoogleFonts.poppins(
                                    color: _textPrimaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Divider(color: _dividerColor),
                            SizedBox(height: 12),
                            Text(
                              _projetoAtual.descricao,
                              style: GoogleFonts.poppins(
                                color: Colors.grey[300],
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Seção Equipe Atual
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _cardColor,
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
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.people,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Current Team",
                                  style: GoogleFonts.poppins(
                                    color: _textPrimaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${_projetoAtual.pessoasEnvolvidas.length} membros",
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // MODIFIED: Reduced height from 12 to 6
                            SizedBox(height: 0), // This reduces the space after the "Current Team" row
                            Divider(color: _dividerColor),
                            // MODIFIED: Reduced height from 12 to 6
                            SizedBox(height: 0), // This reduces the space after the Divider

                            // Lista de membros da equipe
                            if (_projetoAtual.pessoasEnvolvidas.isEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      color: Colors.grey[500],
                                      size: 40,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      "Nenhum membro na equipe ainda",
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _projetoAtual.pessoasEnvolvidas.length,
                                itemBuilder: (context, index) {
                                  final member = _projetoAtual.pessoasEnvolvidas[index];
                                  return InkWell(
                                    onTap: () => _navegarParaPerfil(member),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      margin: EdgeInsets.only(bottom: index < _projetoAtual.pessoasEnvolvidas.length - 1 ? 10 : 0),
                                      decoration: BoxDecoration(
                                        color: _primaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                member.imagemUrl.isNotEmpty
                                                    ? member.imagemUrl
                                                    : "https://via.placeholder.com/40"
                                            ),
                                            radius: 20,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  member.nome,
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                if (member.funcao != null && member.funcao!.isNotEmpty)
                                                  Text(
                                                    member.funcao!,
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.grey[400],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          // Botão de remover membro (apenas para o criador e não para si mesmo)
                                          if (isCriador && member.id != _projetoAtual.usuarioCriador.id)
                                            Container(
                                              decoration: BoxDecoration(
                                                color: _dangerColor.withOpacity(0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: Icon(Icons.person_remove, color: _dangerColor, size: 20),
                                                tooltip: "Remover membro",
                                                onPressed: () => _removerMembro(member),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Seção Solicitações para Entrar (apenas para o criador)
                      if (isCriador && _projetoAtual.usuariosSolicitantes.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _cardColor,
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
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _accentColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.person_add,
                                      color: _accentColor,
                                      size: 16,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Requesting to Join",
                                    style: GoogleFonts.poppins(
                                      color: _textPrimaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _accentColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "${_projetoAtual.usuariosSolicitantes.length} solicitações",
                                      style: GoogleFonts.poppins(
                                        color: _accentColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Divider(color: _dividerColor),
                              SizedBox(height: 12),

                              // Lista de solicitantes
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _projetoAtual.usuariosSolicitantes.length,
                                itemBuilder: (context, index) {
                                  final solicitante = _projetoAtual.usuariosSolicitantes[index];
                                  return Container(
                                    padding: EdgeInsets.all(12),
                                    margin: EdgeInsets.only(bottom: index < _projetoAtual.usuariosSolicitantes.length - 1 ? 10 : 0),
                                    decoration: BoxDecoration(
                                      color: _primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () => _navegarParaPerfil(solicitante),
                                              child: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    solicitante.imagemUrl.isNotEmpty
                                                        ? solicitante.imagemUrl
                                                        : "https://via.placeholder.com/40"
                                                ),
                                                radius: 20,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  InkWell(
                                                    onTap: () => _navegarParaPerfil(solicitante),
                                                    child: Text(
                                                      solicitante.nome,
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  if (solicitante.funcao != null && solicitante.funcao!.isNotEmpty)
                                                    Text(
                                                      solicitante.funcao!,
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.grey[400],
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => _aceitarSolicitacao(solicitante),
                                                icon: Icon(Icons.check, size: 18),
                                                label: Text(
                                                  "Accept",
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: _successColor,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  padding: EdgeInsets.symmetric(vertical: 12),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => _rejeitarSolicitacao(solicitante),
                                                icon: Icon(Icons.close, size: 18),
                                                label: Text(
                                                  "Reject",
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(0xFF424B59),
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  padding: EdgeInsets.symmetric(vertical: 12),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                      ],

                      // Botões de ação
                      if (!isCriador && !estaEnvolvido) ...[
                        Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: estaSolicitando ? null : _solicitarParticipacao,
                            icon: Icon(
                              estaSolicitando ? Icons.hourglass_top : Icons.person_add,
                              size: 20,
                            ),
                            label: Text(
                              estaSolicitando ? "Solicitação Enviada" : "Request to Join",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: estaSolicitando ? Colors.grey : _accentColor,
                              foregroundColor: estaSolicitando ? Colors.white : Colors.black,
                              disabledBackgroundColor: Colors.grey[700],
                              disabledForegroundColor: Colors.white70,
                              elevation: estaSolicitando ? 0 : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],

                      if (isCriador) ...[
                        Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _excluirProjeto,
                            icon: Icon(Icons.delete, size: 20),
                            label: Text(
                              "Delete Project",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _dangerColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],

                      // Espaço no final
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}