
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(RunaMatrixApp());

class RunaMatrixApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Runa Matrix',
      theme: ThemeData.dark(),
      home: MatrixScreen(),
    );
  }
}

class MatrixScreen extends StatefulWidget {
  @override
  _MatrixScreenState createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<RuneSymbol> symbols = [];
  Random random = Random();
  Timer? _timer;
  bool _isStarted = false;  // To track if the animation has started

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initSymbols();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _initSymbols() {
    for (int i = 0; i < 150; i++) {
      symbols.add(RuneSymbol(
        random.nextDouble() * MediaQuery.of(context).size.width,
        random.nextDouble() * MediaQuery.of(context).size.height,
        random.nextDouble() * 0.5 - 0.25,
        random.nextDouble() * 0.5 - 0.25,
        _generateRandomColor(),
      ));
    }
  }

  Color _generateRandomColor() {
    List<Color> gradientColors = [
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.orange,
    ];
    return gradientColors[random.nextInt(gradientColors.length)];
  }

  void _updateSymbols() {
    setState(() {
      for (var symbol in symbols) {
        symbol.x += symbol.dx;
        symbol.y += symbol.dy;

        if (symbol.x < 0) symbol.x = MediaQuery.of(context).size.width;
        if (symbol.x > MediaQuery.of(context).size.width) symbol.x = 0;
        if (symbol.y < 0) symbol.y = MediaQuery.of(context).size.height;
        if (symbol.y > MediaQuery.of(context).size.height) symbol.y = 0;
      }
    });
  }

  Future<void> _startAudioAndAnimation() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('1.mp3'));

    setState(() {
      _isStarted = true;  // Hide the message after starting
    });

    _timer = Timer.periodic(Duration(milliseconds: 1000 ~/ 60), (Timer t) {
      _updateSymbols();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _startAudioAndAnimation,
        child: Container(
          color: Colors.black,
          child: CustomPaint(
            painter: RunaPainter(symbols),
            child: !_isStarted  // Show message only before animation starts
                ? Center(
                    child: Text(
                      'Tap to start the matrix',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class RunaPainter extends CustomPainter {
  final List<RuneSymbol> symbols;
  final random = Random();

  RunaPainter(this.symbols);

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(fontSize: 20);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var symbol in symbols) {
      final textSpan = TextSpan(
          text: String.fromCharCode(symbol.runeCode),
          style: textStyle.copyWith(color: symbol.color));
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, Offset(symbol.x, symbol.y));
    }

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < symbols.length - 1; i++) {
      canvas.drawLine(
        Offset(symbols[i].x, symbols[i].y),
        Offset(symbols[i + 1].x, symbols[i + 1].y),
        paint,
      );
    }

    _drawBinaryBackground(canvas, size);
  }

  void _drawBinaryBackground(Canvas canvas, Size size) {
    final binaryTextStyle = TextStyle(color: Colors.white.withOpacity(0.05), fontSize: 12);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (double i = 0; i < size.width; i += 20) {
      for (double j = 0; j < size.height; j += 20) {
        final textSpan = TextSpan(
            text: random.nextBool() ? '1' : '0',
            style: binaryTextStyle);
        textPainter.text = textSpan;
        textPainter.layout();
        textPainter.paint(canvas, Offset(i, j));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class RuneSymbol {
  double x, y;
  double dx, dy;
  Color color;
  int runeCode;

  RuneSymbol(this.x, this.y, this.dx, this.dy, this.color)
      : runeCode = 0x16A0 + Random().nextInt(96);
}
