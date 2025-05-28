// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import "package:flutter/material.dart";

import "AppColors.dart";

// Modelo de dados simulado (substituir com seus modelos reais)
class Usuario {
  final String id;
  final String nome;
  final String imagemUrl;
  final String? funcao; // Ex: Diretor, Produtor, Cinematographer

  Usuario({required this.id, required this.nome, required this.imagemUrl, this.funcao});
}

class Projeto {
  final String id;
  final String titulo;
  final String descricao;
  final String localizacao;
  final String imagemUrl;
  final String tipo; // Ex: Drama, Curta
  final String status; // Ex: Pre-production, Em andamento, Concluído
  final Usuario usuarioCriador;
  List<Usuario> usuariosSolicitantes; // Tornar mutável para simular aceitar/rejeitar
  List<Usuario> pessoasEnvolvidas; // Tornar mutável para simular aceitar

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
}

class ProjectDetailsScreen extends StatefulWidget {
  final Projeto projeto;
  final Usuario usuarioAtual; // Usuário logado no app

  const ProjectDetailsScreen({Key? key, required this.projeto, required this.usuarioAtual}) : super(key: key);

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late bool isCriador;
  late bool estaSolicitando;
  late bool estaEnvolvido;

// Dentro da classe _ProjectDetailsScreenState

  @override
  void initState() {
    super.initState();
    // Adicione um pequeno atraso se _updateUserRoles depender de algo que ainda não está pronto,
    // mas geralmente chamar diretamente é ok.
    // WidgetsBinding.instance.addPostFrameCallback((_) { // Opcional, para garantir que o widget está montado
    //   _updateUserRoles();
    // });
    _updateUserRoles(); // Chamar diretamente no initState é comum
  }

  void _updateUserRoles() {
    // Adicione prints para depuração
    print("--------------------------------------------------");
    print("ProjectDetailsScreen: _updateUserRoles CALLED");
    print("ID do Criador do Projeto (String): '${widget.projeto.usuarioCriador.id}' (Tipo: ${widget.projeto.usuarioCriador.id.runtimeType})");
    print("Nome do Criador do Projeto: ${widget.projeto.usuarioCriador.nome}");
    print("ID do Usuário Atual (widget.usuarioAtual.id): '${widget.usuarioAtual.id}' (Tipo: ${widget.usuarioAtual.id.runtimeType})");
    print("Nome do Usuário Atual: ${widget.usuarioAtual.nome}");

    bool comparacaoDiretaIDs = widget.projeto.usuarioCriador.id == widget.usuarioAtual.id;
    print("Resultado da comparação (widget.projeto.usuarioCriador.id == widget.usuarioAtual.id): $comparacaoDiretaIDs");
    print("--------------------------------------------------");

    // Forçar um rebuild se o estado realmente mudar.
    // A verificação if (mounted) é uma boa prática em métodos que podem ser chamados após dispose.
    if (mounted) {
      setState(() {
        isCriador = comparacaoDiretaIDs;
        estaSolicitando = widget.projeto.usuariosSolicitantes.any((user) => user.id == widget.usuarioAtual.id);
        estaEnvolvido = widget.projeto.pessoasEnvolvidas.any((user) => user.id == widget.usuarioAtual.id);
      });
    }
  }

  Map<String, Color> _getChipColors(String text, bool isStatus) {
    Color bgColor;
    Color textColor;

    if (isStatus) {
      switch (text) {
        case "Em andamento":
        case "Pre-production":
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
        case "Drama":
          bgColor = Colors.grey[700]!;
          textColor = Colors.white;
          break;
        default:
          bgColor = Colors.grey[800]!;
          textColor = Colors.white70;
      }
    }
    return {"bg": bgColor, "text": textColor};
  }

  void _aceitarSolicitacao(Usuario solicitante) {
    setState(() {
      widget.projeto.pessoasEnvolvidas.add(solicitante);
      widget.projeto.usuariosSolicitantes.removeWhere((user) => user.id == solicitante.id);
      _updateUserRoles();
    });
    // TODO: Adicionar chamada de API para persistir a mudança
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${solicitante.nome} foi adicionado ao projeto.")));
  }

