import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'auth_service.dart';

class ProjetoDetalhesScreen extends StatefulWidget {
  final String projetoId;

  const ProjetoDetalhesScreen({super.key, required this.projetoId});

  @override
  State<ProjetoDetalhesScreen> createState() => _ProjetoDetalhesScreenState();
}

class _ProjetoDetalhesScreenState extends State<ProjetoDetalhesScreen> {
  Map<String, dynamic>? _projeto;
  bool _isLoading = true;
  bool _solicitado = false;
  bool _isEnvolvido = false;
  bool _isCriador = false;
  int? _usuarioLogadoId;

  @override
  void initState() {
    super.initState();
    _carregarProjeto();
    _carregarUsuarioLogado();
  }

  Future<void> _carregarUsuarioLogado() async {
    final userId = await AuthService.getUserId();
    setState(() {
      _usuarioLogadoId = userId;
    });
  }

  Future<void> _carregarProjeto() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8080/projetos/${widget.projetoId}"),
      );

      if (response.statusCode == 200) {
        final projeto = json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          _projeto = projeto;
          _isCriador = projeto['usuarioCriador']?['id'] == _usuarioLogadoId;

          // Verifica se o usuário é um solicitante
          final solicitantes = projeto['usuariosSolicitantes'] as List? ?? [];
          _solicitado = solicitantes.any((s) => s['id'] == _usuarioLogadoId);

          // Verifica se o usuário está envolvido
          final envolvidos = projeto['pessoasEnvolvidas'] as List? ?? [];
          _isEnvolvido = envolvidos.any((p) => p['id'] == _usuarioLogadoId);

          _isLoading = false;
        });
      } else {
        throw Exception("Falha ao carregar projeto");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: ${e.toString()}")),
      );
    }
  }

  Future<void> _deletarProjeto() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar"),
        content: const Text("Tem certeza que deseja deletar este projeto?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Deletar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    try {
      final response = await http.delete(
        Uri.parse("http://localhost:8080/projetos/${widget.projetoId}"),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Projeto deletado com sucesso")),
        );
        Navigator.pop(context, true); // Retorna indicando que foi deletado
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao deletar projeto: ${e.toString()}")),
      );
    }
  }

  Future<void> _solicitarParticipacao() async {
    if (_usuarioLogadoId == null) return;

    try {
      final response = await http.put(
        Uri.parse(
          "http://localhost:8080/projetos/${widget.projetoId}/add-solicitante/$_usuarioLogadoId",
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _solicitado = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Solicitação enviada com sucesso")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao enviar solicitação: ${e.toString()}")),
      );
    }
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

    if (_projeto == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Projeto não encontrado"),
          backgroundColor: Colors.grey[900],
        ),
        body: const Center(
          child: Text(
            "Projeto não encontrado",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Detalhes do Projeto",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme:
        const IconThemeData(color: Colors.white), // Define a cor da seta
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _projeto!["titulo"],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_projeto!["imagemUrl"] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: _projeto!["imagemUrl"],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.image,
                      color: Colors.white54,
                      size: 50,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 50,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              _projeto!["descricao"] ?? "Sem descrição",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _projeto!["status"] == "Concluído"
                        ? Colors.green[800]
                        : Colors.amber[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _projeto!["status"] ?? "Status desconhecido",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Criado por:",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            if (_projeto!["usuarioCriador"] != null)
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: _projeto!["usuarioCriador"]["imagemUrl"] !=
                        null
                        ? NetworkImage(_projeto!["usuarioCriador"]["imagemUrl"])
                        : null,
                    child: _projeto!["usuarioCriador"]["imagemUrl"] == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _projeto!["usuarioCriador"]["nome"] ?? "Desconhecido",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            if (!_isCriador && !_isEnvolvido)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _solicitado ? null : _solicitarParticipacao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _solicitado ? "SOLICITAÇÃO ENVIADA" : "ENTRAR EM CONTATO",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (_isCriador)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _deletarProjeto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "DELETAR PROJETO",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
