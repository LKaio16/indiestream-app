import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:indiestream_app/projeto_create_screen.dart';

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
        throw Exception("Falha ao carregar projetos");
      }
    } catch (e) {
      print("Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> projetosFiltrados = _projetos.where((projeto) {
      return projeto["titulo"].toLowerCase().contains(_filtro.toLowerCase());
    }).toList();

    int totalPaginas = (projetosFiltrados.length / _itensPorPagina).ceil();
    int indiceInicial = (_paginaAtual - 1) * _itensPorPagina;
    int indiceFinal = indiceInicial + _itensPorPagina;
    List<dynamic> projetosPagina = projetosFiltrados.sublist(
        indiceInicial, indiceFinal > projetosFiltrados.length ? projetosFiltrados.length : indiceFinal);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Pesquisar projetos...",
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (valor) {
                setState(() {
                  _filtro = valor;
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: projetosPagina.length,
                itemBuilder: (context, index) {
                  final projeto = projetosPagina[index];

                  // print("Carregando imagem do projeto: ${projeto["titulo"]}");
                  // print("URL da imagem: ${projeto["imagemUrl"]}");

                  return GestureDetector(
                    onTap: () {
                      // Lógica para abrir detalhes do projeto
                    },
                    child: Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),

                              child: CachedNetworkImage(
                                  imageUrl: projeto["imagemUrl"],
                                  height: 150,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[800],
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.white54,
                                      size: 50,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) {
                                    // print("Erro ao carregar imagem: $url");
                                    // print("Erro: $error");
                                    return Container(
                                      color: Colors.grey[800],
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.white54,
                                        size: 50,
                                      ),
                                    );
                                  }
                              )
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              projeto["titulo"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _paginaAtual > 1
                      ? () {
                    setState(() {
                      _paginaAtual--;
                    });
                  }
                      : null,
                ),
                Text(
                  "Página $_paginaAtual de $totalPaginas",
                  style: const TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: _paginaAtual < totalPaginas
                      ? () {
                    setState(() {
                      _paginaAtual++;
                    });
                  }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CriarProjetoScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}