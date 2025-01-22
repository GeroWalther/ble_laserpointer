import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart';

/// Main entry point for the Laser Pointer application.
/// Initializes window properties and runs the app.
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Configure window properties for a transparent, always-on-top overlay
  await windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);  // Hide window title bar
    await windowManager.setBackgroundColor(Colors.transparent);  // Transparent background
    await windowManager.setSize(const Size(1920, 1080));  // Full HD size
    await windowManager.setPosition(Offset.zero);  // Position at screen top-left
    await windowManager.setAlwaysOnTop(true);  // Keep window on top
    await windowManager.setHasShadow(false);  // Remove window shadow
    await windowManager.show();  // Display the window
  });

  runApp(const LaserPointerApp());
}

/// Root widget of the application.
/// Sets up the MaterialApp with theme and initial route.
class LaserPointerApp extends StatelessWidget {
  const LaserPointerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laser Pointer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),  // Blue theme color
          brightness: Brightness.dark,  // Dark theme
        ),
        useMaterial3: true,
      ),
      home: const PointerOverlay(),
    );
  }
}

/// Widget that displays the laser pointer overlay.
/// Creates a transparent window with a movable pointer dot.
class PointerOverlay extends StatefulWidget {
  const PointerOverlay({super.key});

  @override
  State<PointerOverlay> createState() => _PointerOverlayState();
}

/// State class for the PointerOverlay widget.
/// Handles pointer position, visibility, and keyboard controls.
class _PointerOverlayState extends State<PointerOverlay> {
  // Current position of the pointer dot
  Offset _pointerPosition = Offset.zero;
  // Visibility toggle for the pointer dot
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    // Add keyboard event listener for ESC key
    RawKeyboard.instance.addListener(_handleKeyPress);
  }

  @override
  void dispose() {
    // Clean up keyboard listener
    RawKeyboard.instance.removeListener(_handleKeyPress);
    super.dispose();
  }

  /// Handles keyboard events.
  /// ESC key toggles pointer visibility.
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
        // Update pointer position on mouse movement
        onHover: (event) {
          setState(() {
            _pointerPosition = event.position;
          });
        },
        child: Stack(
          children: [
            // Pointer dot - only shown when _isVisible is true
            if (_isVisible)
              Positioned(
                left: _pointerPosition.dx - 10,  // Center dot on cursor
                top: _pointerPosition.dy - 10,
                child: Container(
                  width: 20,  // Dot size
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.5),  // Semi-transparent blue
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
            // Help text in top-right corner
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
