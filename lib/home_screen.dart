import 'package:flutter/material.dart';
import 'projetos_screen.dart';
import 'pessoas_screen.dart';
import 'auth_service.dart';
import 'user_detalhes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const ProjetosScreen(),
    const PessoasScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _navegarParaMeuPerfil() async {
    final userId = await AuthService.getUserId();
    if (userId != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetalhesScreen(userId: userId.toString()),
        ),
      );
    }
    _scaffoldKey.currentState?.closeDrawer();
  }

  Future<void> _sair() async {
    try {
      final confirmacao = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sair'),
          content: const Text('Tem certeza que deseja sair?'),
          backgroundColor: Colors.grey[900],
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(color: Colors.white70),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sair', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmacao == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        await AuthService.logout();

        if (!mounted) return;

        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao sair: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('IndieStream', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 30),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white70),
              title: const Text(
                'Meu Perfil',
                style: TextStyle(color: Colors.white),
              ),
              onTap: _navegarParaMeuPerfil,
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.white70),
              title: const Text(
                'Sair',
                style: TextStyle(color: Colors.white),
              ),
              onTap: _sair,
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Projetos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Pessoas',
          ),
        ],
      ),
    );
  }
}
