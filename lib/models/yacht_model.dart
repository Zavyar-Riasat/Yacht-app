class Yacht {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final String description;
  final double pricePerDay;
  final int capacity;
  final bool available;

  Yacht({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.description,
    required this.pricePerDay,
    required this.capacity,
    required this.available,
  });

  factory Yacht.fromFirestore(Map<String, dynamic> data, String id) {
    return Yacht(
      id: id,
      name: data['name'] as String? ?? '',
      location: data['location'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      description: data['description'] as String? ?? '',
      pricePerDay: (data['pricePerDay'] is num) ? (data['pricePerDay'] as num).toDouble() : double.tryParse('${data['pricePerDay']}') ?? 0.0,
      capacity: (data['capacity'] is int) ? data['capacity'] as int : int.tryParse('${data['capacity']}') ?? 0,
      available: data['available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'imageUrl': imageUrl,
      'description': description,
      'pricePerDay': pricePerDay,
      'capacity': capacity,
      'available': available,
    };
  }
}

// Keep the older name available for files importing `yacht_model.dart`.
typedef YachtModel = Yacht;
