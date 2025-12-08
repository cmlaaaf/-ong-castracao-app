import 'package:flutter/material.dart';
import 'cadastro_responsavel_animal_screen.dart';
import 'animais/animal_list_screen.dart';
import 'voluntarios/voluntario_contribuicao_screen.dart';

/// Tela inicial do aplicativo com 3 botões principais
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
              Color(0xFFE0F2F1),
              Color(0xFFB2DFDB),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: Column(
          children: [
            // Cabeçalho fixo no topo
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 16 : 20,
                horizontal: isMobile ? 20 : 32,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF26A69A),
                    Color(0xFF00897B),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo - Patinha
                    Container(
                      padding: EdgeInsets.all(isMobile ? 8 : 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pets,
                        size: isMobile ? 28 : 32,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    // Texto
                    Text(
                      'Comissão Patinhas',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Conteúdo scrollável
            Expanded(
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        SizedBox(height: isMobile ? 20 : 30),
                        
                        // Mensagem de Boas-vindas
                        Text(
                          'Bem-vindo!',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        
                        SizedBox(height: isMobile ? 40 : 60),
                        
                        // Botão 1 - Cadastrar Responsável + Animal
                        _buildMenuButton(
                          context,
                          icon: Icons.add_circle,
                          title: 'Cadastrar Responsável + Animal',
                          subtitle: 'Novo cadastro completo',
                          color: Colors.white,
                          gradientColors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CadastroResponsavelAnimalScreen(),
                            ),
                          ),
                          isMobile: isMobile,
                        ),
                        
                        SizedBox(height: isMobile ? 16 : 20),
                        
                        // Botão 2 - Animais
                        _buildMenuButton(
                          context,
                          icon: Icons.pets,
                          title: 'Animais',
                          subtitle: 'Lista e gestão de animais',
                          color: Colors.white,
                          gradientColors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AnimalListScreen(),
                            ),
                          ),
                          isMobile: isMobile,
                        ),
                        
                        SizedBox(height: isMobile ? 16 : 20),
                        
                        // Botão 3 - Voluntários e Contribuições
                        _buildMenuButton(
                          context,
                          icon: Icons.volunteer_activism,
                          title: 'Voluntários e Contribuições',
                          subtitle: 'Gerenciar voluntários e doações',
                          color: Colors.white,
                          gradientColors: [Color(0xFFFF7043), Color(0xFFE64A19)],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VoluntarioContribuicaoScreen(),
                            ),
                          ),
                          isMobile: isMobile,
                        ),
                        
                        SizedBox(height: isMobile ? 40 : 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        splashColor: gradientColors[0].withOpacity(0.3),
        highlightColor: gradientColors[0].withOpacity(0.1),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 20 : 26),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 18),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: isMobile ? 34 : 42,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: isMobile ? 18 : 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isMobile ? 17 : 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: isMobile ? 5 : 7),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: gradientColors[0].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: gradientColors[1],
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
