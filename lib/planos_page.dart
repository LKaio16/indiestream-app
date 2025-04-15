import 'package:flutter/material.dart';

class TelaPlanos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1D1D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 40,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Conheça nossos Planos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            _buildPlanoCard(
              cor: Colors.lightBlueAccent,
              icone: Icons.workspace_premium,
              titulo: "Plano Básico",
              preco: "Gratuito",
              descricao:
              "Benefícios\nDireito a adicionar apenas 1 projeto por vez\nLimitação de envio de convites de: 5 projetos",
            ),
            SizedBox(height: 20),
            _buildPlanoCard(
              cor: Colors.amberAccent,
              icone: Icons.diamond,
              titulo: "Plano Premium Mensal",
              preco: "R\$ 50/mês",
              descricao:
              "Benefícios\nDireito a adicionar projetos de maneira ilimitada\nSem limitação de envio de convites",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanoCard({
    required Color cor,
    required IconData icone,
    required String titulo,
    required String preco,
    required String descricao,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 40, color: Colors.black),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      preco,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  descricao,
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
