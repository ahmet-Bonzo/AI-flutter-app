import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';

// ========================== TEMA YÖNETİMİ ==========================
enum AppTheme { pink, blue, grey }

class ThemeManager {
  static const String _themeKey = 'selected_theme';

  static Future<AppTheme> getCurrentTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    return AppTheme.values[themeIndex];
  }

  static Future<void> setTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }

  static ThemeData getThemeData(AppTheme theme) {
    switch (theme) {
      case AppTheme.pink:
        return _pinkTheme;
      case AppTheme.blue:
        return _blueTheme;
      case AppTheme.grey:
        return _greyTheme;
    }
  }

  static ThemeData get _pinkTheme => ThemeData(
    primaryColor: Colors.pinkAccent,
    scaffoldBackgroundColor: const Color(0xFFFFE4EC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.pinkAccent,
      secondary: Colors.pinkAccent,
      surface: Color(0xFFFFE4EC),
    ),
  );

  static ThemeData get _blueTheme => ThemeData(
    primaryColor: Colors.blueAccent,
    scaffoldBackgroundColor: const Color(0xFFE3F2FD),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.blueAccent,
      secondary: Colors.blueAccent,
      surface: Color(0xFFE3F2FD),
    ),
  );

  static ThemeData get _greyTheme => ThemeData(
    primaryColor: Colors.grey.shade600,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    colorScheme: ColorScheme.light(
      primary: Colors.grey.shade600,
      secondary: Colors.grey.shade600,
      surface: const Color(0xFFF5F5F5),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.pink;

  AppTheme get currentTheme => _currentTheme;

  ThemeData get themeData => ThemeManager.getThemeData(_currentTheme);

  Color get primaryColor {
    switch (_currentTheme) {
      case AppTheme.pink:
        return Colors.pinkAccent;
      case AppTheme.blue:
        return Colors.blueAccent;
      case AppTheme.grey:
        return Colors.grey.shade600;
    }
  }

  Color get backgroundColor {
    switch (_currentTheme) {
      case AppTheme.pink:
        return const Color(0xFFFFE4EC);
      case AppTheme.blue:
        return const Color(0xFFE3F2FD);
      case AppTheme.grey:
        return const Color(0xFFF5F5F5);
    }
  }

  Color get cardColor {
    switch (_currentTheme) {
      case AppTheme.pink:
        return const Color(0xFFFFF1F6);
      case AppTheme.blue:
        return const Color(0xFFF0F8FF);
      case AppTheme.grey:
        return Colors.white;
    }
  }

  Color get gradientStartColor {
    switch (_currentTheme) {
      case AppTheme.pink:
        return const Color(0xFFFFE6EE);
      case AppTheme.blue:
        return const Color(0xFFE8F4FD);
      case AppTheme.grey:
        return const Color(0xFFF8F8F8);
    }
  }

  Color get gradientEndColor {
    switch (_currentTheme) {
      case AppTheme.pink:
        return const Color(0xFFFFF9FC);
      case AppTheme.blue:
        return const Color(0xFFF0F8FF);
      case AppTheme.grey:
        return const Color(0xFFF0F0F0);
    }
  }

  Color get bottomBarGradientStart {
    switch (_currentTheme) {
      case AppTheme.pink:
        return const Color(0xFFFFD1E8);
      case AppTheme.blue:
        return const Color(0xFFB3E5FC);
      case AppTheme.grey:
        return const Color(0xFFE0E0E0);
    }
  }

  Color get bottomBarGradientMiddle {
    switch (_currentTheme) {
      case AppTheme.pink:
        return const Color(0xFFFFE9F3);
      case AppTheme.blue:
        return const Color(0xFFE1F5FE);
      case AppTheme.grey:
        return const Color(0xFFF0F0F0);
    }
  }

  Color get bottomBarGradientEnd {
    switch (_currentTheme) {
      case AppTheme.pink:
        return const Color(0xFFFFF5F9);
      case AppTheme.blue:
        return const Color(0xFFF0F8FF);
      case AppTheme.grey:
        return const Color(0xFFF8F8F8);
    }
  }

  Future<void> loadTheme() async {
    _currentTheme = await ThemeManager.getCurrentTheme();
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    await ThemeManager.setTheme(theme);
    notifyListeners();
  }
}

void main() => runApp(const KralApp());

class KralApp extends StatelessWidget {
  const KralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider()..loadTheme(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const AnaMenu(),
          );
        },
      ),
    );
  }
}

// ========================== ANA MENÜ ==========================
class AnaMenu extends StatefulWidget {
  const AnaMenu({super.key});

  @override
  State<AnaMenu> createState() => _AnaMenuState();
}

