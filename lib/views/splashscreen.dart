// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _rotateController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Fade animation for logo
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Scale animation for logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Slide animation for text
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    // Rotate animation for decorative elements
    _rotateController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));
  }

  void _startAnimationSequence() async {
    // Start rotating background elements immediately
    _rotateController.repeat();

    // Sequence animations with delays
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _slideController.forward();

    // Navigate to next screen after total duration
    await Future.delayed(const Duration(seconds: 3));
    _navigateToHome();
  }

  void _navigateToHome() {
    // Replace with your navigation logic
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const HomePage()),
    // );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF0B2239)
        : const Color(0xFFFDFDFD);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Animated background gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: isDark
                    ? [
                        const Color(0xFF0B2239),
                        const Color(0xFF162B45).withOpacity(0.8),
                        const Color(0xFF009688).withOpacity(0.1),
                      ]
                    : [
                        const Color(0xFFFDFDFD),
                        const Color(0xFF009688).withOpacity(0.05),
                        const Color(0xFF2ECC71).withOpacity(0.03),
                      ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),

          // Floating animated circles
          ...List.generate(5, (index) => _buildFloatingCircle(index)),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo section with animations
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _scaleAnimation,
                    _fadeAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: _buildLogo(isDark),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // App name with slide animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'QariConnect', // Replace with your app name
                          style: GoogleFonts.merriweather(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome to the future of Teaching',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Loading indicator with custom styling
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildLoadingIndicator(isDark),
                ),
              ],
            ),
          ),

          // Bottom branding
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Powered by Innovation',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCircle(int index) {
    final colors = [
      const Color(0xFF009688),
      const Color(0xFF2ECC71),
      const Color(0xFFF4D03F),
    ];

    final positions = [
      const Alignment(-0.8, -0.6),
      const Alignment(0.8, -0.4),
      const Alignment(-0.6, 0.8),
      const Alignment(0.7, 0.6),
      const Alignment(0.0, -0.9),
    ];

    final sizes = [60.0, 40.0, 80.0, 35.0, 50.0];

    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Positioned(
          left:
              MediaQuery.of(context).size.width * (positions[index].x + 1) / 2 -
              sizes[index] / 2,
          top:
              MediaQuery.of(context).size.height *
                  (positions[index].y + 1) /
                  2 -
              sizes[index] / 2,
          child: Transform.rotate(
            angle:
                _rotateAnimation.value *
                2 *
                3.14159 *
                (index % 2 == 0 ? 1 : -1),
            child: Container(
              width: sizes[index],
              height: sizes[index],
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors[index % colors.length].withOpacity(0.2),
                    colors[index % colors.length].withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF009688), const Color(0xFF2ECC71)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009688).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icons/logo.png',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? const Color(0xFF2ECC71) : const Color(0xFF009688),
            ),
            backgroundColor: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading...',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }
}
