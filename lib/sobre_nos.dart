import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class PaginaSobre extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        final textColor = isDark ? Colors.white : Colors.black;
        final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: isDark ? Colors.black : Colors.white,
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
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
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
                      _criarOpcao(Icons.people, "Conectar-se com profissionais da área", isDark),
                      _criarOpcao(Icons.lightbulb, "Expressar sua criatividade", isDark),
                      _criarOpcao(Icons.video_library, "Catalogar Produções Independentes", isDark),
                      _criarOpcao(Icons.library_books, "Catalogar Produções Independentes", isDark),
                    ],
                  ),
                ),
                Container(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
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
                      _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Mário", "Engenheiro de Requisitos", isDark),
                      _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Manoel", "Tester", isDark),
                      _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Felipe", "Front-end", isDark),
                      _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Kaio", "Back-end", isDark),
                      _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Mateus", "DBA", isDark),
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
        );
      },
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