class _AnaMenuState extends State<AnaMenu>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _aktifIndex = 2; // 0 = Planlar
  double _activeButtonX = 0.0;
  final List<GlobalKey> _buttonKeys = List.generate(5, (_) => GlobalKey());
  late final AnimationController _animController;
  String _kullaniciAdi = "Kullanıcı";
  static const String _nameKey = 'kullanici_adi';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateButtonPosition(_aktifIndex);
    });

    _loadUserName();

    // Her 2 saniyede bir kullanıcı adını kontrol et
    _startNameCheckTimer();

    // Her dakika tarih kontrolü yap
    _startDateCheckTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserName();
    }
  }

  void _startDateCheckTimer() {
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        _loadUserName();
        _startDateCheckTimer();
      }
    });
  }

  void _startNameCheckTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _loadUserName();
        _startNameCheckTimer();
      }
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedName = prefs.getString(_nameKey);
    if (savedName != null && savedName.isNotEmpty) {
      setState(() {
        _kullaniciAdi = savedName;
      });
    }
  }

  void _updateButtonPosition(int index) {
    final key = _buttonKeys[index];
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      final offset = renderBox.localToGlobal(ui.Offset.zero);
      setState(() {
        _activeButtonX = offset.dx + renderBox.size.width / 2;
      });
    }
  }

  void _setActiveButton(int index) {
    if (_aktifIndex == index) {
      return; // Aynı butona tekrar tıklanırsa hiçbir şey yapma
    }

    setState(() {
      _aktifIndex = index;
    });

    // Buton pozisyonunu güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateButtonPosition(index);
      }
    });
  }

  Widget _buildButton(IconData icon, String text, int index) {
    final bool aktif = _aktifIndex == index;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return SizedBox(
      width: 60,
      child: GestureDetector(
        key: _buttonKeys[index],
        onTap: () => _setActiveButton(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: aktif ? themeProvider.primaryColor : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: aktif
                    ? [
                        BoxShadow(
                          color: themeProvider.primaryColor.withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 12.0,
                          spreadRadius: 2.0,
                          offset: ui.Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: aktif ? Colors.white : Colors.grey.shade600,
                size: aktif ? 28.0 : 26.0,
              ),
            ),
            const SizedBox(height: 5.0),
            Text(
              text,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: aktif ? FontWeight.w600 : FontWeight.normal,
                color: aktif ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0.0),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: _aktifIndex == 0
            ? const PlanliSayfa(key: ValueKey('planli'))
            : _aktifIndex == 1
            ? const GunlukSayfa(key: ValueKey('gunluk'))
            : _aktifIndex == 2
            ? const SansKurabiyesiSayfa(key: ValueKey('sans'))
            : _aktifIndex == 3
            ? const ManifestSayfa(key: ValueKey('manifest'))
            : const KullaniciSayfa(key: ValueKey('kullanici')),
      ),
      bottomNavigationBar: Container(
        height: 90.0,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(color: Colors.transparent),
        child: OverflowBox(
          maxHeight: 90.0,
          child: AltBar(
            controller: _animController,
            activeButtonX: _activeButtonX,
            width: width,
            buildButton: _buildButton,
            kullaniciAdi: _kullaniciAdi,
          ),
        ),
      ),
    );
  }
}

// ========================== ALT BAR ==========================
class AltBar extends StatelessWidget {
  final AnimationController controller;
  final double activeButtonX;
  final double width;
  final Widget Function(IconData, String, int) buildButton;
  final String kullaniciAdi;