  void _rejeitarSolicitacao(Usuario solicitante) {
    setState(() {
      widget.projeto.usuariosSolicitantes.removeWhere((user) => user.id == solicitante.id);
      _updateUserRoles();
    });
    // TODO: Adicionar chamada de API para persistir a mudança
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Solicitação de ${solicitante.nome} rejeitada.")));
  }

  void _solicitarParticipacao() {
    setState(() {
      // Adiciona o usuário atual à lista de solicitantes (simulação)
      // Numa aplicação real, isso seria uma chamada de API
      if (!widget.projeto.usuariosSolicitantes.any((u) => u.id == widget.usuarioAtual.id)) {
        widget.projeto.usuariosSolicitantes.add(widget.usuarioAtual);
      }
      _updateUserRoles();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Solicitação para participar enviada.")));
    // TODO: Adicionar chamada de API para persistir a mudança
  }

  void _excluirProjeto() {
    // TODO: Adicionar lógica de confirmação e chamada de API para excluir o projeto
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Projeto excluído (simulação).")));
    Navigator.of(context).pop(); // Volta para a tela anterior após "excluir"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Ação para o menu de três pontos
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20), // Espaço no final para os botões não ficarem colados
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[700],
              child: widget.projeto.imagemUrl.isNotEmpty
                  ? Image.network(widget.projeto.imagemUrl, fit: BoxFit.cover)
                  : Center(
                child: Text(
                  "Project Cover Image",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.projeto.titulo,
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.projeto.usuarioCriador.imagemUrl.isNotEmpty ? widget.projeto.usuarioCriador.imagemUrl : "https://via.placeholder.com/40"),
                        radius: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        widget.projeto.usuarioCriador.nome,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Project Creator",
                        style: TextStyle(color: Colors.grey[500], fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      Chip(
                        label: Text(widget.projeto.status, style: TextStyle(color: _getChipColors(widget.projeto.status, true)["text"])) ,
                        backgroundColor: _getChipColors(widget.projeto.status, true)["bg"],
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      Chip(
                        label: Text(widget.projeto.tipo, style: TextStyle(color: _getChipColors(widget.projeto.tipo, false)["text"])) ,
                        backgroundColor: _getChipColors(widget.projeto.tipo, false)["bg"],
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.projeto.descricao,
                    style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
                  ),
                  SizedBox(height: 24),

                  // Equipe Atual
                  if (widget.projeto.pessoasEnvolvidas.isNotEmpty)
                    _buildSectionTitle("Current Team"),
                  if (widget.projeto.pessoasEnvolvidas.isNotEmpty)
                    _buildTeamList(widget.projeto.pessoasEnvolvidas),

                  SizedBox(height: 24),

                  // Solicitando para Entrar (apenas para o criador)
                  if (isCriador && widget.projeto.usuariosSolicitantes.isNotEmpty)
                    _buildSectionTitle("Requesting to Join"),
                  if (isCriador)
                    _buildRequestingList(widget.projeto.usuariosSolicitantes),

                  SizedBox(height: 24),

                  // Botões de Ação
                  if (!isCriador && !estaSolicitando && !estaEnvolvido)
                    _buildFullWidthButton("Request to Join", _solicitarParticipacao),

                  if (isCriador)
                    _buildFullWidthButton("Excluir Projeto", _excluirProjeto, isDestructive: true),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTeamList(List<Usuario> team) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: team.length,
      itemBuilder: (context, index) {
        final member = team[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.inputFieldBackgroundAlt,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(member.imagemUrl.isNotEmpty ? member.imagemUrl : "https://via.placeholder.com/40"),
                radius: 20,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.nome, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  if (member.funcao != null && member.funcao!.isNotEmpty)
                    Text(member.funcao!, style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestingList(List<Usuario> solicitantes) {
    if (solicitantes.isEmpty && isCriador) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text("Nenhuma solicitação pendente.", style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: solicitantes.length,
      itemBuilder: (context, index) {
        final solicitante = solicitantes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(solicitante.imagemUrl.isNotEmpty ? solicitante.imagemUrl : "https://via.placeholder.com/40"),
                radius: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(solicitante.nome, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                    if (solicitante.funcao != null && solicitante.funcao!.isNotEmpty) // Supondo que o solicitante possa ter uma função/skill
                      Text(solicitante.funcao!, style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _aceitarSolicitacao(solicitante),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(horizontal: 16)),
                child: Text("Accept", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _rejeitarSolicitacao(solicitante),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700], padding: EdgeInsets.symmetric(horizontal: 16)),
                child: Text("Reject", style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullWidthButton(String text, VoidCallback onPressed, {bool isDestructive = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Colors.red[700] : Colors.grey[700],
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// Exemplo de como usar (para teste, remover em produção):
void main() {
  // Usuários de exemplo
  final userAlex = Usuario(id: "creator456", nome: "Alex Johnson", imagemUrl: "https://randomuser.me/api/portraits/men/1.jpg", funcao: "Project Creator");
  final userSarah = Usuario(id: "user001", nome: "Sarah Chen", imagemUrl: "https://randomuser.me/api/portraits/women/2.jpg", funcao: "Director");
  final userMike = Usuario(id: "user002", nome: "Mike Roberts", imagemUrl: "https://randomuser.me/api/portraits/men/3.jpg", funcao: "Producer");
  final userDavid = Usuario(id: "user003", nome: "David Kim", imagemUrl: "https://randomuser.me/api/portraits/men/4.jpg", funcao: "Cinematographer");
  final userEmma = Usuario(id: "user004", nome: "Emma Wilson", imagemUrl: "https://randomuser.me/api/portraits/women/5.jpg", funcao: "Sound Designer");
  final userLoggedOutsider = Usuario(id: "user123", nome: "Usuário Logado Teste", imagemUrl: "https://randomuser.me/api/portraits/lego/1.jpg");
  final userLoggedSolicitante = Usuario(id: "user789", nome: "Usuário Solicitante Teste", imagemUrl: "https://randomuser.me/api/portraits/lego/2.jpg", funcao: "Roteirista");

  // Projeto de exemplo
  final sampleProject = Projeto(
    id: "proj1",
    titulo: "The Last Light",
    descricao: "Short film about the last lighthouse keeper in a digital world. A story of solitude, tradition, and the inevitable march of progress.",
    localizacao: "A Lighthouse by the Sea",
    imagemUrl: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8bGlnaHRob3VzZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=800&q=60", // Imagem real
    tipo: "Drama",
    status: "Pre-production",
    usuarioCriador: userAlex,
    pessoasEnvolvidas: [userSarah, userMike],
    usuariosSolicitantes: [userDavid, userEmma, userLoggedSolicitante], // Adicionando userLoggedSolicitante para teste
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Color(0xFF222831),
    ),
    // Teste 1: Usuário logado é o CRIADOR
    // home: ProjectDetailsScreen(projeto: sampleProject, usuarioAtual: userAlex),

    // Teste 2: Usuário logado é um PARTICIPANTE (NÃO CRIADOR)
    // home: ProjectDetailsScreen(projeto: sampleProject, usuarioAtual: userSarah),

    // Teste 3: Usuário logado é um SOLICITANTE (NÃO CRIADOR, NÃO PARTICIPANTE)
    // home: ProjectDetailsScreen(projeto: sampleProject, usuarioAtual: userLoggedSolicitante),

    // Teste 4: Usuário logado é um ESTRANHO (NÃO CRIADOR, NÃO PARTICIPANTE, NÃO SOLICITANTE)
    home: ProjectDetailsScreen(projeto: sampleProject, usuarioAtual: userLoggedOutsider),
  ));
}

