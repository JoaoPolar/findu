import 'package:flutter/material.dart';

class CustomPageTransition extends PageRouteBuilder {
  final Widget page;
  final TransitionType transitionType;
  final Curve curve;
  final Duration duration;
  final Duration reverseDuration;

  CustomPageTransition({
    required this.page,
    this.transitionType = TransitionType.fade,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            animation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            switch (transitionType) {
              case TransitionType.fade:
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              case TransitionType.slideUp:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              case TransitionType.slideDown:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, -0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              case TransitionType.scale:
                return ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.9,
                    end: 1.0,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              case TransitionType.rotate:
                return RotationTransition(
                  turns: Tween<double>(
                    begin: 0.05,
                    end: 0.0,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                );
              case TransitionType.slideLeft:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              case TransitionType.slideRight:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              default:
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
            }
          },
        );
}

enum TransitionType {
  fade,
  slideUp,
  slideDown,
  scale,
  rotate,
  slideLeft,
  slideRight,
} 