import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'package:vokabeltrainer_app/core/latlon.dart';

typedef StationTapCallback = void Function(int index);

class GermanyMapWithProgressInteractive extends StatefulWidget {
  final List<LatLon> stations;
  final int completedLevels;
  final int nextLevel;
  final String assetPath;
  final double markerDiameter;
  final double latMax;
  final double latMin;
  final double lonMin;
  final double lonMax;
  final double mapScale;
  final StationTapCallback? onStationTap;

  const GermanyMapWithProgressInteractive({
    Key? key,
    required this.stations,
    required this.completedLevels,
    required this.nextLevel,
    required this.assetPath,
    this.markerDiameter = 32,
    this.latMax = 55.05,
    this.latMin = 47.27,
    this.lonMin = 5.87,
    this.lonMax = 15.04,
    this.mapScale = 1.0,
    this.onStationTap,
  }) : super(key: key);

  @override
  State<GermanyMapWithProgressInteractive> createState() => _GermanyMapWithProgressInteractiveState();
}

class _GermanyMapWithProgressInteractiveState extends State<GermanyMapWithProgressInteractive> {
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

    final screenWidth = MediaQuery.of(context).size.width * widget.mapScale;
    final screenHeight = MediaQuery.of(context).size.height * widget.mapScale;
    final mapRatio = _mapImage!.width / _mapImage!.height;

    double imgWidth = screenWidth;
    double imgHeight = imgWidth / mapRatio;

    if (imgHeight > screenHeight) {
      imgHeight = screenHeight;
      imgWidth = imgHeight * mapRatio;
    }

    final levelCount = widget.completedLevels > widget.nextLevel
        ? widget.completedLevels
        : widget.nextLevel + 1;
    final List<LatLon> visibleStations = widget.stations.length >= levelCount
        ? widget.stations.sublist(0, levelCount)
        : widget.stations;

    final positions =
    visibleStations.map((s) => _project(s, imgWidth, imgHeight)).toList();

    return Center(
      child: SizedBox(
        width: imgWidth,
        height: imgHeight,
        child: Stack(
          children: [
            Image.asset(
              widget.assetPath,
              width: imgWidth,
              height: imgHeight,
              fit: BoxFit.contain,
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _ProgressLinePainter(
                  positions: positions,
                  completedLevels: widget.completedLevels,
                  nextLevel: widget.nextLevel,
                ),
              ),
            ),
            ...List.generate(positions.length, (i) {
              final pos = positions[i];
              if (i < widget.completedLevels) {
                return Positioned(
                  left: pos.dx - widget.markerDiameter / 2,
                  top: pos.dy - widget.markerDiameter / 2,
                  child: GestureDetector(
                    onTap: () {
                      if (widget.onStationTap != null) {
                        widget.onStationTap!(i);
                      }
                    },
                    child: Container(
                      width: widget.markerDiameter,
                      height: widget.markerDiameter,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black54,
                          width: 3,
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
                  ),
                );
              } else if (i == widget.nextLevel) {
                return Positioned(
                  left: pos.dx - widget.markerDiameter / 2,
                  top: pos.dy - widget.markerDiameter / 2,
                  child: Container(
                    width: widget.markerDiameter,
                    height: widget.markerDiameter,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black54,
                        width: 3,
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
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }
}

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
    final autobahn = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final whiteLine = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    int lastIdx = nextLevel > completedLevels ? nextLevel : completedLevels - 1;
    lastIdx = lastIdx.clamp(1, positions.length - 1);

    for (int i = 0; i < lastIdx; i++) {
      if (i + 1 < positions.length) {
        canvas.drawLine(positions[i], positions[i + 1], autobahn);
        canvas.drawLine(positions[i], positions[i + 1], whiteLine);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
