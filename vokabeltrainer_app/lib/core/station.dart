// lib/core/station.dart
class Station {
  Station({
    required this.level,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.imageAsset = '',
  });

  final int level;
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final String imageAsset;

  @override
  bool operator ==(Object other) =>
      other is Station && other.level == level;

  @override
  int get hashCode => level.hashCode;
}
