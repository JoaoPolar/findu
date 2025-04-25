import 'package:findu/services/supabase_service.dart';
import 'package:findu/ui/components/default_input.dart';
import 'package:findu/ui/utils/hero_tags.dart';
import 'package:findu/ui/utils/page_transition.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar a animação quando a tela for carregada
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _mostrarMensagem(String mensagem, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  Future<void> _realizarCadastro() async {
    // Validação dos campos
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _mostrarMensagem('Preencha todos os campos!', isError: true);
      return;
    }
    
    if (password != confirmPassword) {
      _mostrarMensagem('As senhas não coincidem!', isError: true);
      return;
    }
    
    if (password.length < 6) {
      _mostrarMensagem('A senha deve ter pelo menos 6 caracteres!', isError: true);
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await SupabaseService().signUp(email, password, name);
      
      setState(() {
        _isLoading = false;
      });
      
      if (response.user != null) {
        _mostrarMensagem('Cadastro realizado com sucesso! Verifique seu email para confirmar.');
        
        // Iniciar a animação de saída
        _animationController.reverse();
        
        // Aguardar um pouco antes de voltar para dar tempo de ler a mensagem
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        _mostrarMensagem('Erro ao criar conta.', isError: true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      String mensagemErro = 'Erro ao criar conta';
      
      if (e.toString().contains('already registered')) {
        mensagemErro = 'Este email já está cadastrado';
      } else if (e.toString().contains('network')) {
        mensagemErro = 'Erro de conexão. Verifique sua internet';
      } else if (e.toString().contains('invalid email')) {
        mensagemErro = 'Email inválido';
      }
      
      _mostrarMensagem(mensagemErro, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Iniciar animação de saída antes de navegar
            _animationController.reverse().then((_) {
              Navigator.pop(context);
            });
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF009688),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Título
                    Hero(
                      tag: HeroTags.title,
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          "Crie sua conta",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        "Preencha os dados abaixo para se cadastrar",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    DefaultInput(
                      controller: _nameController,
                      hintText: 'Nome completo',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 16),
                    
                    DefaultInput(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    
                    DefaultInput(
                      controller: _passwordController,
                      hintText: 'Senha',
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    
                    DefaultInput(
                      controller: _confirmPasswordController,
                      hintText: 'Confirmar senha',
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Botão de cadastro
                    Center(
                      child: Hero(
                        tag: HeroTags.mainButton + "_form",
                        child: Material(
                          color: Colors.transparent,
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
                              onPressed: _realizarCadastro,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF009688),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                'CADASTRAR',
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
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Link para voltar ao login
                    Center(
                      child: Hero(
                        tag: HeroTags.toggleButton,
                        child: Material(
                          color: Colors.transparent,
                          child: GestureDetector(
                            onTap: () {
                              // Iniciar animação de saída antes de navegar
                              _animationController.reverse().then((_) {
                                Navigator.pop(context);
                              });
                            },
                            child: const Text(
                              "Já tem uma conta? Entre aqui",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 