  const AltBar({
    super.key,
    required this.controller,
    required this.activeButtonX,
    required this.width,
    required this.buildButton,
    required this.kullaniciAdi,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final time = controller.value * 8000.0;
        return CustomPaint(
          painter: GelismisBarPainter(
            activeX: activeButtonX,
            screenWidth: width,
            time: time,
            themeProvider: themeProvider,
          ),
          child: child,
        );
      },
      child: Container(
        height: 90.0,
        padding: const EdgeInsets.only(top: 10.0),
        child: OverflowBox(
          maxWidth: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildButton(Icons.event_note, "Planlar", 0),
              buildButton(Icons.book, "Günlük", 1),
              buildButton(
                Icons.cookie,
                "Şans",
                2,
              ), // eski sürümlerde Icons.cookie yoksa: Icons.emoji_food_beverage
              buildButton(Icons.auto_awesome, "Manifest", 3),
              buildButton(Icons.person, kullaniciAdi, 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================== GELİŞMİŞ BAR PAINTER ==========================
class GelismisBarPainter extends CustomPainter {
  final double activeX;
  final double screenWidth;
  final double time;
  final ThemeProvider themeProvider;

  GelismisBarPainter({
    required this.activeX,
    required this.screenWidth,
    required this.time,
    required this.themeProvider,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = (activeX == 0.0 ? screenWidth / 2.0 : activeX).clamp(
      0.0,
      screenWidth,
    );
    const double curveWidth = 110.0;
    const double curveHeight = 28.0;

    // Ana yol oluştur
    final Path mainPath = _createMainPath(
      size,
      centerX,
      curveWidth,
      curveHeight,
    );

    // Arka plan blur efekti
    _drawBlurredBackground(canvas, mainPath, size, curveHeight);

    // Ana gradient
    _drawMainGradient(canvas, mainPath, size);

    // Işık efektleri
    _drawLightEffects(canvas, mainPath, centerX, curveWidth, curveHeight);

    // Hareketli dalga animasyonu
    _drawWaveAnimation(canvas, mainPath, size, curveHeight);

    // Işıltı efekti
    _drawSparkleEffect(canvas, mainPath, centerX, curveWidth, curveHeight);

    // Gölge
    canvas.drawShadow(
      mainPath,
      Colors.black.withValues(alpha: 0.15),
      6.0,
      true,
    );
  }

  Path _createMainPath(
    Size size,
    double centerX,
    double curveWidth,
    double curveHeight,
  ) {
    return Path()
      ..moveTo(0.0, 0.0)
      ..lineTo(centerX - curveWidth / 2.0, 0.0)
      ..cubicTo(
        centerX - curveWidth * 0.25,
        0.0,
        centerX - curveWidth * 0.15,
        -curveHeight,
        centerX,
        -curveHeight,
      )
      ..cubicTo(
        centerX + curveWidth * 0.15,
        -curveHeight,
        centerX + curveWidth * 0.25,
        0.0,
        centerX + curveWidth / 2.0,
        0.0,
      )
      ..lineTo(screenWidth, 0.0)
      ..lineTo(screenWidth, size.height)
      ..lineTo(0.0, size.height)
      ..close();
  }

  void _drawBlurredBackground(
    Canvas canvas,
    Path path,
    Size size,
    double curveHeight,
  ) {
    final Paint blurPaint = Paint()
      ..imageFilter = ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0)
      ..color = Colors.white.withValues(alpha: 0.3);

    canvas.saveLayer(
      ui.Rect.fromLTWH(
        0.0,
        -curveHeight,
        screenWidth,
        size.height + curveHeight,
      ),
      Paint(),
    );
    canvas.drawPath(path, blurPaint);
    canvas.restore();
  }

  void _drawMainGradient(Canvas canvas, Path path, Size size) {
    final Paint mainGradient = Paint()
      ..shader = LinearGradient(
        colors: [
          themeProvider.bottomBarGradientStart,
          themeProvider.bottomBarGradientMiddle,
          themeProvider.bottomBarGradientEnd,
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0.0, 0.0, screenWidth, size.height));
    canvas.drawPath(path, mainGradient);
  }

  void _drawLightEffects(
    Canvas canvas,
    Path path,
    double centerX,
    double curveWidth,
    double curveHeight,
  ) {
    final ui.Rect highlightRect = Rect.fromCenter(
      center: Offset(centerX, -curveHeight / 2.0),
      width: curveWidth * 1.8,
      height: 55.0,
    );
    final Paint highlightPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(highlightRect)
      ..blendMode = BlendMode.overlay;
    canvas.drawPath(path, highlightPaint);
  }

  void _drawWaveAnimation(
    Canvas canvas,
    Path path,
    Size size,
    double curveHeight,
  ) {
    final double t = (time % 8000.0) / 8000.0;

    for (int wave = 0; wave < 3; wave++) {
      final double waveOffset = (t + wave * 0.33) % 1.0;
      final double waveX = screenWidth * waveOffset;
      final double waveWidth = 180.0 + (wave * 30.0);
      final double waveAlpha = 0.4 - (wave * 0.1);

      final double waveHeight =
          size.height + (math.sin(t * math.pi * 4 + wave) * 8);

      final ui.Rect waveRect = Rect.fromLTWH(
        waveX - waveWidth / 2,
        -curveHeight,
        waveWidth,
        waveHeight,
      );

      final Paint wavePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: waveAlpha),
            Colors.white.withValues(alpha: waveAlpha * 0.5),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.6, 1.0],
          center: Alignment.topCenter,
        ).createShader(waveRect)
        ..blendMode = BlendMode.plus;

      canvas.drawPath(path, wavePaint);
    }
  }

  void _drawSparkleEffect(
    Canvas canvas,
    Path path,
    double centerX,
    double curveWidth,
    double curveHeight,
  ) {
    final double sparkleT = (time % 2000.0) / 2000.0;
    final double sparkleX =
        centerX + (math.sin(sparkleT * math.pi * 2) * curveWidth * 0.3);

    final Rect sparkleRect = Rect.fromCenter(
      center: ui.Offset(sparkleX, -curveHeight * 0.7),
      width: 80.0,
      height: 80.0,
    );

    final Paint sparklePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.7 * math.sin(sparkleT * math.pi)),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(sparkleRect)
      ..blendMode = BlendMode.screen;

    canvas.drawCircle(Offset(sparkleX, -curveHeight * 0.7), 40.0, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant GelismisBarPainter oldDelegate) {
    return oldDelegate.activeX != activeX || oldDelegate.time != time;
  }
}

// ========================== PLANLI SAYFASI ==========================
class PlanliSayfa extends StatefulWidget {
  const PlanliSayfa({super.key});

  @override
  State<PlanliSayfa> createState() => _PlanliSayfaState();
}

class _PlanliSayfaState extends State<PlanliSayfa>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _tasks = [];
  late AnimationController _animController;
  final Set<int> _acikKartlar = {};

  static const String _storageKey = 'gorev_listesi';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadTasks();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString(_storageKey);
    if (jsonData != null) {
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(jsonDecode(jsonData));
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonData = jsonEncode(_tasks);
    await prefs.setString(_storageKey, jsonData);
  }

  void _gorevEkle(String baslik, String aciklama) {
    if (baslik.isEmpty) return;

    setState(() {
      _tasks.add({
        'title': baslik,
        'desc': aciklama,
        'done': false,
        'star': false,
      });
    });
    _saveTasks();
    _animController.forward(from: 0.0);
  }

  void _gorevSil(int index) {
    setState(() {
      _tasks.removeAt(index);
      _acikKartlar.remove(index);
    });
    _saveTasks();
  }

  void _gorevDurumDegistir(int index, bool? value) {
    setState(() {
      _tasks[index]['done'] = value ?? false;
    });
    _saveTasks();
  }

  void _gorevYildizDegistir(int index) {
    setState(() {
      _tasks[index]['star'] = !_tasks[index]['star'];
      _tasks.sort(
        (a, b) =>
            (b['star'] as bool ? 1 : 0).compareTo(a['star'] as bool ? 1 : 0),
      );
    });
    _saveTasks();
  }

  void _gorevEkleDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final TextEditingController baslikCtrl = TextEditingController();
    final TextEditingController aciklamaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: themeProvider.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Yeni Görev Ekle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: baslikCtrl,
                  decoration: const InputDecoration(
                    hintText: "Görev başlığı yaz...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: aciklamaCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Açıklama (isteğe bağlı)...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () {
                _gorevEkle(baslikCtrl.text.trim(), aciklamaCtrl.text.trim());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
              ),
              child: const Text("Ekle", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeProvider.gradientStartColor,
            themeProvider.gradientEndColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _tasks.isEmpty
            ? const Center(
                child: Text(
                  "Henüz bir görev eklenmedi 📝",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _tasks.length,
                itemBuilder: (context, index) => _buildTaskCard(index),
              ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: themeProvider.primaryColor,
          onPressed: () => _gorevEkleDialog(context),
          icon: const Icon(Icons.add),
          label: const Text("Yeni Görev"),
        ),
      ),
    );
  }

