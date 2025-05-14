import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaginaSobre extends StatefulWidget {
  @override
  _PaginaSobreState createState() => _PaginaSobreState();
}

class _PaginaSobreState extends State<PaginaSobre> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // Carrega a preferência de tema (escuro ou claro) do SharedPreferences
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('config_darkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = isDarkMode ? ThemeData.dark() : ThemeData.light(); // Muda o tema conforme a preferência
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = theme.scaffoldBackgroundColor;

    return MaterialApp(
      theme: theme, // Aplica o tema conforme a preferência
      home: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 40),
            ],
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    "Aqui você pode",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.yellow,
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _criarOpcao(Icons.people, "Conectar-se com profissionais da área", isDarkMode),
                    _criarOpcao(Icons.lightbulb, "Expressar sua criatividade", isDarkMode),
                    _criarOpcao(Icons.video_library, "Catalogar Produções Independentes", isDarkMode),
                    _criarOpcao(Icons.library_books, "Catalogar Produções Independentes", isDarkMode),
                  ],
                ),
              ),
              Container(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    "Criadores do Aplicativo",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Mário", "Engenheiro de Requisitos", isDarkMode),
                    _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Manoel", "Tester", isDarkMode),
                    _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Felipe", "Front-end", isDarkMode),
                    _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Kaio", "Back-end", isDarkMode),
                    _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Mateus", "DBA", isDarkMode),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "© 2024 IndieStream. All rights reserved.",
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _criarOpcao(IconData icone, String texto, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icone, color: isDark ? Colors.white : Colors.black),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _criarAvatar(String url, String nome, String funcao, bool isDark) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(url),
          radius: 30,
        ),
        SizedBox(height: 5),
        Text(
          nome,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          funcao,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
