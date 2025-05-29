import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;
  bool isDarkMode = false;

  final List<Map<String, dynamic>> _pages = [
    {
      "title": "Bem-vindo ao IndieStream!",
      "description": "Conecte-se com talentos da indústria audiovisual e dê vida aos seus projetos independentes.",
      "image": "assets/onboarding1.png",
      "color": const Color(0xFF6C63FF)
    },
    {
      "title": "Descubra Projetos",
      "description": "Explore projetos inovadores ou crie o seu próprio e encontre colaboradores talentosos.",
      "image": "assets/onboarding2.png",
      "color": const Color(0xFF00C853)
    },
    {
      "title": "Comece sua Jornada",
      "description": "Entre agora e faça parte da comunidade de criadores independentes.",
      "image": "assets/onboarding3.png",
      "color": const Color(0xFFFF6D00)
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadThemePreference();

    // Configuração da animação
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Configurar feedback tátil para transições de página
    _pageController.addListener(() {
      if (_pageController.page == _pageController.page?.round()) {
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('config_darkMode') ?? false;
    });
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('config_darkMode', isDarkMode);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      // Feedback tátil ao mudar de página
      HapticFeedback.mediumImpact();

      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
      );
    } else {
      // Feedback tátil ao finalizar
      HapticFeedback.heavyImpact();

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _skipToEnd() {
    HapticFeedback.mediumImpact();
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cores dinâmicas baseadas no tema e na página atual
    final Color currentColor = _pages[_currentPage]["color"];
    final backgroundColor = isDarkMode
        ? const Color(0xFF121212)
        : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3142);
    final secondaryTextColor = isDarkMode
        ? Colors.white70
        : const Color(0xFF4F5D75);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Fundo com gradiente sutil
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkMode
                        ? [
                      const Color(0xFF121212),
                      Color.lerp(const Color(0xFF121212), currentColor, 0.15) ?? const Color(0xFF121212),
                    ]
                        : [
                      Colors.white,
                      Color.lerp(Colors.white, currentColor, 0.08) ?? Colors.white,
                    ],
                  ),
                ),
              ),
            ),

            // Botão de pular
            Positioned(
              top: 16,
              right: 16,
              child: _currentPage < _pages.length - 1
                  ? TextButton(
                onPressed: _skipToEnd,
                style: TextButton.styleFrom(
                  foregroundColor: currentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: currentColor.withOpacity(0.3), width: 1),
                  ),
                ),
                child: Text(
                  "Pular",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),

            Column(
              children: [
                // Área de conteúdo principal
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                        // Reiniciar animação ao mudar de página
                        _animationController.reset();
                        _animationController.forward();
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Imagem com animação
                              Container(
                                height: 280,
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 40),
                                child: Hero(
                                  tag: 'onboarding_image_$index',
                                  child: Image.asset(
                                    _pages[index]["image"]!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              // Título com efeito de destaque
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    currentColor,
                                    Color.lerp(currentColor, Colors.deepPurple, 0.5) ?? currentColor,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  _pages[index]["title"]!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Descrição
                              Text(
                                _pages[index]["description"]!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: secondaryTextColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Indicadores de página personalizados
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: _currentPage == index ? 24 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: _currentPage == index
                              ? currentColor
                              : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                          boxShadow: _currentPage == index
                              ? [
                            BoxShadow(
                              color: currentColor.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),

                // Botão de ação principal
                Padding(
                  padding: const EdgeInsets.only(bottom: 48.0, left: 24.0, right: 24.0),
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [
                            currentColor,
                            Color.lerp(currentColor, Colors.deepPurple, 0.6) ?? currentColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: currentColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == _pages.length - 1 ? "Começar Agora" : "Próximo",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentPage == _pages.length - 1
                                  ? Icons.login_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