  Widget _buildTaskCard(int index) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final gorev = _tasks[index];
    final bool acik = _acikKartlar.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          acik ? _acikKartlar.remove(index) : _acikKartlar.add(index);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: themeProvider.primaryColor.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  shape: const CircleBorder(),
                  activeColor: themeProvider.primaryColor,
                  value: gorev['done'],
                  onChanged: (val) => _gorevDurumDegistir(index, val),
                ),
                Expanded(
                  child: Text(
                    gorev['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: gorev['done']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: gorev['done']
                          ? Colors.grey.shade500
                          : Colors.black87,
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => _gorevYildizDegistir(index),
                  child: Icon(
                    gorev['star']
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: gorev['star'] ? Colors.amber : Colors.grey.shade400,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: themeProvider.primaryColor,
                  ),
                  onPressed: () => _gorevSil(index),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(
                  left: 50,
                  right: 8,
                  top: 4,
                  bottom: 8,
                ),
                child: Text(
                  gorev['desc'].isEmpty
                      ? "Açıklama eklenmemiş."
                      : gorev['desc'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              crossFadeState: acik
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }
}

// ========================== ANA SAYFA ==========================
class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.home, size: 80, color: Colors.pinkAccent),
        SizedBox(height: 16),
        Text("Hoş geldin 👋", style: TextStyle(fontSize: 22)),
      ],
    );
  }
}

// ========================== GÜNLÜK SAYFASI ==========================
// ========================== GÜNLÜK SAYFASI (ANA TAKVİM) ==========================
class GunlukSayfa extends StatefulWidget {
  const GunlukSayfa({super.key});

  @override
  State<GunlukSayfa> createState() => _GunlukSayfaState();
}

