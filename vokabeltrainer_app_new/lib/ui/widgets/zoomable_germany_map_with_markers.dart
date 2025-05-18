import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'package:vokabeltrainer_app/core/latlon.dart';

typedef StationTapCallback = void Function(int index);

class ZoomableGermanyMapWithMarkers extends StatefulWidget {
  final List<LatLon> stations;
  final int completedLevels;
  final int nextLevel;
  final String assetPath;
  final double markerDiameter;
  final double latMax;
  final double latMin;
  final double lonMin;
  final double lonMax;
  final StationTapCallback? onStationTap;

  const ZoomableGermanyMapWithMarkers({
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
    this.onStationTap,
  }) : super(key: key);

  @override
  State<ZoomableGermanyMapWithMarkers> createState() => _ZoomableGermanyMapWithMarkersState();
}

class _ZoomableGermanyMapWithMarkersState extends State<ZoomableGermanyMapWithMarkers> {
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

    // Keine automatische Verkleinerung mehr!
    final imgWidth = _mapImage!.width.toDouble();
    final imgHeight = _mapImage!.height.toDouble();

    return InteractiveViewer(
      maxScale: 8.0,
      minScale: 0.5,
      child: SizedBox(
        width: imgWidth,
        height: imgHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: RawImage(
                image: _mapImage,
                fit: BoxFit.contain,
              ),
            ),
            ...List.generate(widget.stations.length, (index) {
              final LatLon pos = widget.stations[index];
              final Offset projected = _project(pos, imgWidth, imgHeight);
              final bool isCompleted = index < widget.completedLevels;
              final bool isNext = index == widget.nextLevel;

              Color markerColor;
              if (isCompleted) {
                markerColor = Colors.green;
              } else if (isNext) {
                markerColor = Colors.orange;
              } else {
                markerColor = Colors.grey;
              }

              return Positioned(
                left: projected.dx - widget.markerDiameter / 2,
                top: projected.dy - widget.markerDiameter / 2,
                child: GestureDetector(
                  onTap: () {
                    if (widget.onStationTap != null) {
                      widget.onStationTap!(index);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: widget.markerDiameter,
                    height: widget.markerDiameter,
                    decoration: BoxDecoration(
                      color: markerColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isNext ? Colors.yellow : Colors.white,
                        width: isNext ? 4 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
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
