import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'package:vokabeltrainer_app/core/latlon.dart';

class GermanyMapWithProgress extends StatefulWidget {
  final List<LatLon> stations;
  final int completedLevels; // wie viele Level wurden vollendet (alle bis einschließlich completedLevels-1)
  final int nextLevel; // das nächste anstehende Level (0-basiert)
  final String assetPath;
  final double markerDiameter;
  final double latMax;
  final double latMin;
  final double lonMin;
  final double lonMax;

  const GermanyMapWithProgress({
    Key? key,
    required this.stations,
    required this.completedLevels,
    required this.nextLevel,
    required this.assetPath,
    this.markerDiameter = 20,
    this.latMax = 55.05,
    this.latMin = 47.27,
    this.lonMin = 5.87,
    this.lonMax = 15.04,
  }) : super(key: key);

  @override
  State<GermanyMapWithProgress> createState() => _GermanyMapWithProgressState();
}

class _GermanyMapWithProgressState extends State<GermanyMapWithProgress> {
  ui.Image? _mapImage;

  @override
  void initState() {
    super.initState();
    _loadMapImage();
  }

  Future<void> _loadMapImage() async {
    final data = await rootBundle.load(widget.assetPath);
    final bytes = data.buffer.asUint8List();
    final image = await decodeImageFromList(bytes);
    setState(() {
      _mapImage = image;
    });
  }

  Offset _project(LatLon p, double width, double height) {
    final x = (p.lon - widget.lonMin) / (widget.lonMax - widget.lonMin) * width;
    final y = (widget.latMax - p.lat) / (widget.latMax - widget.latMin) * height;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    if (_mapImage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth * 0.9 / _mapImage!.width;
    final imgWidth = _mapImage!.width * scale;
    final imgHeight = _mapImage!.height * scale;

    // Alle Stationen umrechnen
    final positions = widget.stations
        .map((s) => _project(s, imgWidth, imgHeight))
        .toList();

    return Center(
      child: SizedBox(
        width: imgWidth,
        height: imgHeight,
        child: Stack(
          children: [
            // Die Karten-PNG
            Image.asset(
              widget.assetPath,
              width: imgWidth,
              height: imgHeight,
              fit: BoxFit.contain,
            ),
            // Die Linie ("Autobahn") zwischen allen bisherigen Stationen und bis zum nächsten Level
            Positioned.fill(
              child: CustomPaint(
                painter: _ProgressLinePainter(
                  positions: positions,
                  completedLevels: widget.completedLevels,
                  nextLevel: widget.nextLevel,
                ),
              ),
            ),
            // Punkte (Marker)
            ...List.generate(widget.stations.length, (i) {
              final pos = positions[i];
              Color color;
              if (i < widget.completedLevels) {
                color = Colors.green;
              } else if (i == widget.nextLevel) {
                color = Colors.red;
              } else {
                color = Colors.grey[400]!;
              }
              return Positioned(
                left: pos.dx - widget.markerDiameter / 2,
                top: pos.dy - widget.markerDiameter / 2,
                child: Container(
                  width: widget.markerDiameter,
                  height: widget.markerDiameter,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black54,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Die Autobahn-ähnliche Linie als CustomPainter
class _ProgressLinePainter extends CustomPainter {
  final List<Offset> positions;
  final int completedLevels;
  final int nextLevel;

  _ProgressLinePainter({
    required this.positions,
    required this.completedLevels,
    required this.nextLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    // Linie für abgeschlossene Levels (grün)
    final autobahn = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    // Weißer Mittelstrich für Autobahn-Look
    final whiteLine = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Strecke alle Verbindungen bis zum nächsten Level
    for (int i = 0; i < nextLevel; i++) {
      if (i + 1 < positions.length) {
        canvas.drawLine(positions[i], positions[i + 1], autobahn);
        canvas.drawLine(positions[i], positions[i + 1], whiteLine);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
