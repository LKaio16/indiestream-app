import 'package:flutter/material.dart';
import 'login_screen.dart';

class CadastroScreen extends StatefulWidget {
  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  String? perfilSelecionado;
  final List<String> listaPerfis = ["Artista", "Fã", "Produtor", "Outro"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1D1D),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ---- LOGO ----
            Image.asset(
            'assets/logo.png',
              height: 80,
            ),
              const SizedBox(height: 20),

              // ---- TÍTULO ----
              Text(
                "Crie sua Conta",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              SizedBox(height: 15),

              // ---- CAMPOS DE TEXTO ----
              _campoTexto("Email", "Insira seu Email"),
              _campoTexto("Nome", "Insira seu nome"),
              _campoTexto("Senha", "Insira sua senha", isSenha: true),
              _campoTexto("Confirme Senha", "Confirme sua senha", isSenha: true),

              // ---- SELEÇÃO DE PERFIL ----
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Profissão", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10),
                margin: EdgeInsets.only(top: 5, bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: perfilSelecionado,
                    hint: Text("Selecione seu perfil", style: TextStyle(color: Colors.black)),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black), // Ícone de seta
                    items: listaPerfis.map((String valor) {
                      return DropdownMenuItem<String>(
                        value: valor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(valor, style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? novoValor) {
                      setState(() {
                        perfilSelecionado = novoValor;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              // ---- BOTÃO AVANÇAR ----
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                onPressed: () {},
                child: Text(
                  "Avançar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              SizedBox(height: 20),
              // ------ Separação "OU" ------
              Text(
                "- OU -",
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: 10),

              // ------ Link "Já possui conta? Entre" ------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Já possui conta? ",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      "  Entrar",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- COMPONENTE PARA CAMPOS DE TEXTO ----
  Widget _campoTexto(String rotulo, String dica, {bool isSenha = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 5),
        TextField(
          obscureText: isSenha,
          decoration: InputDecoration(
            hintText: dica,
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
