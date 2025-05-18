import 'package:flutter/material.dart';

class StationInfoDialog extends StatelessWidget {
  final ImageProvider? image;
  final String? description;
  final int stationIndex;

  const StationInfoDialog({
    Key? key,
    required this.stationIndex,
    this.image,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Station ${stationIndex + 1}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image(
                    image: image!,
                    fit: BoxFit.contain,
                    height: 180,
                  ),
                ),
              const SizedBox(height: 18),
              if (description != null)
                Text(
                  description!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Schließen"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
