import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:indiestream_app/projeto_detalhes_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjetosScreen extends StatefulWidget {
  const ProjetosScreen({super.key});

  @override
  State<ProjetosScreen> createState() => _ProjetosScreenState();
}

class _ProjetosScreenState extends State<ProjetosScreen> {
  List<dynamic> _projetos = [];
  int _paginaAtual = 1;
  int _itensPorPagina = 10;
  String _filtro = "";

  @override
  void initState() {
    super.initState();
    _buscarProjetos();
  }

  Future<void> _buscarProjetos() async {
    try {
      final response = await http.get(Uri.parse("http://localhost:8080/projetos"));
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

  Widget _buildTag(String text, {required bool isStatus}) {
    Color bgColor;
    Color textColor;

    if (isStatus) {
      switch (text) {
        case "Em andamento":
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
      switch (text) {
        case "Curta":
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
    List<dynamic> projetosFiltrados = _projetos.where((projeto) {
      final titulo = projeto["titulo"]?.toString().toLowerCase() ?? "";
      return titulo.contains(_filtro.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Pesquisar projetos...",
                hintStyle: GoogleFonts.inter(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
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
                  ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                  : projetosFiltrados.isEmpty && _filtro.isNotEmpty
                  ? Center(child: Text("Nenhum projeto encontrado.", style: GoogleFonts.inter(color: Colors.white70)))
                  : ListView.builder(
                itemCount: projetosFiltrados.length,
                itemBuilder: (context, index) {
                  final projeto = projetosFiltrados[index];
                  final usuarioCriador = projeto["usuarioCriador"];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjetoDetalhesScreen(
                            projetoId: projeto["id"]?.toString() ?? '',
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: const Color(0xFF1F2937),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: CachedNetworkImage(
                                imageUrl: projeto["imagemUrl"] ?? '',
                                height: 180,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 180,
                                  color: Colors.grey[800],
                                  child: Center(
                                    child: Text(
                                      "Project Cover Image",
                                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) {
                                  print("Erro ao carregar imagem: $url\nErro: $error");
                                  return Container(
                                    height: 180,
                                    color: Colors.grey[800],
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.broken_image,
                                            color: Colors.white54,
                                            size: 50,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Image not available",
                                            style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.grey,
                                      child: Icon(Icons.person, size: 24, color: Colors.white),
                                    ),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            projeto["titulo"] ?? "Título Indisponível",
                                            style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 16
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${usuarioCriador?["nome"] ?? "Diretor Indisponível"}",
                                            style: GoogleFonts.inter(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Text(
                                  projeto["descricao"] ?? "Descrição não disponível.",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 24),

                                Row(
                                  children: [
                                    _buildTag(projeto["status"] ?? "Status Desconhecido", isStatus: true),
                                    const SizedBox(width: 8),
                                    _buildTag(projeto["tipo"] ?? "Tipo Desconhecido", isStatus: false),
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