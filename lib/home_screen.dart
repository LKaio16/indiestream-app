import 'package:flutter/material.dart';
import 'package:indiestream_app/projeto_create_screen.dart';
import 'package:indiestream_app/projetos_screen.dart';
import 'package:indiestream_app/pessoas_screen.dart';
import 'package:indiestream_app/user_detalhes_screen.dart';

import 'auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Duration _animationDuration = const Duration(milliseconds: 100);
  final Color _accentColor = const Color(0xFFFFDD00);

  final List<Widget> _screens = [
    const ProjetosScreen(),
    const PessoasScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddButtonTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CriarProjetoScreen()),
    );
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
          builder: (context) => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
            ),
          ),
        );

        await AuthService.logout();

        if (!mounted) return;

        Navigator.of(context).pop();
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
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

  Widget _buildAnimatedNavItem({
    required int index,
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;
    final Color targetColor = isSelected ? _accentColor : Colors.white70;
    final double targetIconScale = isSelected ? 1.1 : 1.0;
    const double baseIconSize = 24.0;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => _onItemTapped(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.0, end: targetIconScale),
                duration: _animationDuration,
                curve: Curves.easeOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                      begin: isSelected ? Colors.white70 : _accentColor,
                      end: targetColor),
                  duration: _animationDuration,
                  builder: (context, color, child) {
                    return Icon(
                      isSelected ? selectedIcon : unselectedIcon,
                      color: color,
                      size: baseIconSize,
                    );
                  },
                ),
              ),
              const SizedBox(height: 2),
              TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                      begin: isSelected ? Colors.white70 : _accentColor,
                      end: targetColor),
                  duration: _animationDuration,
                  builder: (context, color, child) {
                    return Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'IndieStream',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _accentColor,
                    child: const Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.white70),
              title: const Text(
                'Meu Perfil',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: _navegarParaMeuPerfil,
            ),
            const Divider(color: Colors.white24, height: 1),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.white70),
              title: const Text(
                'Sair',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: _sair,
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddButtonTapped,
        backgroundColor: _accentColor,
        foregroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
        tooltip: 'Criar Projeto',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        height: 60,
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Container(
          padding: const EdgeInsets.only(bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAnimatedNavItem(
                index: 0,
                selectedIcon: Icons.work,
                unselectedIcon: Icons.work_outline,
                label: 'Projetos',
              ),
              const SizedBox(width: 70),
              _buildAnimatedNavItem(
                index: 1,
                selectedIcon: Icons.people,
                unselectedIcon: Icons.people_outline,
                label: 'Pessoas',
              ),
            ],
          ),
        ),
      ),
    );
  }
}