class _GunlukSayfaState extends State<GunlukSayfa> with WidgetsBindingObserver {
  DateTime _aktifAy = DateTime.now();
  DateTime _aktifGun = DateTime.now();
  Map<String, String> _gunlukGirisleri = {};
  static const String _storageKey = 'gunluk_kayitlari';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadEntries();
    _updateToCurrentDate();
    _startAutoUpdateTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateToCurrentDate();
    }
  }

  void _updateToCurrentDate() {
    final now = DateTime.now();
    setState(() {
      _aktifAy = DateTime(now.year, now.month, 1);
      _aktifGun = now;
    });
  }

  void _startAutoUpdateTimer() {
    // Her dakika kontrol et
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        _updateToCurrentDate();
        _startAutoUpdateTimer();
      }
    });
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString(_storageKey);
    if (jsonData != null) {
      setState(() {
        _gunlukGirisleri = Map<String, String>.from(jsonDecode(jsonData));
      });
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonData = jsonEncode(_gunlukGirisleri);
    await prefs.setString(_storageKey, jsonData);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ================= Yeni Ay Geçiş Fonksiyonları =================
  void _ayDegistir(int ayFarki) {
    setState(() {
      _aktifAy = DateTime(_aktifAy.year, _aktifAy.month + ayFarki, 1);

      final int sonGun = DateTime(_aktifAy.year, _aktifAy.month + 1, 0).day;

      _aktifGun = DateTime(
        _aktifAy.year,
        _aktifAy.month,
        // Aktif günü yeni ayın geçerli bir gününe ayarla
        _aktifGun.day.clamp(1, sonGun),
      );
    });
  }

  // ================= Günlük Kayıt Bottom Sheet'e Geçiş =================
  void _gunlukKayitSayfasinaGit(DateTime date) async {
    final DateTime bugun = DateTime.now();
    final DateTime sadeceTarihBugun = DateTime(
      bugun.year,
      bugun.month,
      bugun.day,
    );
    final DateTime sadeceTarihSecilen = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final bool duzenlenebilir = !sadeceTarihSecilen.isBefore(sadeceTarihBugun);

    // Geçmiş bir günse, sadece uyarı göster ve modal açma!
    if (!duzenlenebilir && sadeceTarihSecilen.isBefore(sadeceTarihBugun)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${sadeceTarihSecilen.day}.${sadeceTarihSecilen.month}.${sadeceTarihSecilen.year} gününün kaydı dondurulmuştur. Sadece okunabilir.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final String key = _formatDate(date);
    final String? mevcutGiris = _gunlukGirisleri[key];

    // Bottom Sheet'i göster (Sadece düzenlenebilir günlerde açılır)
    final String? yeniGiris = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true, // Klavye açıldığında yukarı kaymasını sağlar
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GunlukKayitSheet(
          tarih: date,
          mevcutMetin: mevcutGiris ?? '',
          duzenlenebilir: duzenlenebilir,
        );
      },
    );

    // Geri dönüldüğünde kaydet
    if (yeniGiris != null) {
      setState(() {
        if (yeniGiris.trim().isEmpty) {
          _gunlukGirisleri.remove(key);
        } else {
          _gunlukGirisleri[key] = yeniGiris;
        }
        _aktifGun = date;
      });
      _saveEntries();
    }
  }

  // ================= Takvim Yardımcı Fonksiyonları =================
  List<DateTime> _aydakiGunleriGetir(DateTime ay) {
    final DateTime ilkGun = DateTime(ay.year, ay.month, 1);
    final DateTime sonrakiAyIlkGun = DateTime(ay.year, ay.month + 1, 1);
    final int gunSayisi = sonrakiAyIlkGun.difference(ilkGun).inDays;

    return List.generate(gunSayisi, (i) => ilkGun.add(Duration(days: i)));
  }

  Color _getCurrentDayColor(ThemeProvider themeProvider) {
    switch (themeProvider.currentTheme) {
      case AppTheme.pink:
        return Colors.pink.shade800; // Pembe temasının koyu rengi
      case AppTheme.blue:
        return Colors.blue.shade800; // Mavi temasının koyu rengi (lacivert)
      case AppTheme.grey:
        return Colors.grey.shade800; // Gri temasının koyu rengi (siyah)
    }
  }

  // ================= Takvim Widget'ı (KOMPAKT) =================
  Widget _buildCalendar(List<DateTime> gunler) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    int ilkGunHaftaninGunu = gunler.first.weekday;
    int boslukSayisi = ilkGunHaftaninGunu % 7;
    if (ilkGunHaftaninGunu == 7) {
      boslukSayisi = 0;
    }

    final List<String> gunIsimleri = [
      "Paz",
      "Pzt",
      "Sal",
      "Çar",
      "Per",
      "Cum",
      "Cmt",
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Haftanın Günleri Başlıkları
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: gunIsimleri
                .map(
                  (g) => SizedBox(
                    width: 30,
                    child: Text(
                      g,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Divider(
          color: themeProvider.primaryColor,
          indent: 10,
          endIndent: 10,
          height: 10,
          thickness: 1,
        ),
        // Takvim Grid'i
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
            ),
            itemCount: gunler.length + boslukSayisi,
            itemBuilder: (context, index) {
              if (index < boslukSayisi) {
                return const SizedBox.shrink();
              }

              final gunIndex = index - boslukSayisi;
              final gun = gunler[gunIndex];
              final String key = _formatDate(gun);
              final bool kayitVar = _gunlukGirisleri.containsKey(key);
              final bool secili =
                  gun.day == _aktifGun.day &&
                  gun.month == _aktifGun.month &&
                  gun.year == _aktifGun.year;

              return GestureDetector(
                onTap: () {
                  setState(() => _aktifGun = gun);
                  _gunlukKayitSayfasinaGit(gun);
                },
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      // .withValues kullanıldı
                      color: secili
                          ? themeProvider.primaryColor.withValues(alpha: 0.9)
                          : (kayitVar
                                ? themeProvider.primaryColor.withValues(
                                    alpha: 0.2,
                                  )
                                : Colors.transparent),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            DateTime.now().day == gun.day &&
                                DateTime.now().month == gun.month &&
                                DateTime.now().year == gun.year
                            ? _getCurrentDayColor(themeProvider)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      gun.day.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: secili ? Colors.white : Colors.black87,
                        fontWeight: secili
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final gunler = _aydakiGunleriGetir(_aktifAy);
    final String aktifGunKey = _formatDate(_aktifGun);
    final String aktifGunMetni = _gunlukGirisleri[aktifGunKey] ?? "";
    final bool kayitVar = _gunlukGirisleri.containsKey(aktifGunKey);

    // Düzenlenebilirlik Kontrolü
    final DateTime bugun = DateTime.now();
    final DateTime sadeceTarihBugun = DateTime(
      bugun.year,
      bugun.month,
      bugun.day,
    );
    final DateTime sadeceTarihSecilen = DateTime(
      _aktifGun.year,
      _aktifGun.month,
      _aktifGun.day,
    );
    final bool duzenlenebilir = !sadeceTarihSecilen.isBefore(sadeceTarihBugun);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        automaticallyImplyLeading: false,

        // SOL KISIM: GERİ BUTONU ve ARŞİV
        title: Row(
          children: [
            // ÖNCEKİ AY BUTONU
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: themeProvider.primaryColor,
                size: 20,
              ),
              onPressed: () => _ayDegistir(-1),
            ),
            // ARŞİV BUTONU
            InkWell(
              onTap: () async {
                final DateTime? secilenAy = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TumAylarSayfasi(),
                  ),
                );
                if (secilenAy != null) {
                  setState(() {
                    _aktifAy = secilenAy;
                    // Yeni aya geçince aktif günü o ayın ilk gününe ayarla
                    _aktifGun = DateTime(secilenAy.year, secilenAy.month, 1);
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  // .withValues kullanıldı
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.archive_outlined,
                      size: 20,
                      color: themeProvider.primaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Arşiv",
                      style: TextStyle(
                        color: themeProvider.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // SAĞ KISIM: AY BAŞLIĞI VE İLERİ BUTONU
        actions: [
          Text(
            '${_aktifAy.month} / ${_aktifAy.year}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.primaryColor,
            ),
          ),
          // SONRAKİ AY BUTONU
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: themeProvider.primaryColor,
              size: 20,
            ),
            onPressed: () => _ayDegistir(1),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildCalendar(gunler),

            const Divider(height: 30, thickness: 1, indent: 16, endIndent: 16),

            // Seçili Günün Girişi Önizlemesi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Seçili Gün: ${_aktifGun.day}.${_aktifGun.month}.${_aktifGun.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _gunlukKayitSayfasinaGit(_aktifGun),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // .withValues kullanıldı
                  color: kayitVar
                      ? Colors.white
                      : themeProvider.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      // .withValues kullanıldı
                      color: themeProvider.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kayitVar
                          ? aktifGunMetni
                          : "Bu gün için henüz bir kayıt yok. Tıklayarak başlayabilirsin!",
                      maxLines: kayitVar ? 5 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: kayitVar
                            ? Colors.black87
                            : themeProvider.primaryColor,
                        fontStyle: kayitVar
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                    if (kayitVar && duzenlenebilir)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Daha fazlasını görmek için tıkla...",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ========================== GÜNLÜK KAYIT MODAL WIDGET'I (ESTETİK TASARIM) ==========================
class GunlukKayitSheet extends StatefulWidget {
  final DateTime tarih;
  final String mevcutMetin;
  final bool duzenlenebilir;

  const GunlukKayitSheet({
    super.key,
    required this.tarih,
    required this.mevcutMetin,
    required this.duzenlenebilir,
  });

  @override
  State<GunlukKayitSheet> createState() => _GunlukKayitSheetState();
}

class _GunlukKayitSheetState extends State<GunlukKayitSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.mevcutMetin);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _kaydetVeKapat() {
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        // Klavye açıldığında içeriği yukarı kaydırmak için
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            // .withValues kullanıldı
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.tarih.day}.${widget.tarih.month}.${widget.tarih.year}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryColor,
                ),
              ),
              // Kapatma butonu
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context, null),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Eğer dondurulmuşsa uyarı (Bu kısım zaten modalin açılmadığı durumda çalışmaz, ama güvenlik için duruyor)
          if (!widget.duzenlenebilir)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                // .withValues kullanıldı
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, color: Colors.redAccent, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Bu kayıt dondurulmuştur ve sadece okunabilir.",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Kayıt Alanı
          Flexible(
            // Klavye açıldığında esnekliği sağlamak için
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    // .withValues kullanıldı
                    color: themeProvider.primaryColor.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                controller: _controller,
                readOnly: !widget.duzenlenebilir,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText:
                      'Bugünün nasıl geçti? Duygularını ve düşüncelerini yaz...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontStyle: FontStyle.italic),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Kaydet Butonu (Sadece düzenlenebilir ise gösterilir)
          if (widget.duzenlenebilir)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _kaydetVeKapat,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Kaydet",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ========================== TÜM AYLAR SAYFASI (ARŞİV) ==========================
class TumAylarSayfasi extends StatelessWidget {
  const TumAylarSayfasi({super.key});

  final List<String> _ayIsimleri = const [
    "Ocak",
    "Şubat",
    "Mart",
    "Nisan",
    "Mayıs",
    "Haziran",
    "Temmuz",
    "Ağustos",
    "Eylül",
    "Ekim",
    "Kasım",
    "Aralık",
  ];

  // Son 5 ayı ve şimdiki ayı (toplam 6 ay) gösterir.
  List<DateTime> _aylariGetir() {
    final now = DateTime.now();

    // 6 ay geriye doğru gitmek için 0'dan 5'e kadar (toplam 6 ay) döngü yapar
    return List.generate(6, (i) {
      return DateTime(now.year, now.month - i, 1);
    }).reversed.toList(); // En eskiden en yeniye sıralarız
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final aylar = _aylariGetir();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Günlük Arşivi',
          style: TextStyle(
            color: themeProvider.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: themeProvider.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: themeProvider.backgroundColor,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: aylar.length,
        itemBuilder: (context, index) {
          final ay = aylar[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                // Seçilen ayın ilk gününü geri gönder
                Navigator.pop(context, ay);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  // Kart görünümü
                  // .withValues kullanıldı
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      // .withValues kullanıldı
                      color: themeProvider.primaryColor.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: themeProvider.primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _ayIsimleri[ay.month - 1],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${ay.year}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: themeProvider.primaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ========================== ŞANS KURABİYESİ SAYFASI ==========================
class SansKurabiyesiSayfa extends StatefulWidget {
  const SansKurabiyesiSayfa({super.key});

  @override
  State<SansKurabiyesiSayfa> createState() => _SansKurabiyesiSayfaState();
}

class _SansKurabiyesiSayfaState extends State<SansKurabiyesiSayfa> {
  int _clickCount = 0;
  bool _cracked = false;
  String? _message;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  static const String _cookieKey = 'kurabiye_durumu';

  final List<String> _messages = [
    "Bugün senin günün 🌞",
    "Şans kapında! 🍀",
    "Harika bir fırsat seni bekliyor ✨",
    "Gülümsemek her kapıyı açar 😄",
    "Evren senin için çalışıyor 💫",
    "Küçük bir adım, büyük bir değişim getirir 🚀",
  ];

  @override
  void initState() {
    super.initState();
    _loadCookieState();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCookieState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cookieData = prefs.getString(_cookieKey);

    if (cookieData != null) {
      final Map<String, dynamic> data = jsonDecode(cookieData);
      final DateTime savedTime = DateTime.parse(data['timestamp']);
      final int savedCooldown = data['cooldown'] ?? 0;
      final bool savedCracked = data['cracked'] ?? false;
      final String? savedMessage = data['message'];

      // Telefon saatine göre geçen süreyi hesapla
      final DateTime now = DateTime.now();
      final int elapsedSeconds = now.difference(savedTime).inSeconds;
      final int remainingCooldown = (savedCooldown - elapsedSeconds).clamp(
        0,
        savedCooldown,
      );

      if (remainingCooldown > 0) {
        // Hala bekleme süresi var
        setState(() {
          _cracked = savedCracked;
          _message = savedMessage;
          _cooldownSeconds = remainingCooldown;
        });
        _resumeCooldown(); // Kalan süreyi devam ettir
      } else {
        // Bekleme süresi bitmiş, temizle
        await _clearCookieState();
        setState(() {
          _cracked = false;
          _message = null;
          _cooldownSeconds = 0;
        });
      }
    }
  }

  Future<void> _saveCookieState() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = {
      'timestamp': DateTime.now().toIso8601String(),
      'cooldown': _cooldownSeconds,
      'cracked': _cracked,
      'message': _message,
    };
    await prefs.setString(_cookieKey, jsonEncode(data));
  }

  Future<void> _clearCookieState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey);
  }

  String _formatCooldownTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int remainingSeconds = seconds % 60;

    if (hours > 0) {
      return "${hours}s ${minutes}d ${remainingSeconds}s";
    } else if (minutes > 0) {
      return "${minutes}d ${remainingSeconds}s";
    } else {
      return "${remainingSeconds}s";
    }
  }

  void _startCooldown() {
    _cooldownSeconds = 60; // 5 saat = 18000 saniye //sure değiştirme yeri
    _saveCookieState(); // Durumu kaydet
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
        _saveCookieState(); // Her saniye durumu kaydet
      } else {
        timer.cancel();
        setState(() {
          _cracked = false;
          _clickCount = 0;
          _message = null;
        });
        _clearCookieState(); // Süre bitince temizle
      }
    });
  }

  void _resumeCooldown() {
    // Mevcut timer'ı iptal et
    _cooldownTimer?.cancel();

    // Yeni timer başlat ama süreyi sıfırlama
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
        _saveCookieState(); // Her saniye durumu kaydet
      } else {
        timer.cancel();
        setState(() {
          _cracked = false;
          _clickCount = 0;
          _message = null;
        });
        _clearCookieState(); // Süre bitince temizle
      }
    });
  }

  void _handleTap() {
    if (_cracked) return; // Zaten kırılmışsa tıklama devre dışı

    setState(() {
      _clickCount++;
      if (_clickCount >= 10) {
        _cracked = true;
        _message = (_messages..shuffle()).first;
        _startCooldown(); // Bekleme süresini başlat
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: _handleTap,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: !_cracked
                  ? Column(
                      key: const ValueKey("cookie"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/sans_kurabiyesi.png',
                          width: 200,
                          height: 200,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "${10 - _clickCount} tıklama kaldı...",
                          style: TextStyle(
                            fontSize: 18,
                            color: themeProvider.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      key: const ValueKey("cracked"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/sans_kurabiyesi_catlak.png',
                          width: 200,
                          height: 200,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pinkAccent.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            _message ?? "Mesaj bulunamadı",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _cooldownSeconds > 0
                              ? null
                              : () {
                                  setState(() {
                                    _clickCount = 0;
                                    _cracked = false;
                                    _message = null;
                                  });
                                  _clearCookieState(); // Durumu temizle
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cooldownSeconds > 0
                                ? Colors.grey.shade400
                                : themeProvider.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _cooldownSeconds > 0
                                ? "Bekle... ${_formatCooldownTime(_cooldownSeconds)}"
                                : "Yeniden Dene 🔁",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class ManifestSayfa extends StatelessWidget {
  const ManifestSayfa({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 80, color: Colors.pinkAccent),
              SizedBox(height: 16),
              Text(
                "Manifestlerin burada görünecek 🌙",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KullaniciSayfa extends StatefulWidget {
  const KullaniciSayfa({super.key});

  @override
  State<KullaniciSayfa> createState() => _KullaniciSayfaState();
}

class _KullaniciSayfaState extends State<KullaniciSayfa> {
  String _kullaniciAdi = "Kullanıcı";
  static const String _nameKey = 'kullanici_adi';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedName = prefs.getString(_nameKey);
    if (savedName != null && savedName.isNotEmpty) {
      setState(() {
        _kullaniciAdi = savedName;
      });
    }
  }

  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    setState(() {
      _kullaniciAdi = name;
    });
  }

  void _showNameDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final TextEditingController nameController = TextEditingController(
      text: _kullaniciAdi,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("İsminizi Girin"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: "İsminizi yazın...",
            border: OutlineInputBorder(),
          ),
          maxLength: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                _saveUserName(newName);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("İsminiz '$newName' olarak kaydedildi"),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.primaryColor,
            ),
            child: const Text("Kaydet", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil Kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.primaryColor.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: themeProvider.primaryColor,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _kullaniciAdi,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showNameDialog,
                        child: Icon(
                          Icons.edit,
                          color: themeProvider.primaryColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Tema Seçenekleri
            Text(
              "Tema Seçenekleri",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Pembe Tema
            _buildThemeOption(
              context,
              themeProvider,
              AppTheme.pink,
              "Pembe Tema",
              "Sıcak ve romantik pembe tonları",
              const Color(0xFFFF4081),
              Icons.favorite,
            ),

            const SizedBox(height: 12),

            // Mavi Tema
            _buildThemeOption(
              context,
              themeProvider,
              AppTheme.blue,
              "Mavi Tema",
              "Sakin ve profesyonel mavi tonları",
              const Color(0xFF2196F3),
              Icons.water_drop,
            ),

            const SizedBox(height: 12),

            // Gri Tema
            _buildThemeOption(
              context,
              themeProvider,
              AppTheme.grey,
              "Gri Tema",
              "Minimalist ve şık gri tonları",
              const Color(0xFF757575),
              Icons.palette,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    AppTheme theme,
    String title,
    String description,
    Color color,
    IconData icon,
  ) {
    final bool isSelected = themeProvider.currentTheme == theme;

    return GestureDetector(
      onTap: () => themeProvider.setTheme(theme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : themeProvider.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}
