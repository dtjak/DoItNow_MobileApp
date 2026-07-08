import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Membuat state yang dapat diubah untuk widget layar splash.
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animasi masuk bertahap (logo -> nama -> tagline).
  late final AnimationController _intro;
  // Loop berkelanjutan untuk efek cahaya latar dan titik loading.
  late final AnimationController _loop;

  bool _navigated = false;

  static const Color _bgTop = Color(0xFF2563EB);
  static const Color _bgBottom = Color(0xFF002E86);

  /// Menyiapkan controller animasi intro dan loop lalu menjadwalkan navigasi.
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

  /// Menunggu durasi splash selesai lalu memicu navigasi.
  Future<void> _scheduleNavigate() async {
    // Cukup lama agar animasi masuk selesai diputar dan branding
    // terlihat. Pengguna bisa mengetuk untuk melewati lebih awal.
    await Future.delayed(const Duration(milliseconds: 4200));
    _navigate();
  }

  /// Menavigasi ke dashboard jika pengguna sudah masuk, jika tidak ke layar masuk.
  void _navigate() {
    if (_navigated || !mounted) return;
    _navigated = true;
    final user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacementNamed(
      context,
      user != null ? '/dashboard' : '/login',
    );
  }

  /// Membuang kedua controller animasi untuk membebaskan resource.
  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  /// Menghitung nilai progres yang dihaluskan untuk sub-interval animasi intro.
  double _interval(double begin, double end, {Curve curve = Curves.easeOut}) {
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(begin, end, curve: curve),
    ).value;
  }

  /// Membangun tata letak layar splash dengan latar belakang, logo, dan titik loading.
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Ketuk di mana saja untuk langsung masuk ke aplikasi.
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
              // Bulatan dekoratif beranimasi.
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

              // Konten latar depan.
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

              // Titik loading bawah + footer.
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

  /// Membangun satu lingkaran translusen dekoratif pada posisi yang diberikan.
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

  /// Membangun ikon logo aplikasi yang berdenyut beranimasi.
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_intro, _loop]),
      builder: (context, _) {
        final appear = Curves.elasticOut.transform(
          Interval(0.0, 0.6).transform(_intro.value),
        );
        // Halo berdenyut lembut.
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

  /// Membangun teks nama aplikasi yang muncul dengan efek fade-in.
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

  /// Membangun teks tagline yang muncul dengan efek fade-in di bawah nama aplikasi.
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

  /// Membangun baris titik loading yang bergerak naik-turun beranimasi.
  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            // Setiap titik bergerak naik-turun dengan selisih fase.
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
