import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaPlanos extends StatefulWidget {
  @override
  _TelaPlanosState createState() => _TelaPlanosState();
}

class _TelaPlanosState extends State<TelaPlanos> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // Carrega a preferência do tema (modo claro ou escuro) da memória
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('config_darkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = isDarkMode ? ThemeData.dark() : ThemeData.light(); // Muda o tema baseado na preferência

    return MaterialApp(
      theme: theme, // Aplica o tema conforme a preferência
      home: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 40),
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
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              _buildPlanoCard(
                context,
                cor: Colors.lightBlueAccent,
                icone: Icons.workspace_premium,
                titulo: "Plano Básico",
                preco: "Gratuito",
                descricao:
                "Benefícios\n• Direito a adicionar apenas 1 projeto por vez\n• Limitação de envio de convites de: 5 projetos",
              ),
              SizedBox(height: 20),
              _buildPlanoCard(
                context,
                cor: Colors.amberAccent,
                icone: Icons.diamond,
                titulo: "Plano Premium Mensal",
                preco: "R\$ 50/mês",
                descricao:
                "Benefícios\n• Direito a adicionar projetos de maneira ilimitada\n• Sem limitação de envio de convites",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanoCard(
      BuildContext context, {
        required Color cor,
        required IconData icone,
        required String titulo,
        required String preco,
        required String descricao,
      }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: cor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 40, color: theme.iconTheme.color),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(titulo, style: theme.textTheme.titleMedium),
                    Text(preco, style: theme.textTheme.titleSmall),
                  ],
                ),
                SizedBox(height: 8),
                Text(descricao, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
