import 'package:flutter/material.dart';

class TelaEdicaoPerfil extends StatefulWidget {
  @override
  _TelaEdicaoPerfilState createState() => _TelaEdicaoPerfilState();
}

class _TelaEdicaoPerfilState extends State<TelaEdicaoPerfil> {
  List<String> listaLocalizacao = ["São Paulo", "Rio de Janeiro", "Belo Horizonte"];
  List<String> listaHabilidades = ["Desenvolvedor", "Designer", "Fotógrafo"];
  List<String> listaProfissao = ["Músico", "Ator", "Dançarino"];

  String? localizacaoSelecionada;
  String? habilidadeSelecionada;
  String? profissaoSelecionada;
  bool isDark = true; // Definindo o tema escuro como padrão

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1D1D1D) : Colors.white, // Cor de fundo com base no tema
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF1D1D1D) : Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            SizedBox(height: 20),
            Image.asset('assets/logo.png', height: 45,),
            SizedBox(height: 10),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Editar Usuário",
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _criarFotoPerfil(),
              SizedBox(height: 20),
              _criarCampoTexto("Nome", "Insira seu nome", isDark: isDark),
              SizedBox(height: 15),
              _criarCampoTexto("Sobre Mim", "Fale um pouco sobre você", maxLinhas: 4, isDark: isDark),
              SizedBox(height: 15),
              _criarListaSuspensa(
                "Profissão",
                listaProfissao,
                profissaoSelecionada,
                    (String? novoValor) {
                  setState(() {
                    profissaoSelecionada = novoValor;
                  });
                },
              ),
              SizedBox(height: 15),
              _criarListaSuspensa(
                "Localização",
                listaLocalizacao,
                localizacaoSelecionada,
                    (String? novoValor) {
                  setState(() {
                    localizacaoSelecionada = novoValor;
                  });
                },
              ),
              SizedBox(height: 15),
              _criarListaSuspensa(
                "Habilidades",
                listaHabilidades,
                habilidadeSelecionada,
                    (String? novoValor) {
                  setState(() {habilidadeSelecionada = novoValor;
                  });
                },
              ),
              SizedBox(height: 20),
              _criarBotaoSalvar(),
              SizedBox(height: 20),
              _criarSwitchTema(), // Adicionando o switch para alternar entre os temas
            ],
          ),
        ),
      ),
    );
  }

  Widget _criarFotoPerfil() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/100172960?v=4"),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Colors.yellow,
              radius: 18,
              child: Icon(Icons.mode_edit, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _criarCampoTexto(String label, String hint, {int maxLinhas = 1, bool isDark = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          maxLines: maxLinhas,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.black),
            filled: true,
            fillColor: isDark ? Colors.grey[200] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _criarListaSuspensa(
      String label, List<String> lista, String? valorSelecionado, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[200] : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: valorSelecionado,
            isExpanded: true,
            dropdownColor: isDark ? Colors.white : Colors.grey[300],
            underline: SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: Colors.black),
            style: TextStyle(color: Colors.black),
            items: lista.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _criarBotaoSalvar() {
    return Center(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text("Salvar", style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Função para criar o switch para alternar entre os temas - Não consegui fazer diretamente pela pagina de configuração
  Widget _criarSwitchTema() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Tema Escuro",
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
        ),
        Switch(
          value: isDark,
          onChanged: (bool novoValor) {
            setState(() {
              isDark = novoValor;
            });
          },
          activeColor: Colors.yellow,
        ),
      ],
    );
  }
}
