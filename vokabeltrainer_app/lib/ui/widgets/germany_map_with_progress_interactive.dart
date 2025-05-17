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
  double? _imageWidth;
  double? _imageHeight;
  bool _showAllMarkers = false;
  Offset? _lastTapPosition;

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
      _imageWidth = image.width.toDouble();
      _imageHeight = image.height.toDouble();
    });
  }

  Offset latLonToOffset(double lat, double lon, double width, double height) {
    final x = ((lon - widget.lonMin) / (widget.lonMax - widget.lonMin)) * width;
    final y = ((widget.latMax - lat) / (widget.latMax - widget.latMin)) * height;
    return Offset(x, y);
  }

  int? getStationAtPosition(Offset tapPos, double width, double height) {
    for (int i = 0; i < widget.stations.length; i++) {
      final station = widget.stations[i];
      final pos = latLonToOffset(station.lat, station.lon, width, height);
      final rect = Rect.fromCircle(center: pos, radius: widget.markerDiameter / 2);
      if (rect.contains(tapPos)) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_mapImage == null || _imageWidth == null || _imageHeight == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final width = _imageWidth! * widget.mapScale;
    final height = _imageHeight! * widget.mapScale;

    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 12.0, // <--- HIER: Nur der Zoom wurde verändert!
      child: Stack(
          children: [
          GestureDetector(
          onTapDown: (details) {
    setState(() {
    _lastTapPosition = details.localPosition;
    });
    },
      onTapUp: (details) {
        final tapPos = details.localPosition;
        final tappedStation = getStationAtPosition(tapPos, width, height);
        if (tappedStation != null && tappedStation < widget.completedLevels) {
          widget.onStationTap?.call(tappedStation);
        }
      },
      child: SizedBox(
        width: width,
        height: height,
        child: RawImage(
          image: _mapImage,
          fit: BoxFit.fill,
        ),
      ),
    ),
            // Marker-Overlay (Level-Punkte, grüne/gelbe/graue Kreise)
            ...List.generate(widget.stations.length, (index) {
              final station = widget.stations[index];
              final pos = latLonToOffset(
                station.lat,
                station.lon,
                width,
                height,
              );

              final isCompleted = index < widget.completedLevels;
              final isNext = index == widget.nextLevel;
              final color = isCompleted
                  ? Colors.green
                  : (isNext ? Colors.orange : Colors.grey.shade400);

              return Positioned(
                left: pos.dx - widget.markerDiameter / 2,
                top: pos.dy - widget.markerDiameter / 2,
                child: GestureDetector(
                  onTap: (isCompleted && widget.onStationTap != null)
                      ? () => widget.onStationTap!(index)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: widget.markerDiameter,
                    height: widget.markerDiameter,
                    decoration: BoxDecoration(
                      color: color.withOpacity(isCompleted ? 0.9 : 0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        if (isNext)
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            blurRadius: 18,
                            spreadRadius: 3,
                          ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: widget.markerDiameter / 2.2,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Optional: letzte Tipp-Position anzeigen (für Entwicklung/Debug)
            if (_lastTapPosition != null)
              Positioned(
                left: _lastTapPosition!.dx - 8,
                top: _lastTapPosition!.dy - 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
      ),
    );
  }
}
