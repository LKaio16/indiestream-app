import 'package:flutter/material.dart';
import 'edicao-perfil_screen.dart' as edit;
import 'sobre_nos.dart' as sobre;

class PaginaConfiguracao extends StatefulWidget {
  @override
  _PaginaConfiguracaoState createState() => _PaginaConfiguracaoState();
}

class _PaginaConfiguracaoState extends State<PaginaConfiguracao> {
  bool isDarkMode = false;
  int fontSize = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1D1D),
      appBar: AppBar(
        backgroundColor: Color(0xFF2C2C2C),
        elevation: 0,
        title: Text("Configurações", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _criarItemToggle("Dark mode", isDarkMode, (value) {
              setState(() {
                isDarkMode = value;
              });
            }),
            SizedBox(height: 20),
            _criarItemFonte("Tamanho da Fonte"),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => edit.TelaEdicaoPerfil()),
                );
              },
              child: _criarBotao("Editar Perfil"),
            ),
            SizedBox(height: 15),
            _criarBotao("Visualizar Planos"),
            SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => sobre.PaginaSobre()), // Substitua com a tela correta
                );
              },
              child: _criarBotao("Sobre nós"),
            ),
          ],
        ),
      ),
    );
  }


  Widget _criarItemToggle(String titulo, bool valor, Function(bool) onChanged) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: TextStyle(color: Colors.white, fontSize: 16)),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeColor: Colors.yellow,
          ),
        ],
      ),
    );
  }

  Widget _criarItemFonte(String titulo) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: TextStyle(color: Colors.white, fontSize: 16)),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () {
                  setState(() {
                    if (fontSize < 20) fontSize++;
                  });
                },
              ),
              Text("$fontSize", style: TextStyle(color: Colors.white, fontSize: 16)),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.white),
                onPressed: () {
                  setState(() {
                    if (fontSize > 8) fontSize--;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _criarBotao(String texto) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          texto,
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
