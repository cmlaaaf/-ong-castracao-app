import 'package:flutter/material.dart';
import 'animais/animal_list_screen.dart';
import 'voluntarios/voluntario_list_screen.dart';
import 'contribuicoes/contribuicao_list_screen.dart';

/// Tela inicial de boas-vindas com navegação para os módulos
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[300]!,
              Colors.green[500]!,
              Colors.green[700]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 600),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20.0 : 32.0,
                    vertical: 24.0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 48,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                    
                    // Logo - Patinha
                    Hero(
                      tag: 'logo',
                      child: Container(
                        padding: EdgeInsets.all(isMobile ? 28 : 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.pets,
                          size: isMobile ? 80 : 100,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: isMobile ? 36 : 48),
                    
                    // Mensagem de boas-vindas
                    Text(
                      'Bem-vindo!',
                      style: TextStyle(
                        fontSize: isMobile ? 40 : 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'ONG Castração Animal',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                    ),
                    
                    const Spacer(flex: 2),
                    
                    // Botões de navegação
                    _buildMenuButton(
                      context,
                      icon: Icons.pets,
                      title: 'Animais Castrados',
                      subtitle: 'Gerenciar cadastros',
                      color: Colors.white,
                      onTap: () => _navigateTo(context, const AnimalListScreen()),
                      isMobile: isMobile,
                    ),
                    
                    SizedBox(height: isMobile ? 16 : 20),
                    
                    _buildMenuButton(
                      context,
                      icon: Icons.people,
                      title: 'Voluntários',
                      subtitle: 'Gerenciar voluntários ativos',
                      color: Colors.white,
                      onTap: () => _navigateTo(context, const VoluntarioListScreen()),
                      isMobile: isMobile,
                    ),
                    
                    SizedBox(height: isMobile ? 16 : 20),
                    
                    _buildMenuButton(
                      context,
                      icon: Icons.monetization_on,
                      title: 'Contribuições',
                      subtitle: 'Registrar doações',
                      color: Colors.white,
                      onTap: () => _navigateTo(context, const ContribuicaoListScreen()),
                      isMobile: isMobile,
                    ),
                    
                    const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        splashColor: Colors.green.withOpacity(0.3),
        highlightColor: Colors.green.withOpacity(0.1),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 18 : 24),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 14 : 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[400]!, Colors.green[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: isMobile ? 28 : 36,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: isMobile ? 16 : 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isMobile ? 17 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.green[700],
                  size: isMobile ? 16 : 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
