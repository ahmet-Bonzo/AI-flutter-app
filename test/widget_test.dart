
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() => runApp(const KralApp());

class KralApp extends StatelessWidget {
  const KralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnaMenu(),
    );
  }
}

class AnaMenu extends StatefulWidget {
  const AnaMenu({super.key});

  @override
  State<AnaMenu> createState() => _AnaMenuState();
}

class _AnaMenuState extends State<AnaMenu> with SingleTickerProviderStateMixin {
  int aktifIndex = 1;
  double _activeButtonX = 0.0;
  late Ticker _ticker;
  double _time = 0;

@override
void initState() {
  super.initState();
  _ticker = Ticker((elapsed) {
    if (mounted) {
      setState(() {
        _time = elapsed.inMilliseconds.toDouble();
      });
    }
  });

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _ticker.start();
  });
}


  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _setActiveButton(int index, double buttonX) {
    setState(() {
      aktifIndex = index;
      _activeButtonX = buttonX;
    });
  }

  Widget _buildButton(IconData icon, String text, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            Offset offset = renderBox.localToGlobal(Offset.zero);
            double buttonX = offset.dx + renderBox.size.width / 2;
            _setActiveButton(index, buttonX);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: aktifIndex == index
                      ? Colors.pinkAccent
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: aktifIndex == index
                      ? [
                          BoxShadow(
                            color: Colors.pinkAccent.withValues(alpha: 0.12),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  icon,
                  color:
                      aktifIndex == index ? Colors.white : Colors.grey.shade600,
                  size: aktifIndex == index ? 28 : 26,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: aktifIndex == index
                      ? Colors.pinkAccent
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE4EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: () {
                setState(() {
                  aktifIndex = 3;
                });
              },
              child: const Text("Ayarlar",
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ),
          )
        ],
      ),
      body: Center(
        child: Text(
          aktifIndex == 0
              ? "📅 Planlı Sayfası"
              : aktifIndex == 1
                  ? "🏠 Ana Menü"
                  : aktifIndex == 2
                      ? "📖 Günlük"
                      : "⚙️ Ayarlar",
          style: const TextStyle(fontSize: 22, color: Colors.black87),
        ),
      ),
      bottomNavigationBar: CustomPaint(
        painter: SmoothBarPainter(
          activeX: _activeButtonX,
          screenWidth: width,
          time: _time, // 💥 animasyon zamanı
        ),
        child: Container(
          height: 90,
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(Icons.event_note, "Planlı", 0),
              _buildButton(Icons.home, "Ana Menü", 1),
              _buildButton(Icons.book, "Günlük", 2),
            ],
          ),
        ),
      ),
    );
  }
}

class SmoothBarPainter extends CustomPainter {
  final double activeX;
  final double screenWidth;
  final double time;

  SmoothBarPainter({
    required this.activeX,
    required this.screenWidth,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = activeX == 0 ? screenWidth / 2 : activeX;
    const double curveWidth = 90;
    const double curveHeight = 32;

    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(centerX - curveWidth / 2, 0);
    path.cubicTo(
      centerX - curveWidth * 0.25, 0,
      centerX - curveWidth * 0.15, -curveHeight,
      centerX, -curveHeight,
    );
    path.cubicTo(
      centerX + curveWidth * 0.15, -curveHeight,
      centerX + curveWidth * 0.25, 0,
      centerX + curveWidth / 2, 0,
    );
    path.lineTo(screenWidth, 0);
    path.lineTo(screenWidth, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Blur (cam efekti)
    final Paint blurPaint = Paint()
      ..imageFilter = ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18)
      ..color = Colors.white.withValues(alpha: 0.25);
    canvas.saveLayer(
        Rect.fromLTWH(0, -curveHeight, screenWidth, size.height + curveHeight),
        Paint());
    canvas.drawPath(path, blurPaint);

    // Hafif pembe ton
    final Paint pinkLight = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFC9E1), Color(0xFFFFE6F1)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, screenWidth, size.height))
      ..blendMode = BlendMode.softLight;
    canvas.drawPath(path, pinkLight);

    // Yansıma parıltısı (tam buton altı)
    final Rect highlightRect = Rect.fromCenter(
      center: Offset(centerX, -curveHeight / 2.5),
      width: curveWidth * 1.5,
      height: 50,
    );
    final Paint highlightPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(highlightRect)
      ..blendMode = BlendMode.overlay;
    canvas.drawPath(path, highlightPaint);

    // Kayan ışık efekti (her frame)
    final double t = (time % 4000) / 4000;
    final double shineX = screenWidth * t;

    final Rect movingLight = Rect.fromLTWH(shineX - 60, -curveHeight, 120, 50);
    final Paint movingPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.6),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(movingLight)
      ..blendMode = BlendMode.plus;
    canvas.drawPath(path, movingPaint);

    // Hafif gölge
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.12), 5, true);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SmoothBarPainter oldDelegate) {
    return oldDelegate.activeX != activeX || oldDelegate.time != time;
  }
}
