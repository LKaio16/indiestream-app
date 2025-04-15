import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:indiestream_app/user_detalhes_screen.dart';

class PessoasScreen extends StatefulWidget {
  const PessoasScreen({super.key});

  @override
  State<PessoasScreen> createState() => _PessoasScreenState();
}

class _PessoasScreenState extends State<PessoasScreen> {
  List<dynamic> _usuarios = [];
  int _paginaAtual = 1;
  int _itensPorPagina = 12;
  String _filtro = "";

  @override
  void initState() {
    super.initState();
    _buscarUsuarios();
  }

  Future<void> _buscarUsuarios() async {
    try {
      final response = await http.get(Uri.parse("http://localhost:8080/user"));
      if (response.statusCode == 200) {
        setState(() {
          _usuarios = json.decode(utf8.decode(response.bodyBytes));
        });
      } else {
        throw Exception("Falha ao carregar usuários");
      }
    } catch (e) {
      print("Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> usuariosFiltrados = _usuarios.where((usuario) {
      return usuario["nome"].toLowerCase().contains(_filtro.toLowerCase());
    }).toList();

    int totalPaginas = (usuariosFiltrados.length / _itensPorPagina).ceil();
    int indiceInicial = (_paginaAtual - 1) * _itensPorPagina;
    int indiceFinal = indiceInicial + _itensPorPagina;
    List<dynamic> usuariosPagina = usuariosFiltrados.sublist(
        indiceInicial, indiceFinal > usuariosFiltrados.length ? usuariosFiltrados.length : indiceFinal);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Pesquisar usuários...",
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
            Text(
              "${usuariosFiltrados.length} Usuários encontrados na Busca",
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: usuariosPagina.length,
                itemBuilder: (context, index) {
                  final usuario = usuariosPagina[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetalhesScreen(
                            userId: usuario["id"].toString(),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                imageUrl: usuario["imagemUrl"],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[800],
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white54,
                                    size: 50,
                                  ),
                                ),
                                errorWidget: (context, url, error) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[800],
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white54,
                                      size: 50,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    usuario["nome"],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    usuario["profissaoNome"] ?? "Profissão não informada",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "${usuario["cidadeNome"] ?? "Cidade não informada"}${usuario["estadoNome"] != null ? ", ${usuario["estadoNome"]}" : ""}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
    );
  }
}