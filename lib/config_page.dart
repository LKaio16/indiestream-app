import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edicao-perfil_screen.dart' as edit;
import 'sobre_nos.dart' as sobre;
import './planos_page.dart';

class PaginaConfiguracao extends StatefulWidget {
  @override
  _PaginaConfiguracaoState createState() => _PaginaConfiguracaoState();
}

class _PaginaConfiguracaoState extends State<PaginaConfiguracao> {
  bool isDarkMode = false;
  int fontSize = 10;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('config_darkMode') ?? false;
      fontSize = prefs.getInt('config_fontSize') ?? 10;
    });
  }

  void _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('config_darkMode', isDarkMode);
    prefs.setInt('config_fontSize', fontSize);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? Color(0xFF1D1D1D) : Colors.grey[200];
    final cardColor = isDarkMode ? Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
        elevation: 0,
        title: Text("Configurações", style: TextStyle(color: textColor)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
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
                  _savePreferences();
                });
            }, cardColor, textColor),
            SizedBox(height: 20),
            _criarItemFonte("Tamanho da Fonte", cardColor, textColor),
            SizedBox(height: 20),
            GestureDetector(
              // onTap: () {
              //   Navigator.push(context,
              //       MaterialPageRoute(builder: (context) => edit.EditarPerfilScreen()));
              // },
              child: _criarBotao("Editar Perfil", cardColor, textColor),
            ),
            SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TelaPlanos()));
              },
              child: _criarBotao("Visualizar Planos", cardColor, textColor),
            ),
            SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => sobre.PaginaSobre()));
              },
              child: _criarBotao("Sobre nós", cardColor, textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _criarItemToggle(String titulo, bool valor, Function(bool) onChanged,
      Color cardColor, Color textColor) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: TextStyle(color: textColor, fontSize: 16)),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeColor: Colors.yellow,
          ),
        ],
      ),
    );
  }

  Widget _criarItemFonte(String titulo, Color cardColor, Color textColor) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: TextStyle(color: textColor, fontSize: 16)),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: textColor),
                onPressed: () {
                  setState(() {
                    if (fontSize < 20) fontSize++;
                    _savePreferences();
                  });
                },
              ),
              Text("$fontSize", style: TextStyle(color: textColor, fontSize: 16)),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: textColor),
                onPressed: () {
                  setState(() {
                    if (fontSize > 8) fontSize--;
                    _savePreferences();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _criarBotao(String texto, Color cardColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          texto,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
