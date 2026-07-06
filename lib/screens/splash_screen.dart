import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Staggered entrance animation (logo -> name -> tagline).
  late final AnimationController _intro;
  // Continuous loop for the background glow and loading dots.
  late final AnimationController _loop;

  bool _navigated = false;

  static const Color _bgTop = Color(0xFF2563EB);
  static const Color _bgBottom = Color(0xFF002E86);

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _scheduleNavigate();
  }

  Future<void> _scheduleNavigate() async {
    // Long enough for the entrance animation to play and the branding to be
    // seen. Users can tap to skip early.
    await Future.delayed(const Duration(milliseconds: 4200));
    _navigate();
  }

  void _navigate() {
    if (_navigated || !mounted) return;
    _navigated = true;
    final user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacementNamed(
      context,
      user != null ? '/dashboard' : '/login',
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  double _interval(double begin, double end, {Curve curve = Curves.easeOut}) {
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(begin, end, curve: curve),
    ).value;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Tap anywhere to skip straight into the app.
      body: GestureDetector(
        onTap: _navigate,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgTop, _bgBottom],
            ),
          ),
          child: Stack(
            children: [
              // Animated decorative blobs.
              AnimatedBuilder(
                animation: _loop,
                builder: (context, _) {
                  final t = _loop.value;
                  return Stack(
                    children: [
                      _blob(
                        left: -60 + 20 * math.sin(t * 2 * math.pi),
                        top: size.height * 0.12 +
                            18 * math.cos(t * 2 * math.pi),
                        diameter: 180,
                        opacity: 0.12,
                      ),
                      _blob(
                        left: size.width * 0.6 +
                            16 * math.cos(t * 2 * math.pi),
                        top: size.height * 0.68 +
                            22 * math.sin(t * 2 * math.pi),
                        diameter: 240,
                        opacity: 0.10,
                      ),
                      _blob(
                        left: size.width * 0.7,
                        top: size.height * 0.05 +
                            14 * math.sin(t * 2 * math.pi + 1),
                        diameter: 120,
                        opacity: 0.10,
                      ),
                    ],
                  );
                },
              ),

              // Foreground content.
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 28),
                    _buildAppName(),
                    const SizedBox(height: 10),
                    _buildTagline(),
                  ],
                ),
              ),

              // Bottom loading dots + footer.
              Positioned(
                left: 0,
                right: 0,
                bottom: 48,
                child: Column(
                  children: [
                    _buildLoadingDots(),
                    const SizedBox(height: 18),
                    Opacity(
                      opacity: _interval(0.6, 1.0),
                      child: const Text(
                        'Manajer Tugas Mahasiswa Berperforma Tinggi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white38,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blob({
    required double left,
    required double top,
    required double diameter,
    required double opacity,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_intro, _loop]),
      builder: (context, _) {
        final appear = Curves.elasticOut.transform(
          Interval(0.0, 0.6).transform(_intro.value),
        );
        // Gentle pulsing halo.
        final pulse = 0.5 + 0.5 * math.sin(_loop.value * 2 * math.pi);
        return Transform.scale(
          scale: appear.clamp(0.0, 1.2),
          child: Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.25 + 0.25 * pulse),
                  blurRadius: 32 + 16 * pulse,
                  spreadRadius: 4 * pulse,
                ),
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.schedule, size: 66, color: _bgTop),
                Positioned(
                  bottom: 18,
                  right: 18,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 32,
                      color: _bgBottom,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName() {
    final v = _interval(0.35, 0.75);
    return Opacity(
      opacity: v,
      child: Transform.translate(
        offset: Offset(0, 16 * (1 - v)),
        child: const Text(
          'DoItNow',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTagline() {
    final v = _interval(0.5, 0.9);
    return Opacity(
      opacity: v,
      child: Transform.translate(
        offset: Offset(0, 12 * (1 - v)),
        child: const Text(
          'Kelola tugas, kuasai waktu',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            // Each dot bobs with a phase offset.
            final phase = (_loop.value + i * 0.2) % 1.0;
            final lift = math.sin(phase * 2 * math.pi).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.35 + 0.55 * lift),
              ),
            );
          }),
        );
      },
    );
  }
}
