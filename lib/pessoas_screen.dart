import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:indiestream_app/AppColors.dart';
import 'package:indiestream_app/user_detalhes_screen.dart';

class PessoasScreen extends StatefulWidget {
  const PessoasScreen({super.key});

  @override
  State<PessoasScreen> createState() => _PessoasScreenState();
}

class _PessoasScreenState extends State<PessoasScreen> {
  List<dynamic> _usuarios = [];
  String _filtro = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _buscarUsuarios();
  }

  Future<void> _buscarUsuarios() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse("http://localhost:8080/user"));

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
          setState(() {
            _usuarios = decodedData;
          });
        } else {
          print("Erro: Resposta da API não é uma lista.");
          setState(() {
            _usuarios = [];
          });
        }
      } else {
        print("Falha ao carregar usuários: Status ${response.statusCode}");
        setState(() {
          _usuarios = [];
        });
      }
    } catch (e) {
      print("Erro ao buscar usuários: $e");
      setState(() {
        _usuarios = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildHabilidadeTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: AppColors.tagBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: AppColors.tagText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> usuariosFiltrados = _usuarios.where((usuario) {
      final nome = usuario["nome"]?.toString().toLowerCase() ?? "";
      return nome.contains(_filtro.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Pesquisar membros...",
                hintStyle: GoogleFonts.interTight(color: AppColors.secondaryText),
                filled: true,
                fillColor: AppColors.inputFieldBackground,
                prefixIcon: const Icon(Icons.search, color: AppColors.placeholderIcon),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              style: GoogleFonts.inter(color: AppColors.primaryText),
              onChanged: (valor) {
                setState(() {
                  _filtro = valor;
                });
              },
            ),
            const SizedBox(height: 16),
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "${usuariosFiltrados.length} Membro${usuariosFiltrados.length != 1 ? 's' : ''} encontrado${usuariosFiltrados.length != 1 ? 's' : ''}",
                  style: GoogleFonts.inter(color: AppColors.secondaryText, fontSize: 14),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(
                  child: CircularProgressIndicator(color: AppColors.premiumGold))
                  : usuariosFiltrados.isEmpty
                  ? Center(
                  child: Text(
                      _filtro.isEmpty
                          ? "Nenhum membro encontrado."
                          : "Nenhum membro encontrado para '$_filtro'.",
                      style: GoogleFonts.inter(
                          color: AppColors.secondaryText, fontSize: 16)))
                  : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: usuariosFiltrados.length,
                itemBuilder: (context, index) {
                  final usuario = usuariosFiltrados[index];
                  final String nome = usuario['nome'] ?? 'Nome Indisponível';
                  final String? imageUrl = usuario['imagemUrl'];
                  final String profissaoNome =
                      usuario['profissaoNome'] ?? "Profissão não informada";
                  final String cidadeNome =
                      usuario['cidadeNome'] ?? "Cidade não informada";
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

                  return GestureDetector(
                    onTap: () {
                      final userId = usuario["id"]?.toString();
                      if (userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetalhesScreen(
                              userId: userId,
                            ),
                          ),
                        );
                      } else {
                        print("Erro: ID do usuário é nulo.");
                      }
                    },
                    child: Card(
                      color: AppColors.cardBackground,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isPremium
                            ? const BorderSide(
                            color: AppColors.premiumGold, width: 1.5)
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: AppColors.errorBackground,
                              child: imageUrl == null || imageUrl.isEmpty
                                  ? const Icon(Icons.person,
                                  size: 35, color: AppColors.placeholderIcon)
                                  : ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(
                                        color: AppColors.errorBackground,
                                        child: const Icon(Icons.person,
                                            size: 35,
                                            color: AppColors.placeholderIcon),
                                      ),
                                  errorWidget: (context, url, error) {
                                    print(
                                        "Erro ao carregar imagem: $url\nErro: $error");
                                    return Container(
                                      color: AppColors.errorBackground,
                                      child: const Icon(Icons.broken_image,
                                          size: 35,
                                          color: AppColors.placeholderIcon),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          nome,
                                          style: GoogleFonts.inter(
                                            color: AppColors.primaryText,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isPremium)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 6.0),
                                          child: Icon(
                                            Icons.star,
                                            color: AppColors.premiumGold,
                                            size: 18,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profissaoNome,
                                    style: GoogleFonts.inter(
                                      color: isPremium
                                          ? AppColors.premiumGold
                                          : AppColors.secondaryText,
                                      fontSize: 14,
                                      fontWeight:
                                      isPremium ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (localizacao != "Localização não informada")
                                    Text(
                                      localizacao,
                                      style: GoogleFonts.inter(
                                        color: AppColors.secondaryText,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (localizacao != "Localização não informada")
                                    const SizedBox(height: 10),
                                  if (sobreMim.isNotEmpty)
                                    Text(
                                      sobreMim,
                                      style: GoogleFonts.inter(
                                          color: AppColors.primaryText
                                              .withOpacity(0.9),
                                          fontSize: 14,
                                          height: 1.4),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (sobreMim.isNotEmpty)
                                    const SizedBox(height: 12),
                                  if (habilidades.isNotEmpty)
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 6.0,
                                      children: habilidades
                                          .map((habilidade) =>
                                          _buildHabilidadeTag(habilidade))
                                          .toList(),
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
          ],
        ),
      ),
    );
  }
}