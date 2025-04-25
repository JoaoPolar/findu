import 'package:findu/services/supabase_service.dart';
import 'package:findu/ui/components/default_input.dart';
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
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightAnimation = Tween<double>(
      begin: 0.45,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.addListener(() {
      setState(() {});
    });
  }

  Future<void> _realizarLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }

    try {
      final response = await SupabaseService().login(email, password);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login bem-sucedido: ${response.user?.email}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro no login: $e')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height,
      width: size.width,
      color: const Color(0xFF009688),
      child: Column(
        children: [
          // Parte superior em verde com retângulo cinza
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: size.width,
            height: size.height * (_heightAnimation.value),
            color: const Color(0xFF009688), // Verde teal como na imagem
            child: Center(
              child: AnimatedOpacity(
                opacity: _expanded ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: size.width * 0.5,
                  height: size.width * 0.5,
                  color: const Color(0xFF009688),
                ),
              ),
            ),
          ),

          // Parte inferior branca
          Expanded(
            child: Container(
              width: size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  DefaultInput(
                    controller: _emailController,
                    hintText: 'email@exemplo.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  DefaultInput(
                    controller: _passwordController,
                    hintText: 'password',
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _realizarLogin,
                    child: const Text('Entrar'),
                  ),
                  const Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _toggleExpand,
                        child: const Text(
                          "Não tem uma conta? Se cadastre aqui",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
