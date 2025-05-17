import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'package:vokabeltrainer_app/core/latlon.dart'; // Nur dieser Import!

/// Widget, das eine Deutschlandkarte mit beliebig vielen Markern anzeigt.
class GermanyMapWithMarkersAuto extends StatefulWidget {
  final List<LatLon> points;
  final double markerDiameter;
  final String assetPath;

  final double latMax;
  final double latMin;
  final double lonMin;
  final double lonMax;

  const GermanyMapWithMarkersAuto({
    Key? key,
    required this.points,
    this.markerDiameter = 18,
    required this.assetPath,
    this.latMax = 55.05,
    this.latMin = 47.27,
    this.lonMin = 5.87,
    this.lonMax = 15.04,
  }) : super(key: key);

  @override
  State<GermanyMapWithMarkersAuto> createState() =>
      _GermanyMapWithMarkersAutoState();
}

class _GermanyMapWithMarkersAutoState extends State<GermanyMapWithMarkersAuto> {
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
    final x =
        (p.lon - widget.lonMin) / (widget.lonMax - widget.lonMin) * width;
    final y =
        (widget.latMax - p.lat) / (widget.latMax - widget.latMin) * height;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    if (_mapImage == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final width = _mapImage!.width.toDouble();
    final height = _mapImage!.height.toDouble();

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.assetPath,
              fit: BoxFit.contain,
            ),
          ),
          ...widget.points.map((p) {
            final pos = _project(p, width, height);
            return Positioned(
              left: pos.dx - widget.markerDiameter / 2,
              top: pos.dy - widget.markerDiameter / 2,
              child: Container(
                width: widget.markerDiameter,
                height: widget.markerDiameter,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black54, width: 2),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
