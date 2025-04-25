import 'package:findu/services/supabase_service.dart';
import 'package:findu/ui/components/default_input.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF009688),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Crie sua conta",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Preencha os dados abaixo para se cadastrar",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
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
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
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
                  
                  const SizedBox(height: 20),
                  
                  // Link para voltar ao login
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
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
                ],
              ),
            ),
    );
  }
} 