import 'package:findu/services/supabase_service.dart';
import 'package:findu/ui/components/default_input.dart';
import 'package:findu/ui/pages/signup_page.dart';
import 'package:findu/ui/pages/success_page.dart';
import 'package:flutter/material.dart';

Widget preview() {
  return DrawerLogin();
}

class DrawerLogin extends StatefulWidget {
  const DrawerLogin({Key? key}) : super(key: key);

  @override
  State<DrawerLogin> createState() => _DrawerLoginState();
}

class _DrawerLoginState extends State<DrawerLogin>
    with SingleTickerProviderStateMixin {
  bool _drawerOpen = false;
  late AnimationController _controller;
  late Animation<double> _drawerAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _drawerAnimation = Tween<double>(
      begin: 0.0,
      end: 0.65,  // Reduzido para evitar overflow
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    
    _controller.addListener(() {
      setState(() {});
    });
  }

  Future<void> _realizarLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _mostrarErro('Preencha todos os campos!');
      return;
    }

    // Mostrar indicador de carregamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            backgroundColor: Color(0xFF009688),
          ),
        );
      },
    );

    try {
      final response = await SupabaseService().login(email, password);
      
      // Fechar o diálogo de carregamento
      Navigator.pop(context);
      
      if (response.user != null) {
        // Navegação para a página de sucesso
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SuccessPage(email: email),
          ),
        );
      } else {
        _mostrarErro('Erro na autenticação: usuário ou senha inválidos');
      }
    } catch (e) {
      // Fechar o diálogo de carregamento
      Navigator.pop(context);
      
      String mensagemErro = 'Erro de autenticação';
      
      // Verificar tipos específicos de erro para mensagens mais detalhadas
      if (e.toString().contains('Invalid login credentials')) {
        mensagemErro = 'Email ou senha incorretos';
      } else if (e.toString().contains('network')) {
        mensagemErro = 'Erro de conexão. Verifique sua internet';
      }
      
      _mostrarErro(mensagemErro);
    }
  }
  
  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _drawerOpen = !_drawerOpen;
      if (_drawerOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: const Color(0xFF009688),
      body: Stack(
        children: [
          // Conteúdo da tela inicial com logo e botão entrar
          Positioned.fill(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),
                  // Área para logo
                  Container(
                    width: size.width * 0.35,
                    height: size.width * 0.35,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Título
                  const Text(
                    "FindU",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Encontre sua sala",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(flex: 1),
                  // Botão entrar principal
                  Container(
                    width: size.width * 0.6,
                    height: 48,
                    margin: const EdgeInsets.only(bottom: 40),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _toggleDrawer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF009688),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'ENTRAR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Drawer com formulário de login
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            bottom: 0,
            left: 0,
            right: 0,
            height: _drawerOpen ? size.height * _drawerAnimation.value : 0, // Controla a altura do drawer
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Barra de arraste
                        Center(
                          child: GestureDetector(
                            onTap: _toggleDrawer,
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Entre para encontrar sua sala",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Campos de login
                        DefaultInput(
                          controller: _emailController,
                          hintText: 'email@exemplo.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        DefaultInput(
                          controller: _passwordController,
                          hintText: 'password',
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Botão de login no formulário
                        Center(
                          child: Container(
                            width: size.width * 0.6,
                            height: 44,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _realizarLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF009688),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                'ENTRAR',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        // Link para cadastro
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              // Fechar o drawer
                              if (_drawerOpen) {
                                _toggleDrawer();
                              }
                              
                              // Navegar para a página de cadastro
                              Future.delayed(Duration(milliseconds: 300), () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupPage(),
                                  ),
                                );
                              });
                            },
                            child: const Text(
                              "Não tem uma conta? Se cadastre aqui",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
