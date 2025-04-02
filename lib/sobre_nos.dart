import 'package:flutter/material.dart';

class PaginaSobre extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1D1D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
              color: Colors.grey[300],
              padding: EdgeInsets.all(10),
              child: Center(
                child: Text(
                  "Aqui você pode",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              color: Colors.yellow,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _criarOpcao(Icons.people, "Conectar-se com profissionais da área"),
                  _criarOpcao(Icons.lightbulb, "Expressar sua criatividade"),
                  _criarOpcao(Icons.video_library, "Catalogar Produções Independentes"),
                  _criarOpcao(Icons.library_books, "Catalogar Produções Independentes"),
                ],
              ),
            ),
            Container(
              color: Colors.grey[300],
              padding: EdgeInsets.all(10),
              child: Center(
                child: Text(
                  "Criadores do Aplicativo",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Mário", "Engenheiro de Requisitos"),
                  _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Manoel", "Tester"),
                  _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Felipe", "Front-end"),
                  _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Kaio", "Back-end"),
                  _criarAvatar("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3J8NKYVOAuvW7i5ndqRz3znDPK6ts3W8QA&s", "Mateus", "DBA"),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "© 2024 IndieStream. All rights reserved.",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _criarOpcao(IconData icone, String texto) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icone, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _criarAvatar(String url, String nome, String funcao) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(url),
          radius: 30,
        ),
        SizedBox(height: 5),
        Text(
          nome,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Text(
          funcao,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
