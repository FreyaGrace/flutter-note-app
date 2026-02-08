import 'dart:math';
import 'package:flutter/material.dart';

class MysticBackground extends StatefulWidget {
  final Widget child;
  const MysticBackground({super.key, required this.child});

  @override
  State<MysticBackground> createState() => _MysticBackgroundState();
}

class _MysticBackgroundState extends State<MysticBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rand = Random();

  // ⭐ Store star positions once
  late final List<Offset> _stars;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _stars = List.generate(
      30,
      (_) => Offset(_rand.nextDouble(), _rand.nextDouble()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color.fromARGB(255, 84, 29, 187),
                      Color.fromARGB(255, 78, 69, 201),
                      Color.fromARGB(255, 9, 18, 201),
                    ]
                  : const [
                      Color.fromARGB(255, 203, 153, 243),
                      Color.fromARGB(255, 146, 191, 245),
                      Color.fromARGB(255, 203, 140, 240),
                    ],
            ),
          ),
          child: Stack(
            children: [
              // ✨ Twinkling stars
              for (final star in _stars)
                Positioned(
                  left: size.width * star.dx,
                  top: size.height * star.dy,
                  child: Opacity(
                    opacity: 0.5 + (_controller.value * 0.5),
                    child: const Icon(
                      Icons.star,
                      size: 6,
                      color: Color.fromARGB(255, 241, 239, 99),
                    ),
                  ),
                ),

              // ☁️ Cloud overlay (optional but nice)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.6,
                    child: Image.asset(
                      'assets/cloud.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              widget.child,
            ],
          ),
        );
      },
    );
  }
}
