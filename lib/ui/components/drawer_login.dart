import 'package:flutter/material.dart';

class DrawerLogin extends StatefulWidget {
  const DrawerLogin({Key? key}) : super(key: key);

  @override
  State<DrawerLogin> createState() => _DrawerLoginState();
}

class _DrawerLoginState extends State<DrawerLogin> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightAnimation = Tween<double>(begin: 0.45, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addListener(() {
      setState(() {});
    });
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
            ),
          ),
        ],
      ),
    );
  }
}
