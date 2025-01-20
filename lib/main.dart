import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Configure window properties
  await windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.setSize(const Size(1920, 1080)); // Adjust to your screen resolution
    await windowManager.setPosition(Offset.zero);
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setHasShadow(false);
    await windowManager.show();
  });

  runApp(const LaserPointerApp());
}

class LaserPointerApp extends StatelessWidget {
  const LaserPointerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laser Pointer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const PointerOverlay(),
    );
  }
}

class PointerOverlay extends StatefulWidget {
  const PointerOverlay({super.key});

  @override
  State<PointerOverlay> createState() => _PointerOverlayState();
}

class _PointerOverlayState extends State<PointerOverlay> {
  Offset _pointerPosition = Offset.zero;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_handleKeyPress);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyPress);
    super.dispose();
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      setState(() {
        _isVisible = !_isVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MouseRegion(
        onHover: (event) {
          setState(() {
            _pointerPosition = event.position;
          });
        },
        child: Stack(
          children: [
            if (_isVisible)
              Positioned(
                left: _pointerPosition.dx - 10,
                top: _pointerPosition.dy - 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2196F3).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            // Small hint text
            Positioned(
              top: 10,
              right: 10,
              child: Text(
                'Press ESC to ${_isVisible ? 'hide' : 'show'} pointer',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
