import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:indiestream_app/projeto_create_screen.dart';
import 'package:indiestream_app/projetos_screen.dart';
import 'package:indiestream_app/pessoas_screen.dart';
import 'package:indiestream_app/user_detalhes_screen.dart';
import 'package:http/http.dart' as http;

import 'api_constants.dart';
import 'auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _drawerAnimationController;
  late Animation<double> _drawerScaleAnimation;
  String _userName = "Usuário";
  String _userImageUrl = "";
  bool _isLoadingUserData = true;

  final Duration _animationDuration = const Duration(milliseconds: 100);
  final Color _accentColor = const Color(0xFFFFDD00);
  final Color _primaryColor = const Color(0xFF1E2530);
  final Color _cardColor = const Color(0xFF2A3441);

  final List<Widget> _screens = [
    const ProjetosScreen(),
    const PessoasScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _drawerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _drawerAnimationController,
        curve: Curves.easeOutQuint,
      ),
    );
    _carregarDadosUsuario();
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosUsuario() async {
    setState(() {
      _isLoadingUserData = true;
    });

    try {
      final userId = await AuthService.getUserId();
      if (userId != null && mounted) {
        final response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/user/$userId"),
          headers: {'ngrok-skip-browser-warning': 'skip-browser-warning'},
        );

        if (response.statusCode == 200) {
          final userData = json.decode(utf8.decode(response.bodyBytes));
          setState(() {
            _userName = userData['nome'] ?? "Usuário";
            _userImageUrl = userData['imagemUrl'] ?? "";
            _isLoadingUserData = false;
          });
        } else {
          setState(() {
            _isLoadingUserData = false;
          });
        }
      } else {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      print("Erro ao carregar dados do usuário: $e");
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

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
      ).then((_) {
        // Recarregar dados do usuário ao voltar da tela de perfil
        _carregarDadosUsuario();
      });
    }
    _scaffoldKey.currentState?.closeDrawer();
  }

  Future<void> _sair() async {
    try {
      final confirmacao = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Sair',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Tem certeza que deseja sair?',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Sair',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted ? _accentColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHighlighted ? _accentColor.withOpacity(0.2) : _cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: FaIcon(
            icon,
            color: iconColor ?? (isHighlighted ? _accentColor : Colors.white70),
            size: 18,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 15,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _primaryColor,
                Color(0xFF252D3A),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo2.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.movie_filter,
                color: _accentColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'IndieStream',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _cardColor,
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                FontAwesomeIcons.bell,
                color: Colors.white,
                size: 16,
              ),
            ),
            onPressed: () {
              // Ação para notificações
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notificações em breve!'),
                  backgroundColor: _cardColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            tooltip: 'Notificações',
          ),
          const SizedBox(width: 8),
        ],
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cardColor,
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.barsStaggered,
              color: Colors.white,
              size: 16,
            ),
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
            _drawerAnimationController.forward();
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: _primaryColor,
        width: MediaQuery.of(context).size.width * 0.85,
        child: AnimatedBuilder(
          animation: _drawerAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _drawerScaleAnimation.value,
              child: child,
            );
          },
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  bottom: 24,
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _primaryColor,
                      Color(0xFF252D3A),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Menu',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.xmark,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onPressed: () {
                            _drawerAnimationController.reverse().then((_) {
                              _scaffoldKey.currentState?.closeDrawer();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: _navegarParaMeuPerfil,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Hero(
                              tag: 'profile-avatar',
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _accentColor,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _accentColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: _isLoadingUserData
                                    ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                                  strokeWidth: 2,
                                )
                                    : CircleAvatar(
                                  backgroundColor: _accentColor.withOpacity(0.2),
                                  backgroundImage: _userImageUrl.isNotEmpty
                                      ? NetworkImage(_userImageUrl)
                                      : null,
                                  child: _userImageUrl.isEmpty
                                      ? FaIcon(
                                    FontAwesomeIcons.user,
                                    size: 24,
                                    color: _accentColor,
                                  )
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userName,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _accentColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Ver perfil',
                                      style: GoogleFonts.poppins(
                                        color: _accentColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FaIcon(
                              FontAwesomeIcons.angleRight,
                              color: Colors.white54,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      icon: FontAwesomeIcons.house,
                      title: 'Início',
                      isHighlighted: true,
                      onTap: () {
                        _scaffoldKey.currentState?.closeDrawer();
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                    ),
                    _buildDrawerItem(
                      icon: FontAwesomeIcons.solidUser,
                      title: 'Meu Perfil',
                      onTap: _navegarParaMeuPerfil,
                    ),
                    _buildDrawerItem(
                      icon: FontAwesomeIcons.solidBookmark,
                      title: 'Favoritos',
                      onTap: () {
                        _scaffoldKey.currentState?.closeDrawer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Favoritos em breve!'),
                            backgroundColor: _cardColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: FontAwesomeIcons.gear,
                      title: 'Configurações',
                      onTap: () {
                        _scaffoldKey.currentState?.closeDrawer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Configurações em breve!'),
                            backgroundColor: _cardColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      child: Divider(
                        color: Colors.white24,
                        thickness: 1,
                      ),
                    ),
                    _buildDrawerItem(
                      icon: FontAwesomeIcons.rightFromBracket,
                      title: 'Sair',
                      iconColor: Colors.red[300],
                      onTap: _sair,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'IndieStream v1.0.0',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
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
