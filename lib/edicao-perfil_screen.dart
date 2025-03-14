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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1D1D),
      appBar: AppBar(
        backgroundColor: Color(0xFF1D1D1D),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            SizedBox(height: 20),
            Image.asset('assets/logo.png', height: 45,), SizedBox(height: 10),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,),
              ),
              SizedBox(height: 20),
              _criarFotoPerfil(),
              SizedBox(height: 20),
              _criarCampoTexto("Nome", "Insira seu nome"),
              SizedBox(height: 15),
              _criarCampoTexto("Sobre Mim", "Fale um pouco sobre você", maxLinhas: 4),
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

  Widget _criarCampoTexto(String label, String hint, {int maxLinhas = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          maxLines: maxLinhas,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
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
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: valorSelecionado,
            isExpanded: true,
            dropdownColor: Colors.white,
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
}
