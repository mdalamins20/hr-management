import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';
import 'setup_screen.dart';

/// Screen 1 of the reference design: blue welcome / splash screen.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.splashTop, AppColors.splashBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 56),
                // HR logo mark
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 46,
                      height: 40,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 8,
                            child: Icon(Icons.circle,
                                size: 11, color: Colors.white),
                          ),
                          Positioned(
                            left: 15,
                            top: 0,
                            child: Icon(Icons.person,
                                size: 24, color: Colors.white),
                          ),
                          Positioned(
                            right: 0,
                            top: 10,
                            child: Icon(Icons.circle,
                                size: 9, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'HR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'HR Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Better People. Stronger Teams.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Spacer(),
                const _Illustration(),
                const Spacer(),
                // Page dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 22,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const CircleAvatar(
                        radius: 3, backgroundColor: Colors.white38),
                    const SizedBox(width: 6),
                    const CircleAvatar(
                        radius: 3, backgroundColor: Colors.white38),
                  ],
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => appState.configured
                              ? const MainShell()
                              : const SetupScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward, size: 19),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 34),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stylised team illustration drawn with shapes (no external assets needed),
/// echoing the illustration in the reference design.
class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft blob background
          Container(
            width: 260,
            height: 190,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          // Leaf accents
          const Positioned(
            left: 26,
            bottom: 8,
            child: Icon(Icons.eco, color: Color(0xFF39C48D), size: 42),
          ),
          const Positioned(
            right: 30,
            bottom: 22,
            child: Icon(Icons.eco_outlined, color: Color(0xFF2FA8E0), size: 30),
          ),
          // Profile card in the middle
          Container(
            width: 92,
            height: 118,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFBFD6FF),
                  child: Icon(Icons.person, color: Color(0xFF2F6BFF), size: 22),
                ),
                const SizedBox(height: 10),
                _line(52),
                const SizedBox(height: 6),
                _line(38),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: Color(0xFF39C48D), size: 13),
                    SizedBox(width: 4),
                    Icon(Icons.star, color: Color(0xFFF5C04E), size: 13),
                  ],
                ),
              ],
            ),
          ),
          // People
          const Positioned(
            left: 38,
            bottom: 18,
            child: _Person(color: Color(0xFF14213D), icon: Icons.person),
          ),
          const Positioned(
            right: 38,
            bottom: 18,
            child: _Person(color: Color(0xFF2F6BFF), icon: Icons.person_2),
          ),
          const Positioned(
            bottom: 0,
            child: _Person(color: Color(0xFF7EB6FF), icon: Icons.laptop_mac),
          ),
        ],
      ),
    );
  }

  static Widget _line(double w) => Container(
        width: w,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.white38,
          borderRadius: BorderRadius.circular(4),
        ),
      );
}

class _Person extends StatelessWidget {
  const _Person({required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircleAvatar(
          radius: 13,
          backgroundColor: Color(0xFFF2C9A4),
          child: Icon(Icons.face, size: 16, color: Color(0xFF8A5A33)),
        ),
        const SizedBox(height: 2),
        Container(
          width: 44,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Icon(icon, color: Colors.white70, size: 19),
        ),
      ],
    );
  }
}
