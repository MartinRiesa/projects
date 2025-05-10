class Station {
  final int level;          // Spalte „Nr“
  final String name;        // Spalte „Station“
  final double latitude;    // Spalte „Latitude“
  final double longitude;   // Spalte „Longitude“
  final String imageAsset;  // Spalte „Bild“ (relativer Asset-Pfad)
  final String description; // Spalte „Erklärung“

  Station({
    required this.level,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.imageAsset,
    required this.description,
  });
}
